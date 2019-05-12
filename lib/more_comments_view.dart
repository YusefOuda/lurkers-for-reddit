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
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black))),
        child: Padding(
          padding: EdgeInsets.only(
            left: 10.0 + (depth * 10.0),
            top: 10.0,
            bottom: 10.0,
            right: 10.0,
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