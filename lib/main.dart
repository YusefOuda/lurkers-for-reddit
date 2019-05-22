import 'package:draw/draw.dart' as Dart;
import 'package:flutter/material.dart';
import 'package:lurkers_for_reddit/helpers/subreddit_helper.dart';
import 'package:lurkers_for_reddit/helpers/user_hint_helper.dart';
import 'package:transparent_image/transparent_image.dart';
import 'helpers/text_helper.dart';
import 'redditsession.dart';
import 'package:uni_links/uni_links.dart';
import 'package:lurkers_for_reddit/submission_list.dart';

var redditSession = RedditSession.instance;

void main() async {
  await redditSession.onReady();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lurkers for Reddit',
      theme: ThemeData(
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        }),
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

GlobalKey<SubmissionListState> globalKey = GlobalKey();

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PersistentBottomSheetController _sheetController;
  String _userNameText = redditSession?.user?.displayName ?? "";
  List<dynamic> _subreddits = List<dynamic>();
  dynamic _currentSub = 'frontpage';
  String _currentSort = 'hot';
  bool _bottomSheetOpen = false;
  Icon _subredditNavIcon = Icon(Icons.keyboard_arrow_up);
  Color _appBarColor;
  String _searchSubString = '';

  List<String> sorts = [
    "hot",
    "new",
    "rising",
    "controversial",
    "top",
  ];

  @override
  void initState() {
    super.initState();
    getSubreddits();
    _appBarColor = Colors.black12;
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => UserHintHelper.showHintsIfNecessary(_scaffoldKey));
  }

  _getReorderableSubs() {
    List<Widget> widgets = [];
    _subreddits.forEach((s) {
      String subName = s.runtimeType == Dart.Subreddit ? s.displayName : s;
      Dart.Subreddit sub;
      String iconImg;
      Color subColor = SubredditHelper.getSubColor(s);
      if (s.runtimeType == Dart.Subreddit) {
        sub = s as Dart.Subreddit;
        if (sub.data['icon_img'] != null) {
          iconImg = sub.data['icon_img'];
        }
      }
      var widget = Visibility(
        key: Key(subName),
        visible: _searchSubString.isEmpty ||
            subName.toLowerCase().contains(_searchSubString.toLowerCase()),
        child: Container(
          constraints: BoxConstraints(maxHeight: 50.0),
          decoration: BoxDecoration(
            color: subColor != null ? subColor : Colors.black,
            border: Border(
              bottom: BorderSide(color: Colors.white),
            ),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                _currentSub = sub != null ? sub : s;
                _appBarColor = SubredditHelper.getSubColor(sub);
              });
              globalKey.currentState.newSubSelected(_currentSub);
              _sheetController.close();
            },
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  sub != null && iconImg != null && iconImg.startsWith('http')
                      ? FadeInImage.memoryNetwork(
                          height: 30.0,
                          width: 30.0,
                          placeholder: kTransparentImage,
                          image: iconImg,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 30.0,
                          width: 30.0,
                          color: Colors.black.withOpacity(0),
                        ),
                  Flexible(
                    flex: 6,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 10.0,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          sub != null ? sub.displayName : s,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 4,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(sub != null
                          ? TextHelper.convertScoreToAbbreviated(
                                  sub.data['subscribers']) +
                              ' subs'
                          : ''),
                    ),
                  ),
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Icon(Icons.drag_handle),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      widgets.add(widget);
    });

    return widgets;
  }

  _bottomSheet() {
    var x =
        _scaffoldKey.currentState.showBottomSheet<Null>((BuildContext context) {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                left: 40.0,
                right: 40.0,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Enter a subreddit...',
                ),
                onChanged: (text) {
                  setState(() {
                    _sheetController.setState(() {
                      _searchSubString = text;
                    });
                  });
                },
                onSubmitted: (text) {
                  setState(() {
                    _sheetController.setState(() {
                      _currentSub = text;
                      _searchSubString = '';
                    });
                  });
                  globalKey.currentState.newSubSelected(_currentSub);
                  _sheetController.close();
                },
              ),
            ),
            Divider(height: 24.0, color: Colors.white),
            Flexible(
              child: _subreddits.length > 0
                  ? ReorderableListView(
                      onReorder: (oldIndex, newIndex) {
                        var sub = _subreddits[oldIndex];
                        _sheetController.setState(() {
                          _subreddits.removeAt(oldIndex);
                          if (newIndex > oldIndex) newIndex--;
                          _subreddits.insert(newIndex, sub);
                        });
                        if (redditSession.user != null)
                          redditSession.saveSubreddits(_subreddits);
                      },
                      children: _getReorderableSubs(),
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
            ),
          ],
        ),
      );
    });
    x.closed.then((y) {
      setState(() {
        _subredditNavIcon = Icon(Icons.keyboard_arrow_up);
        _bottomSheetOpen = false;
      });
    });
    return x;
  }

  void getSubreddits() async {
    _subreddits.clear();
    redditSession.getSubreddits().then((subs) {
      setState(() {
        _subreddits.addAll(subs);
        if (_sheetController != null) {
          _sheetController.setState(() {});
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Theme.of(context).colorScheme.onBackground,
        selectedFontSize: 12.0,
        selectedItemColor: Theme.of(context).colorScheme.onBackground,
        onTap: (index) {
          if (index == 1) {
            if (!_bottomSheetOpen) {
              _bottomSheetOpen = true;
              setState(() {
                _subredditNavIcon = Icon(Icons.keyboard_arrow_down);
              });
              _sheetController = _bottomSheet();
            } else {
              _sheetController.close();
              _sheetController = null;
            }
          } else if (index == 0) {
            globalKey.currentState.newSubSelected(_currentSub);
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.refresh),
            title: Text('Refresh'),
          ),
          BottomNavigationBarItem(
            icon: _subredditNavIcon,
            title: Text('Subreddits'),
          ),
        ],
      ),
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Center(
                child: Text(
                  'Lurkers for Reddit',
                  style: Theme.of(context)
                      .textTheme
                      .display1
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              decoration: BoxDecoration(color: Theme.of(context).accentColor),
            ),
            Visibility(
              visible: redditSession.user != null,
              child: ListTile(
                title: Text(this._userNameText),
                onTap: () {
                  print('Open settings');
                },
              ),
            ),
            Visibility(
              visible: redditSession.user == null,
              child: ListTile(
                title: Text('Login'),
                onTap: () {
                  redditSession.login().then((x) {
                    getUriLinksStream().listen((Uri uri) {
                      final code = uri.queryParameters['code'];
                      redditSession.onAuthCode(code).then((x) {
                        setState(() {
                          if (redditSession.user != null) {
                            this._userNameText =
                                redditSession?.user?.displayName ?? "";
                            this.getSubreddits();
                          }
                        });
                      });
                    });
                  });
                },
              ),
            ),
            Visibility(
              visible: redditSession.user != null,
              child: ListTile(
                title: Text('Logout'),
                onTap: () {
                  redditSession.logout().then((x) {
                    setState(() {
                      this._userNameText = "";
                      this.getSubreddits();
                    });
                  });
                },
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: _appBarColor,
        titleSpacing: 0.0,
        title: InkWell(
          onTap: () {
            if (!_bottomSheetOpen) {
              _bottomSheetOpen = true;
              setState(() {
                _subredditNavIcon = Icon(Icons.keyboard_arrow_down);
              });
              _sheetController = _bottomSheet();
            } else {
              _sheetController.close();
              _sheetController = null;
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              _currentSub != null
                  ? Flexible(
                      child: Text(_currentSub.runtimeType == Dart.Subreddit
                          ? _currentSub.displayName
                          : _currentSub),
                    )
                  : Text('Lurkers for reddit'),
            ],
          ),
        ),
        actions: <Widget>[
          DropdownButton<String>(
            value: _currentSort,
            onChanged: (String newValue) {
              setState(() {
                _currentSort = newValue;
                globalKey.currentState.newSortSelected(_currentSort);
              });
            },
            items: sorts.map<DropdownMenuItem<String>>(
              (String sort) {
                return DropdownMenuItem<String>(child: Text(sort), value: sort);
              },
            ).toList(),
          ),
        ],
      ),
      body: SubmissionList(
        key: globalKey,
        sub: _currentSub,
        subreddits: _subreddits,
      ),
    );
  }
}
