import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:lurkers_for_reddit/main.dart';
import 'package:lurkers_for_reddit/submission_view.dart';

import 'main.dart';

class SubmissionListState extends State<SubmissionList> {
  List<RedditBase> _submissions = List<RedditBase>();
  ScrollController controller;
  String _sub;
  String _after = '';
  String _sort = '';

  @override
  void initState() {
    super.initState();
    _sub = widget.sub;
    controller = ScrollController()..addListener(_scrollListener);
    getMoreSubmissions(sub: _sub, after: _after, sort: _sort);
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(_scrollListener);
  }

  void _scrollListener() {
    if (controller.position.atEdge) {
      getMoreSubmissions(sub: _sub, after: _after, sort: _sort);
    }
  }

  void getMoreSubmissions ({limit = '20', sort = 'hot', sub = 'frontpage', after = ''}) async {
    var params = <String, String>{};
    params['limit'] = limit;
    params['after'] = after;
    var subString = sub == "frontpage" ? "" : "/r/$sub";
    redditSession.reddit.get("$subString/$sort", params: params).then((result) {
      setState(() {
        _submissions.addAll(result['listing']?.cast<Submission>());
      });
      _after = result['after'];
    });

  }

  void newSubSelected(sub) {
    _sub = sub;
    _submissions.clear();
    _after = '';
    getMoreSubmissions(sub: _sub, after: _after, sort: _sort);
  }

  void newSortSelected(sort) {
    _sort = sort;
    _submissions.clear();
    _after = '';
    getMoreSubmissions(sub: _sub, after: _after, sort: _sort);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      itemCount: _submissions.length,
      itemBuilder: (context, index) {
        final post = _submissions[index];
        return SubmissionView(
          submission: post,
        );
      },
    );
  }
}

class SubmissionList extends StatefulWidget {
  SubmissionList({Key key, this.sub}) : super(key: key);

  final String sub;

  @override
  SubmissionListState createState() => SubmissionListState();
}
