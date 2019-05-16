import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:lurkers_for_reddit/main.dart';
import 'package:lurkers_for_reddit/submission_view.dart';

import 'main.dart';

class SubmissionListState extends State<SubmissionList> {
  List<RedditBase> _submissions = List<RedditBase>();
  ScrollController controller;
  String _sub;
  String _after = '';
  String _sort = '';
  bool _loading = false;

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

  void getMoreSubmissions(
      {limit = '20', sort = 'hot', sub = 'frontpage', after = ''}) async {
    var params = <String, String>{};
    params['limit'] = limit;
    params['after'] = after;
    var subString = sub == "frontpage" ? "" : "/r/$sub";
    _loading = true;
    redditSession.reddit.get("$subString/$sort", params: params).then((result) {
      var x = List<Submission>.from(result['listing']);
      x.removeWhere((s) => s.over18);
      setState(() {
        _submissions.addAll(x);
      });
      _after = result['after'];
      _loading = false;
    });
  }

  void newSubSelected(sub) {
    _sub = sub;
    setState(() {
      _submissions.clear();
    });
    _after = '';
    getMoreSubmissions(sub: _sub, after: _after, sort: _sort);
  }

  void newSortSelected(sort) {
    _sort = sort;
    setState(() {
      _submissions.clear();
    });
    _after = '';
    getMoreSubmissions(sub: _sub, after: _after, sort: _sort);
  }

  Future<Null> _handleRefresh() async {
    setState(() {
      _submissions.clear();
    });
    _after = '';
    getMoreSubmissions(sub: _sub, after: _after, sort: _sort);

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: prefix0.Visibility(
        visible: !_loading,
        replacement: Center(
          child: CircularProgressIndicator(),
        ),
        child: ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          controller: controller,
          itemCount: _submissions.length,
          itemBuilder: (context, index) {
            final post = _submissions[index];
            return SubmissionView(
              submission: post,
            );
          },
        ),
      ),
    );
  }
}

class SubmissionList extends StatefulWidget {
  SubmissionList({Key key, this.sub}) : super(key: key);

  final String sub;

  @override
  SubmissionListState createState() => SubmissionListState();
}
