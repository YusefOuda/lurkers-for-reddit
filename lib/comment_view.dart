import 'package:flutter/material.dart';
import 'package:draw/draw.dart' as Dart;
import 'package:lurkers_for_reddit/helpers/comment_helper.dart';
import 'package:lurkers_for_reddit/helpers/time_converter.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:url_launcher/url_launcher.dart';

class _CommentViewState extends State<CommentView> {
  @override
  Widget build(BuildContext context) {
    var unescape = HtmlUnescape();
    return Container(
      margin: EdgeInsets.only(left: (widget.depth * 8.0) + 20.0, right: 20.0),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black))),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            left: BorderSide(
              color: CommentHelper.getBorderSideColor(widget.depth),
            ),
          ),
        ),
        padding: EdgeInsets.only(left: 12.0, right: 8.0),
        child: Padding(
          padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    "/u/${widget.comment.author}",
                    style: Theme.of(context).textTheme.subtitle.copyWith(
                        fontSize: 14.0,
                        backgroundColor:
                            widget.comment.author == widget.submission.author
                                ? Colors.blue.shade600
                                : null),
                  ),
                  Text("  •  "),
                  Text("${widget.comment.score} points",
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          .copyWith(fontSize: 14.0)),
                  Text("  •  "),
                  Text(
                      "${TimeConverter.convertUtcToDiffString(widget.comment.createdUtc)}",
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          .copyWith(fontSize: 14.0)),
                  Text(widget.comment.authorFlairText != null &&
                          widget.comment.authorFlairText.isNotEmpty
                      ? "  •  "
                      : ""),
                  Visibility(
                    visible: widget.comment.authorFlairText != null,
                    child: Flexible(
                      flex: 8,
                      child: Text(
                        "${widget.comment.authorFlairText}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.caption.copyWith(
                            fontSize: 14.0,
                            backgroundColor: Colors.blue.shade900),
                      ),
                    ),
                  ),
                  Spacer(),
                  Visibility(
                    visible: widget.childrenCollapsed,
                    child: Padding(
                      padding: EdgeInsets.only(right: 4.0),
                      child: Text(
                        "+" + widget.numChildren.toString(),
                        style: TextStyle(color: Colors.green.shade700),
                      ),
                    ),
                    replacement: Container(),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    child: MarkdownBody(
                      selectable: true,
                      styleSheet:
                          MarkdownStyleSheet.fromTheme(Theme.of(context))
                              .copyWith(
                                  blockquoteDecoration: BoxDecoration(
                                      color: Colors.blueGrey.shade700)),
                      data: unescape
                          .convert(widget.comment.body)
                          .replaceAll('&#x200B;', '\u200b'),
                      onTapLink: (url) {
                        _handleLink(url);
                      },
                    ),
                  ), // Text(widget.comment.body),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _handleLink(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw "cant open link";
    }
  }
}

class CommentView extends StatefulWidget {
  CommentView(
      {Key key,
      this.comment,
      this.depth,
      this.childrenCollapsed,
      this.numChildren,
      this.submission})
      : super(key: key);

  final Dart.Comment comment;
  final int depth;
  final bool childrenCollapsed;
  final int numChildren;
  final Dart.Submission submission;

  @override
  _CommentViewState createState() => _CommentViewState();
}
