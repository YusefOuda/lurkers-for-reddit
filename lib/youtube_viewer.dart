import 'package:flutter/material.dart';
import 'package:youtube_player/youtube_player.dart';
class YoutubeViewerState extends State<YoutubeViewer> {
  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      quality: YoutubeQuality.FHD,
      context: context,
      source: widget.url,
      autoPlay: widget.autoplay,
    );
  }
}

class YoutubeViewer extends StatefulWidget {
  YoutubeViewer({this.url, this.autoplay});

  final String url;
  final bool autoplay;
  @override
  YoutubeViewerState createState() => YoutubeViewerState();
}
