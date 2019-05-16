import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:url_launcher/url_launcher.dart';

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
    } else if (widget.submission.preview.length > 0) {
      imageUrl = widget.submission.preview[0].source.url.toString();
    } else {
      imageUrl = widget.submission.url.toString();
    }

    imageUrl = imageUrl.replaceAll('amp;', '');
    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    var url = getImageUrl();
    String postUrl = widget.submission.url.toString();
    print(url);
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height - 400,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: material.Visibility(
          visible: url.isNotEmpty,
          child: InkWell(
            onTap: () {
              _handleLink(postUrl);
            },
            child: Image.network(url, fit: BoxFit.cover),
          ),
          replacement: Container(),
        ),
      ),
    );
  }

  _handleLink(url) async {
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
