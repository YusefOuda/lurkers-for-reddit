import 'package:flutter/material.dart';
import 'package:draw/draw.dart' as Dart;
import 'package:flutter/rendering.dart';
import 'package:lurkers_for_reddit/comment_and_depth.dart';

import 'comment_view.dart';
import 'more_comments_view.dart';

class _SubmissionCommentsState extends State<SubmissionComments> {
  List<CommentAndDepth> _comments = [];

  @override
  void initState() {
    super.initState();
    widget.submission.refreshComments().then((x) {
      var cmts = widget.submission.comments.comments;
      setState(() {
        cmts.forEach((c) {
          addToComments(c);
        });
      });
    });
  }

  addToComments(comment, {index, depth}) {
    if (comment == null) return;
    CommentAndDepth commentAndDepth =
        CommentAndDepth(comment: comment, visible: true);
    if (depth != null) {
      commentAndDepth.depth = depth;
    } else if (comment is Dart.Comment) {
      commentAndDepth.depth = comment.depth;
    }
    if (index != null) {
      _comments.insert(index, commentAndDepth);
    } else {
      _comments.add(commentAndDepth);
    }
    if (commentAndDepth.comment is Dart.MoreComments) return;
    commentAndDepth.comment.replies?.comments?.forEach((r) {
      addToComments(r);
    });
  }

  collapseChildren(index, depth) {
    var sublist = _comments.sublist(index + 1);
    var endIndex =
        sublist.indexWhere((x) => x.depth != null && x.depth <= depth);
    setState(() {
      sublist.sublist(0, endIndex).forEach((x) {
        x.visible = !x.visible;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Text(
                    "${widget.submission.title}",
                    style: Theme.of(context).textTheme.headline,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final commentAndDepth = _comments[index];
                if (commentAndDepth.comment is Dart.MoreComments) {
                  CommentAndDepth parent;
                  parent = _comments.firstWhere(
                      (x) =>
                          x.comment.fullname ==
                          commentAndDepth.comment.parentId,
                      orElse: () {});
                  if (parent == null) {
                    return Visibility(
                      visible: commentAndDepth.visible,
                      child: MoreCommentsView(
                          parentId: commentAndDepth.comment.fullname,
                          depth: 0,
                          onLoadTap: (String id) {
                            var index = _comments.indexWhere((x) =>
                                x.comment.fullname == id &&
                                x.comment is Dart.MoreComments);
                            _comments[index].comment.comments().then((x) {
                              _comments.removeAt(index);
                              setState(() {
                                x.forEach((c) {
                                  addToComments(c, index: index);
                                  index++;
                                });
                              });
                            });
                          }),
                    );
                  } else {
                    return Visibility(
                      visible: parent.visible,
                      child: MoreCommentsView(
                          parentId: parent.comment.fullname,
                          depth: parent.depth,
                          onLoadTap: (String parentId) {
                            var index = _comments.indexWhere((x) =>
                                x.comment.parentId == parentId &&
                                x.comment is Dart.MoreComments);
                            var parentDepth = _comments
                                .firstWhere(
                                    (x) => x.comment.fullname == parentId)
                                .depth;
                            _comments[index].comment.comments().then((x) {
                              _comments.removeAt(index);
                              setState(() {
                                x.forEach((c) {
                                  addToComments(c,
                                      index: index, depth: parentDepth+1);
                                  index++;
                                });
                              });
                            });
                            print("LOADING MORE $parentId");
                          }),
                    );
                  }
                } else {
                  return InkWell(
                    onTap: () {
                      collapseChildren(index, commentAndDepth.depth);
                    },
                    child: Visibility(
                      child: CommentView(
                          comment: commentAndDepth.comment,
                          depth: commentAndDepth.depth),
                      visible: commentAndDepth.visible,
                      replacement: Container(),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SubmissionComments extends StatefulWidget {
  SubmissionComments({Key key, this.submission}) : super(key: key);

  final Dart.Submission submission;

  @override
  _SubmissionCommentsState createState() => _SubmissionCommentsState();
}
