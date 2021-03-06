import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PostPhotoView extends StatelessWidget {
  final String url;

  PostPhotoView({this.url});

  @override
  Widget build(BuildContext context) {
    return PhotoView(
      imageProvider: NetworkImage(url, headers: null),
      backgroundDecoration: BoxDecoration(color: Colors.black.withOpacity(0.9)),
    );
  }
}
