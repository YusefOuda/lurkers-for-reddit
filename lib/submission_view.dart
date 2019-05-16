import 'package:flutter/material.dart';
import 'package:draw/draw.dart' as Dart;
import 'package:lurkers_for_reddit/submission_comments.dart';
import 'package:transparent_image/transparent_image.dart';

class _SubmissionViewState extends State<SubmissionView> {
  @override
  Widget build(BuildContext context) {
    var thumb = widget.submission.thumbnail;
    bool showThumbnail =
        thumb != null && thumb.scheme.startsWith('http');
    return IntrinsicHeight(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubmissionComments(
                    submission: widget.submission,
                  ),
            ),
          );
        },
        child: Card(
          margin: EdgeInsets.all(7),
          child: Padding(
            padding: EdgeInsets.all(3.0),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Visibility(
                      visible: showThumbnail,
                      child: FadeInImage.memoryNetwork(
                        height: 70.0,
                        width: 70.0,
                        placeholder: kTransparentImage,
                        image: thumb.toString(),
                        fit: BoxFit.cover,
                      ),
                      replacement: Container(
                        height: 70.0,
                        width: 70.0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/placeholder.png'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Spacer(
                  flex: 1,
                ),
                Expanded(
                  flex: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text(widget.submission.title),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "${widget.submission.subreddit.path}",
                            style: Theme.of(context).textTheme.caption,
                          ),
                          Text("${widget.submission.numComments} comments")
                        ],
                      ),
                    ],
                  ),
                ),
                Spacer(
                  flex: 1,
                ),
                Expanded(
                    child: Column(
                      children: <Widget>[
                        IconButton(
                          iconSize: 3.0,
                          icon: Icon(
                            Icons.arrow_upward,
                            color: Colors.black,
                            size: 24.0,
                          ),
                          onPressed: () {
                            print("UPVOTED");
                          },
                        ),
                        IconButton(
                          iconSize: 3.0,
                          icon: Icon(
                            Icons.arrow_downward,
                            color: Colors.black,
                            size: 24.0,
                          ),
                          onPressed: () {
                            print("DOWNVOTED");
                          },
                        ),
                      ],
                    ),
                    flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SubmissionView extends StatefulWidget {
  SubmissionView({Key key, this.submission}) : super(key: key);

  final Dart.Submission submission;

  @override
  _SubmissionViewState createState() => _SubmissionViewState();
}
