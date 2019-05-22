import 'package:flutter/material.dart';
import 'package:draw/draw.dart' as Dart;
import 'package:flutter/rendering.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lurkers_for_reddit/comment_and_depth.dart';
import 'package:lurkers_for_reddit/helpers/subreddit_helper.dart';
import 'package:lurkers_for_reddit/helpers/text_helper.dart';
import 'package:lurkers_for_reddit/helpers/time_converter.dart';
import 'package:lurkers_for_reddit/submission_body.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:url_launcher/url_launcher.dart';

import 'comment_view.dart';
import 'more_comments_view.dart';

class _SubmissionCommentsState extends State<SubmissionComments> {
  List<CommentAndDepth> _comments = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;
    widget.submission.refreshComments().then((x) {
      var cmts = widget.submission.comments.comments;
      if (mounted) {
        setState(() {
          cmts.forEach((c) {
            addToComments(c);
          });
        });
        _loading = false;
      }
    });
  }

  addToComments(comment, {index, depth}) {
    if (comment == null) return;
    CommentAndDepth commentAndDepth = CommentAndDepth(
        comment: comment, visible: true, childrenCollapsed: false);
    if (depth != null) {
      commentAndDepth.depth = depth;
    } else if (comment is Dart.Comment) {
      commentAndDepth.depth = comment.depth;
    } else if (comment is Dart.MoreComments) {
      var parent = _comments.firstWhere(
          (x) => x.comment.fullname == comment.parentId,
          orElse: () {});
      commentAndDepth.depth = parent?.depth != null ? parent.depth + 1 : 0;
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

  toggleVisibilityChildren(id, visibility, numCollapsed) {
    var children = _comments.where((c) => c.comment.parentId == id).toList();
    if (children == null || children.length == 0) return numCollapsed;
    children.forEach((c) {
      numCollapsed = toggleVisibilityChildren(
          c.comment.fullname, visibility, numCollapsed);
      c.visible = visibility;
      c.childrenCollapsed = !visibility;
      numCollapsed++;
    });
    return numCollapsed;
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) {
        var body = Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child: _loading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : _comments.length > 0
                      ? ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: ClampingScrollPhysics(),
                          shrinkWrap: true,
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
                                      parentId:
                                          commentAndDepth.comment.fullname,
                                      depth: 0,
                                      onLoadTap: (String id) {
                                        _loadMore(id);
                                      }),
                                );
                              } else {
                                return Visibility(
                                  visible: commentAndDepth.visible,
                                  child: MoreCommentsView(
                                      parentId: parent.comment.fullname,
                                      depth: parent.depth + 1,
                                      onLoadTap: (String parentId) {
                                        _loadMoreParent(parentId);
                                      }),
                                );
                              }
                            } else {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    var numCollapsed = toggleVisibilityChildren(
                                        commentAndDepth.comment.fullname,
                                        commentAndDepth.childrenCollapsed,
                                        0);
                                    commentAndDepth.numChildren = numCollapsed;
                                    if (numCollapsed > 0) {
                                      commentAndDepth.childrenCollapsed =
                                          !commentAndDepth.childrenCollapsed;
                                    }
                                  });
                                },
                                child: Visibility(
                                  child: CommentView(
                                      comment: commentAndDepth.comment,
                                      depth: commentAndDepth.depth,
                                      childrenCollapsed:
                                          commentAndDepth.childrenCollapsed,
                                      numChildren: commentAndDepth.numChildren),
                                  visible: commentAndDepth.visible,
                                  replacement: Container(),
                                ),
                              );
                            }
                          },
                        )
                      : Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Center(
                            child: Text(
                              "No comments!",
                              style: Theme.of(context).textTheme.body2,
                            ),
                          ),
                        ),
            ),
          ],
        );
        var subtitle = Padding(
          padding: EdgeInsets.only(top: 4.0),
          child: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: "/u/${widget.submission.author}",
                  style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: "  •  ",
                  style: TextStyle(fontSize: 10.0),
                ),
                TextSpan(
                  text:
                      "${TimeConverter.convertUtcToDiffString(widget.submission.createdUtc)} ago",
                  style: TextStyle(fontSize: 10.0),
                ),
                TextSpan(
                  text: widget.submission.linkFlairText != null ? "  •  " : "",
                  style: TextStyle(fontSize: 10.0),
                ),
                TextSpan(
                    text: widget.submission.linkFlairText != null
                        ? widget.submission.linkFlairText
                        : "",
                    style: TextStyle(
                        backgroundColor: Colors.blue.shade900, fontSize: 10.0)),
              ],
            ),
          ),
        );
        var aboveTitle = RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: TextHelper.convertScoreToAbbreviated(
                    widget.submission.score),
                style: Theme.of(context).textTheme.subtitle.copyWith(
                    color: Colors.deepOrangeAccent,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: "  •  ",
                style: TextStyle(fontSize: 10.0),
              ),
              TextSpan(
                text: widget.submission.subreddit.displayName,
                style: Theme.of(context)
                    .textTheme
                    .subtitle
                    .copyWith(color: Colors.deepOrangeAccent, fontSize: 12.0),
              ),
              TextSpan(
                text: "  •  ",
                style: TextStyle(fontSize: 10.0),
              ),
              TextSpan(
                text: widget.submission.numComments.toString() + ' comments',
                style: Theme.of(context)
                    .textTheme
                    .subtitle
                    .copyWith(color: Colors.deepOrangeAccent, fontSize: 9.0),
              ),
            ],
          ),
        );
        var headerRow = Padding(
          padding: EdgeInsets.all(7.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(child: aboveTitle),
                    Flexible(
                      child: Text(
                        widget.submission.title,
                        style: Theme.of(context)
                            .textTheme
                            .headline
                            .copyWith(fontSize: 20.0),
                      ),
                    ),
                    Flexible(
                      child: subtitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
        if (!widget.submission.isSelf) {
          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SubmissionBody(submission: widget.submission),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return headerRow;
                      },
                      childCount: 1,
                    ),
                  ),
                ];
              },
              body: body,
            ),
          );
        } else {
          var unescape = HtmlUnescape();
          return Scaffold(
            appBar: AppBar(
              backgroundColor: SubredditHelper.getSubColor(widget.subreddit),
            ),
            body: ListView(
              children: <Widget>[
                headerRow,
                Visibility(
                  visible: widget.submission.selftext != null &&
                      widget.submission.selftext.isNotEmpty,
                  child: Divider(),
                  replacement: Container(),
                ),
                Visibility(
                  visible: widget.submission.selftext != null &&
                      widget.submission.selftext.isNotEmpty,
                  replacement: Container(),
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: MarkdownBody(
                      styleSheet:
                          MarkdownStyleSheet.fromTheme(Theme.of(context))
                              .copyWith(
                                  blockquoteDecoration: BoxDecoration(
                                      color: Colors.blueGrey.shade700)),
                      data: unescape
                          .convert(widget.submission.selftext ?? "")
                          .replaceAll('&#x200B;', '\u200b'),
                      onTapLink: (url) {
                        _handleLink(url);
                      },
                    ),
                  ),
                ),
                body
              ],
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
            ),
          );
        }
      },
    );
  }

  _loadMore(id) async {
    var index = _comments.indexWhere(
        (x) => x.comment.fullname == id && x.comment is Dart.MoreComments);
    _comments[index].comment.comments().then((x) {
      _comments.removeAt(index);
      setState(() {
        x.forEach((c) {
          addToComments(c, index: index);
          index++;
        });
      });
    });
  }

  _loadMoreParent(parentId) async {
    var index = _comments.indexWhere((x) =>
        x.comment.parentId == parentId && x.comment is Dart.MoreComments);
    _comments[index].comment.comments().then((x) {
      _comments.removeAt(index);
      setState(() {
        x.forEach((c) {
          addToComments(c, index: index, depth: c.depth);
          index++;
        });
      });
    });
    print("LOADING MORE $parentId");
  }

  _handleLink(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw "cant open link";
    }
  }
}

class SubmissionComments extends StatefulWidget {
  SubmissionComments({Key key, this.submission, this.subreddit})
      : super(key: key);

  final Dart.Submission submission;
  final dynamic subreddit;

  @override
  _SubmissionCommentsState createState() => _SubmissionCommentsState();
}
