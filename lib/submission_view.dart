import 'package:flutter/material.dart';
import 'package:draw/draw.dart' as Dart;
import 'package:lurkers_for_reddit/submission_comments.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:lurkers_for_reddit/time_converter.dart';

class _SubmissionViewState extends State<SubmissionView> {
  Color upvoteColor = Colors.white;
  Color downvoteColor = Colors.white;
  @override
  Widget build(BuildContext context) {
    var thumb = widget.submission.thumbnail;
    bool showThumbnail = thumb != null && thumb.scheme.startsWith('http');
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
                          Expanded(
                            flex: 2,
                            child: Text(
                              "${widget.submission.subreddit.path}",
                              style: Theme.of(context).textTheme.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              TimeConverter.convertUtcToDiffString(
                                  widget.submission.createdUtc),
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "${widget.submission.numComments} cmts",
                              maxLines: 1,
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ),
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
                            color: upvoteColor,
                            size: 24.0,
                          ),
                          onPressed: () {
                            setState(() {
                              upvoteColor = Colors.orange;
                              downvoteColor = Colors.white;
                            });
                            widget.submission.downvote().then((x) {
                              print("upvoted");
                            });
                          },
                        ),
                        Text(
                          "${widget.submission.score}",
                          maxLines: 1,
                          style: Theme.of(context).textTheme.caption.copyWith(color: widget.submission.score > 0 ? Colors.orange : Colors.blue),
                        ),
                        IconButton(
                          iconSize: 3.0,
                          icon: Icon(
                            Icons.arrow_downward,
                            color: downvoteColor,
                            size: 24.0,
                          ),
                          onPressed: () {
                            setState(() {
                              upvoteColor = Colors.white;
                              downvoteColor = Colors.blue;
                            });
                            widget.submission.downvote().then((x) {
                              print("downvoted");
                            });
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
