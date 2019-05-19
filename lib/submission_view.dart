import 'package:flutter/material.dart';
import 'package:draw/draw.dart' as Dart;
import 'package:lurkers_for_reddit/submission_comments.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:lurkers_for_reddit/helpers/time_converter.dart';

import 'package:lurkers_for_reddit/helpers/text_helper.dart';

class _SubmissionViewState extends State<SubmissionView> {
  Color upvoteColor = Colors.white;
  Color downvoteColor = Colors.white;
  @override
  Widget build(BuildContext context) {
    var thumb = widget.submission.thumbnail;
    bool showThumbnail = thumb != null && thumb.scheme.startsWith('http');
    return IntrinsicHeight(
      child: InkWell(
        onLongPress: () {
          if (!widget.submission.saved) {
            widget.submission.save().then((x) {
              widget.submission.refresh().then((y) {
                setState(() {});
                Scaffold.of(context).hideCurrentSnackBar();
                Scaffold.of(context).showSnackBar(new SnackBar(
                  content: new Text("Post saved succesfully"),
                ));
              });
            });
          } else {
            widget.submission.unsave().then((x) {
              widget.submission.refresh().then((y) {
                setState(() {});
                Scaffold.of(context).hideCurrentSnackBar();
                Scaffold.of(context).showSnackBar(new SnackBar(
                  content: new Text("Post unsaved succesfully"),
                ));
              });
            });
          }
        },
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
        child: Dismissible(
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              widget.submission.hide().then((x) {
                widget.onHide(widget.submission);
                setState(() {
                  Scaffold.of(context).showSnackBar(new SnackBar(
                    content: new Text("Post hidden succesfully"),
                  ));
                });
              });
            }
          },
          key: Key(widget.submission.id),
          child: Card(
            margin: EdgeInsets.all(7),
            child: Padding(
              padding: EdgeInsets.all(3.0),
              child: Row(
                children: [
                  Expanded(
                    flex: showThumbnail ? 3 : 0,
                    child: Container(
                      padding: EdgeInsets.only(right: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Visibility(
                            visible: showThumbnail,
                            child: FadeInImage.memoryNetwork(
                              height: 80.0,
                              width: 80.0,
                              placeholder: kTransparentImage,
                              image: thumb.toString(),
                              fit: BoxFit.cover,
                            ),
                            replacement: Container(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: showThumbnail ? 10 : 13,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                widget.submission.subreddit.path,
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10.0),
                              ),
                            ),
                            Text(
                              ' by /u/' + widget.submission.author,
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  .copyWith(fontSize: 10.0),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: RichText(
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: widget.submission.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline
                                          .copyWith(fontSize: 15.0),
                                    ),
                                    TextSpan(text: "  "),
                                    TextSpan(
                                        text: widget.submission.linkFlairText !=
                                                null
                                            ? widget.submission.linkFlairText
                                            : "",
                                        style: TextStyle(
                                            backgroundColor:
                                                Colors.blue.shade900,
                                            fontSize: 10.0)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              "${widget.submission.numComments} comments in ",
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  .copyWith(fontSize: 10.0),
                            ),
                            Text(
                              TimeConverter.convertUtcToDiffString(
                                  widget.submission.createdUtc),
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  .copyWith(fontSize: 10.0),
                            ),
                            Text("  •  "),
                            Text(
                              widget.submission.domain,
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  .copyWith(fontSize: 10.0),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          alignment: Alignment.center,
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
                          "${TextHelper.convertScoreToAbbreviated(widget.submission.score)}",
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.caption.copyWith(
                              color: widget.submission.score > 0
                                  ? Colors.orange
                                  : Colors.blue),
                        ),
                        IconButton(
                          alignment: Alignment.center,
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SubmissionView extends StatefulWidget {
  SubmissionView({Key key, this.submission, this.onHide}) : super(key: key);

  final Dart.Submission submission;
  final Function onHide;

  @override
  _SubmissionViewState createState() => _SubmissionViewState();
}
