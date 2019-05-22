import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeViewerState extends State<YoutubeViewer> {
  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      context: context,
      videoId: YoutubePlayer.convertUrlToId(widget.url),
      autoPlay: false,
      showVideoProgressIndicator: true,
    );
  }
}

class YoutubeViewer extends StatefulWidget {
  YoutubeViewer({this.url});

  final String url;

  @override
  YoutubeViewerState createState() => YoutubeViewerState();
}
