import 'package:draw/draw.dart' as dart;
import 'package:flutter/material.dart';
import 'package:lurkers_for_reddit/helpers/post_type_helper.dart';
import 'package:lurkers_for_reddit/helpers/submission_helper.dart';
import 'package:lurkers_for_reddit/post_photo_view.dart';
import 'package:lurkers_for_reddit/transparent_route.dart';
import 'package:lurkers_for_reddit/video_viewer.dart';
import 'package:lurkers_for_reddit/youtube_viewer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:cached_network_image/cached_network_image.dart';

class SubmissionBodyState extends State<SubmissionBody> {
  Future<String> _vidUrl;

  @override
  void initState() {
    super.initState();
    _vidUrl = getVideoUrl();
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
      vidUrl = 'http:' + jsonResponse['files']['mp4']['url'];
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
      imageUrl = SubmissionHelper.getImageUrl(widget.submission);
    });
    String postUrl = widget.submission.url.toString();
    PostType type = PostTypeHelper.getPostType(widget.submission);
    var expandedHeight = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).size.height / 3);
    Widget background;
    if (type == PostType.YouTube) {
      background = YoutubeViewer(
        url: postUrl,
      );
    } else if (type == PostType.Vid) {
      background = FutureBuilder(
        initialData: "",
        future: _vidUrl,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return InkWell(
              onTap: () {
                if (snapshot.data.isNotEmpty) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (BuildContext context, _, __) => VideoViewer(
                            url: snapshot.data,
                          ),
                    ),
                  );
                }
              },
              child: Center(
                child: Icon(Icons.play_arrow, size: 100.0),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );
    } else if (type == PostType.Pic) {
      Widget picBackground = CachedNetworkImage(
        fit: BoxFit.cover,
        imageUrl: imageUrl,
        placeholder: (context, url) => Center(
              child: CircularProgressIndicator(),
            ),
        errorWidget: (context, url, error) => Center(
              child: Icon(Icons.error),
            ),
      );
      background = InkWell(
          child: picBackground,
          onTap: () {
            Navigator.push(
              context,
              TransparentRoute(
                builder: (context) => PostPhotoView(
                      url: imageUrl,
                    ),
              ),
            );
          });
    }

    var sliverAppBar = SliverAppBar(
      pinned: false,
      snap: false,
      floating: true,
      expandedHeight: expandedHeight,
      title: Text(
        widget.submission.subreddit.displayName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        collapseMode: CollapseMode.parallax,
        background: background,
      ),
    );
    return sliverAppBar;
  }
}

class SubmissionBody extends StatefulWidget {
  SubmissionBody({Key key, this.submission}) : super(key: key);

  final dart.Submission submission;

  @override
  SubmissionBodyState createState() => SubmissionBodyState();
}
