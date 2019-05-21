import 'package:draw/draw.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:lurkers_for_reddit/main.dart';
import 'package:lurkers_for_reddit/submission_view.dart';

import 'main.dart';

class SubmissionListState extends State<SubmissionList> {
  List<RedditBase> _submissions = List<RedditBase>();
  ScrollController controller;
  dynamic _sub;
  String _after = '';
  String _sort = '';
  bool _loading = false;
  String _headerImage = '';

  @override
  void initState() {
    super.initState();
    _sub = widget.sub;
    _headerImage = widget.sub.runtimeType == Subreddit &&
            widget.sub.data['banner_img'] != null
        ? widget.sub.data['banner_img']
        : '';
    controller = ScrollController()..addListener(_scrollListener);
    getMoreSubmissions(sub: _sub, after: _after, sort: _sort);
  }

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(_scrollListener);
  }

  void _scrollListener() {
    if (controller.position.pixels + controller.position.viewportDimension >
            controller.position.maxScrollExtent &&
        !_loading) {
      getMoreSubmissions(sub: _sub, after: _after, sort: _sort);
    }
  }

  void getMoreSubmissions(
      {limit = '20', sort = 'hot', sub = 'frontpage', after = ''}) async {
    var params = <String, String>{};
    params['limit'] = limit;
    params['after'] = after;
    var subName = sub.runtimeType == Subreddit ? sub.displayName : sub;
    var subString = subName == "frontpage" ? "" : "/r/$subName";
    _loading = true;
    redditSession.reddit.get("$subString/$sort", params: params).then((result) {
      var x = List<Submission>.from(result['listing']);
      x.removeWhere((s) => s.over18);
      setState(() {
        _submissions.addAll(x);
      });
      _after = result['after'];
      _loading = false;
    }).catchError((e) {
      print("couldn't get submissions");
      setState(() {
        _loading = false;
        _submissions.clear();
      });
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text("Could not load submissions"),
      ));
    });
  }

  void newSubSelected(sub) {
    _sub = sub;
    _headerImage =
        _sub.runtimeType == Subreddit && _sub.data['banner_img'] != null
            ? _sub.data['banner_img']
            : '';
    print(_headerImage);
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

  _onHide(sub) {
    setState(() {
      _submissions.remove(sub);
    });
  }

  _onHideUndo(sub, index) {
    setState(() {
      _submissions.insert(index, sub);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: NestedScrollView(
          controller: controller,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            var showHeader = _headerImage != null && _headerImage.isNotEmpty;
            var children = <Widget>[];
            if (showHeader) {
              children.add(
                SliverAppBar(
                  expandedHeight: 150.0,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: Image.network(
                      _headerImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            }
            children.add(
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final post = _submissions[index];
                  return SubmissionView(
                    submission: post,
                    index: index,
                    onHide: _onHide,
                    onHideUndo: _onHideUndo,
                  );
                }, childCount: _submissions.length),
              ),
            );
            return children;
          },
          body: Container(),
        ),
      ),
    );
  }
}

class SubmissionList extends StatefulWidget {
  SubmissionList({Key key, this.sub}) : super(key: key);

  final dynamic sub;

  @override
  SubmissionListState createState() => SubmissionListState();
}
