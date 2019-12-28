import 'package:flutter/material.dart';
import 'package:lurkers_for_reddit/helpers/comment_helper.dart';

class MoreCommentsView extends StatelessWidget {
  final int depth;
  final String parentId;
  final OnLoadTapCallback onLoadTap;

  MoreCommentsView({this.parentId, this.depth, this.onLoadTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onLoadTap(parentId);
      },
      child: Container(
        margin: EdgeInsets.only(left: (depth * 8.0) + 20.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            bottom: BorderSide(color: Colors.black),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              left: BorderSide(
                color: CommentHelper.getBorderSideColor(depth),
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 5.0,
              top: 10.0,
              bottom: 10.0,
            ),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    "Load more comments...",
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 12.0, color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

typedef OnLoadTapCallback = void Function(String color);
