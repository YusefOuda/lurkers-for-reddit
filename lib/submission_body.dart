import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:lurkers_for_reddit/post_photo_view.dart';
import 'package:lurkers_for_reddit/video_viewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:photo_view/photo_view.dart';

class SubmissionBodyState extends State<SubmissionBody> {
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

  String getVideoUrl() {
    String vidUrl = "";
    var data = widget.submission.data;
    if (widget.submission.url.toString().contains('v.redd.it')) {
      // look for fallback_url
      if (data['secure_media'] != null) {
        vidUrl = data['secure_media']['reddit_video']['fallback_url'];
      } else if (data['crosspost_parent_list'] != null) {
        vidUrl = data['crosspost_parent_list'][0]['secure_media']
            ['reddit_video']['fallback_url'];
      }
    }
    return vidUrl;
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = getImageUrl();
    String vidUrl = getVideoUrl();
    PhotoView photoView;
    String postUrl = widget.submission.url.toString();
    bool isVid = false;
    if (postUrl.contains('v.redd.it')) {
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
          visible: imageUrl.isNotEmpty || vidUrl.isNotEmpty,
          child: InkWell(
            onTap: () {
              if (isVid && vidUrl.isNotEmpty) {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (BuildContext context, _, __) => VideoViewer(
                          url: vidUrl,
                        ),
                  ),
                );
              } else if (photoView != null &&
                  imageUrl.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostPhotoView(
                          photoView: photoView,
                        ),
                  ),
                );
              } else {
                _handleLink(postUrl, imageUrl);
              }
            },
            child: isVid ? Center(child: Icon(Icons.play_arrow, size: 100.0),) : Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          replacement: Container(),
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
