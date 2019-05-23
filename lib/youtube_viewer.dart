import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeViewerState extends State<YoutubeViewer> {
  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      context: context,
      videoId: YoutubePlayer.convertUrlToId(widget.url),
      autoPlay: widget.autoplay,
      showVideoProgressIndicator: true,

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
