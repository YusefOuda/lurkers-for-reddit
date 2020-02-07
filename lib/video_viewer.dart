import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class VideoViewer extends StatefulWidget {
  VideoViewer({this.url});

  final String url;

  @override
  VideoViewerState createState() => VideoViewerState();
}

class VideoViewerState extends State<VideoViewer> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;
  Future<void> _initializeAudioPlayerFuture;
  AudioPlayer _audioPlayer;

  getAudioUrl() {
    return widget.url.substring(0, widget.url.lastIndexOf('/')) + '/audio';
  }

  @override
  void initState() {
    super.initState();
    initControllers();
  }

  initControllers() async {
    _controller = VideoPlayerController.network(widget.url);
    _initializeVideoPlayerFuture = _controller.initialize();
    _audioPlayer = AudioPlayer();
    //TODO:wait for this to be implemented_audioPlayer.setReleaseMode(ReleaseMode.STOP);
    var audioUrl = getAudioUrl();
    _initializeAudioPlayerFuture = _audioPlayer.setUrl(audioUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    //TODO:wait for this to be implemented_audioPlayer.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Future.wait(
            [_initializeVideoPlayerFuture, _initializeAudioPlayerFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _handlePlay();
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  void _handlePlay() async {
    if (_controller.value.isPlaying) {
      _audioPlayer.pause();
      setState(() {
        _controller.pause();
      });
    } else {
      _audioPlayer.resume();
      setState(() {
        _controller.play();
      });
    }
  }
}
