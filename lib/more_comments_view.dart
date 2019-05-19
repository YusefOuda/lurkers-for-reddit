import 'package:flutter/material.dart';

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
        margin: EdgeInsets.only(left: (depth * 8.0)),
        decoration: BoxDecoration(
            ),//border: Border(bottom: BorderSide(color: Colors.black))),
        child: Padding(
          padding: EdgeInsets.only(
            top: 8.0,
            bottom: 8.0,
          ),
          child: Row(
            children: <Widget>[
              Flexible(
                child: Text(
                  "Load more comments...",
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef OnLoadTapCallback = void Function(String color);