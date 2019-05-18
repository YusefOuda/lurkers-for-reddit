import 'package:flutter/material.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  PersistentBottomSheetController _sheetController;
  String _userNameText = redditSession?.user?.displayName ?? "";
  List<String> _subreddits = List<String>();
  String _currentSub = 'frontpage';
  String _currentSort = 'hot';
  bool _bottomSheetOpen = false;
  Icon _subredditNavIcon = Icon(Icons.keyboard_arrow_up);
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
  }

  _getReorderableSubs() {
    List<Widget> widgets = [];
    _subreddits.forEach((s) {
      var widget = Container(
        constraints: BoxConstraints(maxHeight: 50.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white),
          ),
        ),
        key: Key(s),
        child: InkWell(
          onTap: () {
            setState(() {
              _currentSub = s;
            });
            globalKey.currentState.newSubSelected(_currentSub);
            _sheetController.close();
          },
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 16,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(s),
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
                onSubmitted: (text) {
                  setState(() {
                    _currentSub = text;
                  });
                  globalKey.currentState.newSubSelected(_currentSub);
                  _sheetController.close();
                },
              ),
            ),
            Divider(height: 24.0, color: Colors.white),
            Expanded(
              child: ReorderableListView(
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
    redditSession.getSubredditsDisplayNames().then((subs) {
      setState(() {
        _subreddits.addAll(subs);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          if (index == 0) {
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
          } else if (index == 1) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Search..."),
                  content: TextField(
                    onSubmitted: (text) {
                      Navigator.pop(context);
                      print(text);
                    },
                  ),
                );
              },
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: _subredditNavIcon,
            title: Text('Subreddits'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text('Search'),
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
            children: <Widget>[
              _currentSub != null ? Text(_currentSub) : Text('Lurkr'),
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
      body: SubmissionList(key: globalKey, sub: _currentSub),
    );
  }
}
