import 'package:flutter/material.dart';
import 'package:draw/draw.dart' as Dart;
import 'package:lurkers_for_reddit/helpers/time_converter.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:url_launcher/url_launcher.dart';

class _CommentViewState extends State<CommentView> {
  @override
  Widget build(BuildContext context) {
    var unescape = new HtmlUnescape();
    return Container(
      //padding: EdgeInsets.only(top: 7.0, bottom: 7.0),
      margin: EdgeInsets.only(left: (widget.depth * 10.0)),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black))),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.black45,
            border: Border(left: BorderSide(color: _getBorderSideColor()))),
        padding: EdgeInsets.only(left: 4.0),
        child: Padding(
          padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    "/u/${widget.comment.author}",
                    style: Theme.of(context)
                        .textTheme
                        .subtitle
                        .copyWith(fontSize: 11.0),
                  ),
                  Text("  •  "),
                  Text("${widget.comment.score} points",
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          .copyWith(fontSize: 11.0)),
                  Text("  •  "),
                  Text(
                      "${TimeConverter.convertUtcToDiffString(widget.comment.createdUtc)}",
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          .copyWith(fontSize: 11.0)),
                  Spacer(),
                  Visibility(
                    visible: widget.childrenCollapsed,
                    child: Text(
                      "+" + widget.numChildren.toString(),
                      style: TextStyle(backgroundColor: Colors.greenAccent),
                    ),
                    replacement: Container(),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    child: MarkdownBody(
                      data: unescape.convert(widget.comment.body),
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

  _getBorderSideColor() {
    var colors = [
      Colors.white,
      Colors.lightBlue,
      Colors.lightGreen,
      Colors.orange,
      Colors.pink,
      Colors.purple,
      Colors.yellow,
      Colors.amber,
      Colors.cyan,
      Colors.red
    ];
    return colors[widget.depth % colors.length];
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
      this.numChildren})
      : super(key: key);

  final Dart.Comment comment;
  final int depth;
  final bool childrenCollapsed;
  final int numChildren;

  @override
  _CommentViewState createState() => _CommentViewState();
}
