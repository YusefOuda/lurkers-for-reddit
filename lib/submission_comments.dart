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
    CommentAndDepth commentAndDepth = CommentAndDepth(comment: comment);
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
                  var parent = _comments.firstWhere((x) =>
                      x.comment.fullname == commentAndDepth.comment.parentId);
                  return MoreCommentsView(
                      parentId: parent.comment.fullname,
                      depth: parent.depth,
                      onLoadTap: (String parentId) {
                        var index = _comments.indexWhere((x) =>
                            x.comment.parentId == parentId &&
                            x.comment is Dart.MoreComments);
                        var parentDepth = _comments
                            .firstWhere((x) => x.comment.fullname == parentId)
                            .depth;
                        _comments[index].comment.comments().then((x) {
                          _comments.removeAt(index);
                          setState(() {
                            x.forEach((c) {
                              addToComments(c, index: index, depth: parentDepth);
                              index++;
                            });
                          });
                        });
                        print("LOADING MORE $parentId");
                      });
                } else {
                  return CommentView(
                      comment: commentAndDepth.comment,
                      depth: commentAndDepth.depth);
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
