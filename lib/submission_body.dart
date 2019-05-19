import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:lurkers_for_reddit/post_photo_view.dart';
import 'package:lurkers_for_reddit/video_viewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:photo_view/photo_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class SubmissionBodyState extends State<SubmissionBody> {
  Future<String> _vidUrl;

  @override
  void initState() {
    super.initState();
    _vidUrl = getVideoUrl();
  }

  String getImageUrl() {
    String imageUrl = "";
    if (widget.submission.isSelf) return imageUrl;

    if (widget.submission.variants.length > 0) {
      var gifVariant = widget.submission.variants
          .firstWhere((x) => x.containsKey('gif'))
          .values
          .toList()[0];
      if (gifVariant != null) {
        imageUrl = gifVariant.source.url.toString();
      }
    } else if (widget.submission.url.toString().contains('.jpg') ||
        widget.submission.url.toString().contains('.jpeg') ||
        widget.submission.url.toString().contains('.png') ||
        widget.submission.url.toString().contains('.gif') ||
        widget.submission.url.toString().contains('.webm')) {
      imageUrl = widget.submission.url.toString();
    } else if (widget.submission.preview.length > 0) {
      imageUrl = widget.submission.preview[0].source.url.toString();
    }

    imageUrl = imageUrl.replaceAll('amp;', '').replaceAll('.gifv', '.mp4');
    return imageUrl;
  }

  Future<String> getVideoUrl() async {
    String vidUrl;
    var data = widget.submission.data;
    if (widget.submission.url.toString().contains('v.redd.it')) {
      // look for fallback_url
      if (data['secure_media'] != null) {
        vidUrl = data['secure_media']['reddit_video']['fallback_url'];
      } else if (data['crosspost_parent_list'] != null) {
        vidUrl = data['crosspost_parent_list'][0]['secure_media']
            ['reddit_video']['fallback_url'];
      }
    } else if (widget.submission.url.toString().contains('streamable')) {
      var hash = widget.submission.url.path;
      var url = 'http://api.streamable.com/videos$hash';
      var resp = await http.get(url);
      var jsonResponse = convert.jsonDecode(resp.body);
      vidUrl = 'http:' +  jsonResponse['files']['mp4']['url'];
      return vidUrl;
    } else if (widget.submission.url.toString().contains('gfycat')) {
            var hash = widget.submission.url.path;
      var url = 'https://api.gfycat.com/v1/gfycats$hash';
      var resp = await http.get(url);
      var jsonResponse = convert.jsonDecode(resp.body);
      vidUrl = jsonResponse['gfyItem']['mp4Url'];
      return vidUrl;
    }
    return vidUrl;
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl;
    setState(() {
      imageUrl = getImageUrl();
    });
    PhotoView photoView;
    String postUrl = widget.submission.url.toString();
    bool isVid = false;
    if (postUrl.contains('v.redd.it') || postUrl.contains('streamable') || postUrl.contains('gfycat')) {
      isVid = true;
    }
    if (imageUrl.isNotEmpty &&
        (imageUrl.contains('.mp4') ||
            imageUrl.contains('.gif') ||
            imageUrl.contains('.jpg') ||
            imageUrl.contains('.jpeg') ||
            imageUrl.contains('.png'))) {
      photoView = PhotoView(
        gaplessPlayback: true,
        imageProvider: NetworkImage(imageUrl, headers: null),
      );
    }
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height - 400,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: material.Visibility(
          replacement: InkWell(child: Container(),onTap: () {
            _handleLink(postUrl, imageUrl);
          },),
          visible: imageUrl.isNotEmpty || isVid,
          child: FutureBuilder(
            initialData: "",
            future: _vidUrl,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return InkWell(
                  onTap: () {
                    if (isVid && snapshot.data.isNotEmpty) {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          opaque: false,
                          pageBuilder: (BuildContext context, _, __) =>
                              VideoViewer(
                                url: snapshot.data,
                              ),
                        ),
                      );
                    } else if (photoView != null && imageUrl.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostPhotoView(
                                photoView: photoView,
                              ),
                        ),
                      );
                    }
                  },
                  child: isVid
                      ? Center(
                          child: Icon(Icons.play_arrow, size: 100.0),
                        )
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        ),
                );
              } else {
                return Center(child: CircularProgressIndicator(),);
              }
            },
          ),
        ),
      ),
    );
  }

  _handleLink(url, String imageUrl) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw "cant open link";
    }
  }
}

class SubmissionBody extends StatefulWidget {
  SubmissionBody({Key key, this.submission}) : super(key: key);

  final Submission submission;

  @override
  SubmissionBodyState createState() => SubmissionBodyState();
}
