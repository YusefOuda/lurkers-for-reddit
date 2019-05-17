import 'package:flutter/material.dart';
import 'package:draw/draw.dart' as Dart;
import 'package:lurkers_for_reddit/time_converter.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:url_launcher/url_launcher.dart';

class _CommentViewState extends State<CommentView> {
  @override
  Widget build(BuildContext context) {
    var unescape = new HtmlUnescape();
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black))),
      child: Padding(
        padding: EdgeInsets.only(
          left: 10.0 + (widget.depth * 10.0),
          top: 10.0,
          bottom: 10.0,
          right: 10.0,
        ),
        child: Container(
          decoration: BoxDecoration(
              border: Border(left: BorderSide(color: _getBorderSideColor()))),
          padding: EdgeInsets.only(left: 8.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    "/u/${widget.comment.author}",
                    style: Theme.of(context).textTheme.subtitle,
                  ),
                  Text("  • "),
                  Text("${widget.comment.score} points"),
                  Text("  • "),
                  Text(
                      "${TimeConverter.convertUtcToDiffString(widget.comment.createdUtc)}"),
                      Spacer(),
                  Visibility(
                    visible: widget.childrenCollapsed,
                    child: Text("+" + widget.numChildren.toString(), style: TextStyle(backgroundColor: Colors.greenAccent), ),
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
    var colors = [Colors.white, Colors.lightBlue, Colors.lightGreen, Colors.orange, Colors.pink, Colors.purple, Colors.yellow, Colors.amber, Colors.cyan, Colors.red];
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
  CommentView({Key key, this.comment, this.depth, this.childrenCollapsed, this.numChildren})
      : super(key: key);

  final Dart.Comment comment;
  final int depth;
  final bool childrenCollapsed;
  final int numChildren;

  @override
  _CommentViewState createState() => _CommentViewState();
}
