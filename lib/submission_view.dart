import 'package:flutter/material.dart';
import 'package:draw/draw.dart' as Dart;
import 'package:lurkers_for_reddit/submission_comments.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:lurkers_for_reddit/time_converter.dart';

class _SubmissionViewState extends State<SubmissionView> {
  Color upvoteColor = Colors.white;
  Color downvoteColor = Colors.white;
  Icon _saveIcon = Icon(Icons.star_border);
  @override
  Widget build(BuildContext context) {
    var thumb = widget.submission.thumbnail;
    bool showThumbnail = thumb != null && thumb.scheme.startsWith('http');
    if (widget.submission.saved) {
      _saveIcon = Icon(Icons.star);
    } else {
      _saveIcon = Icon(Icons.star_border);
    }
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
                          color: Colors.blueGrey.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Expanded(
                    flex: 15,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(right: 10.0),
                              child: Text(
                                widget.submission.subreddit.path,
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              '/u/' + widget.submission.author,
                              style: Theme.of(context).textTheme.caption,
                            ),
                            Flexible(
                              child: Padding(
                                padding: EdgeInsets.only(left: 10.0),
                                child: Text(
                                  widget.submission.domain,
                                  style: Theme.of(context).textTheme.caption,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(widget.submission.title),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(right: 10.0),
                              child: Text(
                                TimeConverter.convertUtcToDiffString(
                                    widget.submission.createdUtc),
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 10.0),
                              child: Text(
                                "${widget.submission.numComments} comments",
                                maxLines: 1,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),
                            IconButton(
                                icon: _saveIcon,
                                onPressed: () {
                                  if (!widget.submission.saved) {
                                    widget.submission.save().then((x) {
                                      widget.submission.refresh().then((y) {
                                        setState(() {
                                          _saveIcon = Icon(Icons.star);
                                        });
                                        Scaffold.of(context)
                                            .hideCurrentSnackBar();
                                        Scaffold.of(context)
                                            .showSnackBar(new SnackBar(
                                          content: new Text(
                                              "Post saved succesfully"),
                                        ));
                                      });
                                    });
                                  } else {
                                    widget.submission.unsave().then((x) {
                                      widget.submission.refresh().then((y) {
                                        setState(() {
                                          _saveIcon = Icon(Icons.star_border);
                                        });
                                        Scaffold.of(context)
                                            .hideCurrentSnackBar();
                                        Scaffold.of(context)
                                            .showSnackBar(new SnackBar(
                                          content: new Text(
                                              "Post unsaved succesfully"),
                                        ));
                                      });
                                    });
                                  }
                                }),
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
                            style: Theme.of(context).textTheme.caption.copyWith(
                                color: widget.submission.score > 0
                                    ? Colors.orange
                                    : Colors.blue),
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
