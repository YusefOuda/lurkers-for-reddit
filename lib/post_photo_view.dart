import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PostPhotoView extends StatelessWidget {
  final PhotoView photoView;

  PostPhotoView({this.photoView});

  @override
  Widget build(BuildContext context) {
    return photoView;
  }
}