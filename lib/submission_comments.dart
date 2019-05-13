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
        CommentAndDepth(comment: comment, visible: true, childrenCollapsed: false);
    if (depth != null) {
      commentAndDepth.depth = depth;
    } else if (comment is Dart.Comment) {
      commentAndDepth.depth = comment.depth;
    } else if (comment is Dart.MoreComments) {
      var parent = _comments.firstWhere((x) => x.comment.fullname == comment.parentId, orElse: () {});
      commentAndDepth.depth = parent?.depth != null ? parent.depth+1 : 0;
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

  toggleVisibilityChildren(id, visibility) {
    var children = _comments.where((c) => c.comment.parentId == id).toList();
    if (children == null || children.length == 0) return;
    children.forEach((c) {
      c.visible = visibility;
      c.childrenCollapsed = !visibility;
      toggleVisibilityChildren(c.comment.fullname, visibility);
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
                      visible: commentAndDepth.visible,
                      child: MoreCommentsView(
                          parentId: parent.comment.fullname,
                          depth: parent.depth + 1,
                          onLoadTap: (String parentId) {
                            var index = _comments.indexWhere((x) =>
                                x.comment.parentId == parentId &&
                                x.comment is Dart.MoreComments);
                            _comments[index].comment.comments().then((x) {
                              _comments.removeAt(index);
                              setState(() {
                                x.forEach((c) {
                                  addToComments(c,
                                      index: index, depth: c.depth);
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
                      setState(() {
                        toggleVisibilityChildren(commentAndDepth.comment.fullname, commentAndDepth.childrenCollapsed);
                        commentAndDepth.childrenCollapsed = !commentAndDepth.childrenCollapsed;
                      });
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
