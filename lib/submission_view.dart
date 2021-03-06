import 'package:flutter/material.dart';
import 'package:draw/draw.dart' as Dart;
import 'package:html_unescape/html_unescape.dart';
import 'package:lurkers_for_reddit/helpers/post_type_helper.dart';
import 'package:lurkers_for_reddit/helpers/submission_helper.dart';
import 'package:lurkers_for_reddit/helpers/subreddit_helper.dart';
import 'package:lurkers_for_reddit/main.dart';
import 'package:lurkers_for_reddit/post_photo_view.dart';
import 'package:lurkers_for_reddit/submission_comments.dart';
import 'package:lurkers_for_reddit/transparent_route.dart';
import 'package:lurkers_for_reddit/video_viewer.dart';
import 'package:lurkers_for_reddit/youtube_viewer.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:lurkers_for_reddit/helpers/time_converter.dart';

import 'package:lurkers_for_reddit/helpers/text_helper.dart';

class _SubmissionViewState extends State<SubmissionView>
    with TickerProviderStateMixin {
  Color _upvoteColor = _defaultNonevoteColor;
  Color _downvoteColor = _defaultNonevoteColor;
  int _score;
  AnimationController _animationController;
  Animation<Offset> _offsetFloat;

  static Color _defaultUpvoteColor = Colors.orange;
  static Color _defaultDownvoteColor = Colors.blue;
  static Color _defaultNonevoteColor = Colors.white;

  @override
  void initState() {
    if (widget.submission.vote == Dart.VoteState.downvoted) {
      _downvoteColor = _defaultDownvoteColor;
    } else if (widget.submission.vote == Dart.VoteState.upvoted) {
      _upvoteColor = _defaultUpvoteColor;
    }

    _score = widget.submission.score ?? 0;
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _offsetFloat = Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0))
        .animate(_animationController);

    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    if (_animationController != null) _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var thumb = widget.submission.thumbnail;
    bool showThumbnail = thumb != null && thumb.scheme.startsWith('http');
    var unescape = HtmlUnescape();
    return IntrinsicHeight(
      child: SlideTransition(
        position: _offsetFloat,
        child: InkWell(
          onLongPress: () {
            if (redditSession.user == null) {
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(new SnackBar(
                content: Text("You must be logged in to do that!"),
              ));
            } else if (!widget.submission.saved) {
              widget.submission.save().then((x) {
                widget.submission.refresh().then((y) {
                  setState(() {});
                  Scaffold.of(context).hideCurrentSnackBar();
                  Scaffold.of(context).showSnackBar(new SnackBar(
                    content: Text("Post saved succesfully"),
                  ));
                });
              });
            } else {
              widget.submission.unsave().then((x) {
                widget.submission.refresh().then((y) {
                  setState(() {});
                  Scaffold.of(context).hideCurrentSnackBar();
                  Scaffold.of(context).showSnackBar(new SnackBar(
                    content: Text("Post unsaved succesfully"),
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
                      subreddit: widget.subreddit,
                      subreddits: widget.subreddits,
                    ),
              ),
            );
          },
          child: Dismissible(
            confirmDismiss: (d) {
              if (redditSession.user == null) {
                Scaffold.of(context).hideCurrentSnackBar();
                Scaffold.of(context).showSnackBar(new SnackBar(
                  content: Text("You must be logged in to do that!"),
                ));
                return Future.value(false);
              }
              return Future.value(true);
            },
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              if (direction == DismissDirection.endToStart) {
                var sub = widget.submission;
                widget.submission.hide().then((x) {
                  widget.onHide(sub);
                  setState(() {
                    Scaffold.of(context).showSnackBar(new SnackBar(
                      duration: Duration(seconds: 6),
                      content: Text("Post hidden succesfully"),
                      action: SnackBarAction(
                        label: "Undo",
                        onPressed: () {
                          sub.unhide().then((y) {
                            widget.onHideUndo(sub, widget.index);
                          });
                        },
                      ),
                    ));
                  });
                });
              }
            },
            key: Key(widget.submission.id),
            child: Card(
              color: SubredditHelper.getSubColor(
                  widget.subreddits.firstWhere(
                      (x) =>
                          (x.runtimeType == Dart.Subreddit
                              ? x.displayName
                              : x) ==
                          widget.submission.subreddit.displayName,
                      orElse: () => ""),
                  defaultColor: Theme.of(context).cardColor,
                  opacity: 0.3),
              margin: EdgeInsets.all(7),
              child: Padding(
                padding: EdgeInsets.all(3.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: showThumbnail ? 4 : 0,
                      child: Container(
                        padding: EdgeInsets.only(right: 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Visibility(
                              visible: showThumbnail,
                              child: InkWell(
                                onTap: () {
                                  Widget overlay;
                                  var type = PostTypeHelper.getPostType(
                                      widget.submission);
                                  if (type == PostType.Pic) {
                                    overlay = PostPhotoView(
                                      url: SubmissionHelper.getImageUrl(
                                          widget.submission),
                                    );
                                  } else if (type == PostType.Vid) {
                                    overlay = VideoViewer(
                                        url: widget.submission.url.toString());
                                  } else if (type == PostType.YouTube) {
                                    overlay = Center(
                                      child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Material(
                                          child: YoutubeViewer(
                                            url: widget.submission.url
                                                .toString(),
                                            autoplay: true,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else if (type == PostType.Web) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SubmissionComments(
                                              submission: widget.submission,
                                              subreddit: widget.subreddit,
                                              subreddits: widget.subreddits,
                                            ),
                                      ),
                                    );
                                  }
                                  Navigator.push(
                                    context,
                                    TransparentRoute(
                                        builder: (context) => overlay),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey)),
                                  child: FadeInImage.memoryNetwork(
                                    height: 80.0,
                                    width: 80.0,
                                    placeholder: kTransparentImage,
                                    image: thumb.toString(),
                                    fit: BoxFit.cover,
                                  ),
                                ),
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
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                        text: unescape
                                            .convert(widget.submission.title),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline
                                            .copyWith(fontSize: 15.0),
                                      ),
                                      TextSpan(text: "  "),
                                      TextSpan(
                                          text: widget.submission
                                                      .linkFlairText !=
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
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Visibility(
                                visible: widget.submission.saved,
                                child: Icon(
                                  Icons.star,
                                  size: 10.0,
                                  color: Colors.yellow,
                                ),
                              ),
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
                              Flexible(
                                child: Text(
                                  widget.submission.domain,
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(fontSize: 10.0),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
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
                              color: _upvoteColor,
                              size: 24.0,
                            ),
                            onPressed: () {
                              if (redditSession.user == null) {
                                Scaffold.of(context).hideCurrentSnackBar();
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content:
                                      Text("You must be logged in to do that!"),
                                ));
                                return;
                              }
                              if (widget.submission.vote ==
                                  Dart.VoteState.upvoted) {
                                widget.submission.clearVote().then((x) {
                                  setState(() {
                                    _upvoteColor = _defaultNonevoteColor;
                                    _downvoteColor = _defaultNonevoteColor;
                                    _score--;
                                  });
                                }).catchError((e) {
                                  Scaffold.of(context).hideCurrentSnackBar();
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                      content: Text(
                                          "Vote failed. You're doing that too fast!")));
                                });
                              } else {
                                widget.submission.upvote().then((x) {
                                  setState(() {
                                    _upvoteColor = _defaultUpvoteColor;
                                    _downvoteColor = _defaultNonevoteColor;
                                    _score++;
                                  });
                                }).catchError((e) {
                                  Scaffold.of(context).hideCurrentSnackBar();
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                      content: Text(
                                          "Vote failed. You're doing that too fast!")));
                                });
                              }
                            },
                          ),
                          Text(
                            "${TextHelper.convertScoreToAbbreviated(_score)}",
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
                              color: _downvoteColor,
                              size: 24.0,
                            ),
                            onPressed: () {
                              if (redditSession.user == null) {
                                Scaffold.of(context).hideCurrentSnackBar();
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content:
                                      Text("You must be logged in to do that!"),
                                ));
                                return;
                              }
                              if (widget.submission.vote ==
                                  Dart.VoteState.downvoted) {
                                widget.submission.clearVote().then((x) {
                                  setState(() {
                                    _upvoteColor = _defaultNonevoteColor;
                                    _downvoteColor = _defaultNonevoteColor;
                                    _score++;
                                  });
                                }).catchError((e) {
                                  Scaffold.of(context).hideCurrentSnackBar();
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                      content: Text(
                                          "Vote failed. You're doing that too fast!")));
                                });
                              } else {
                                widget.submission.downvote().then((x) {
                                  setState(() {
                                    _upvoteColor = _defaultNonevoteColor;
                                    _downvoteColor = _defaultDownvoteColor;
                                    _score--;
                                  });
                                }).catchError((e) {
                                  Scaffold.of(context).hideCurrentSnackBar();
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                      content: Text(
                                          "Vote failed. You're doing that too fast!")));
                                });
                              }
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
      ),
    );
  }
}

class SubmissionView extends StatefulWidget {
  SubmissionView(
      {Key key,
      this.submission,
      this.onHide,
      this.onHideUndo,
      this.index,
      this.subreddit,
      this.subreddits})
      : super(key: key);

  final Dart.Submission submission;
  final Function onHide;
  final Function onHideUndo;
  final int index;
  final dynamic subreddit;
  final List<dynamic> subreddits;

  @override
  _SubmissionViewState createState() => _SubmissionViewState();
}
