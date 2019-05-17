import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'redditsession.dart';
import 'package:uni_links/uni_links.dart';
import 'package:lurkers_for_reddit/submission_list.dart';
import 'package:toast/toast.dart';

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
  String _userNameText = redditSession?.user?.displayName ?? "";
  List<String> _subreddits = List<String>();
  List<String> _favorites = List<String>();
  String _currentSub = 'frontpage';
  String _currentSort = 'hot';
  bool _viewingUserEnteredSub = false;
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

  void getSubreddits() async {
    await _getFavorites();
    _subreddits.clear();
    redditSession.getSubredditsDisplayNames().then((subs) {
      setState(() {
        _subreddits.addAll(subs);
        _sortSubreddits();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        mini: false,
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(title: FormField(
                  builder: (FormFieldState state) {
                    return Column(
                      children: <Widget>[
                        Text("Enter a subreddit..."),
                        TextField(
                          autofocus: true,
                          onSubmitted: (value) {
                            setState(() {
                              if (_viewingUserEnteredSub) {
                                _subreddits.removeAt(0);
                              }
                              if (!_subreddits.contains(value)) {
                                _viewingUserEnteredSub = true;
                                _subreddits.insert(0, value);
                              }

                              Navigator.pop(context);
                              _currentSub = value;
                              globalKey.currentState
                                  .newSubSelected(_currentSub);
                            });
                          },
                        )
                      ],
                    );
                  },
                ));
              });
        },
      ),
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
        title: _subreddits.length > 0
            ? DropdownButton<String>(
                isExpanded: true,
                value: _currentSub,
                onChanged: (String newValue) {
                  if (newValue == _currentSub) return;
                  if (_viewingUserEnteredSub) {
                    _subreddits.removeAt(0);
                  }
                  _viewingUserEnteredSub = false;
                  setState(() {
                    _currentSub = newValue;
                    globalKey.currentState.newSubSelected(_currentSub);
                  });
                },
                items: _subreddits.map<DropdownMenuItem<String>>(
                  (String subName) {
                    return DropdownMenuItem<String>(
                      value: subName,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Text(subName),
                          ),
                          IconButton(
                            icon: Visibility(
                              visible: !_favorites.contains(subName),
                              child: Icon(Icons.star_border),
                              replacement: Icon(Icons.star),
                            ),
                            onPressed: () {
                              var didFavorite = _handleSubFavorite(subName);
                              _sortSubreddits();
                              //Navigator.pop(context);
                              Toast.show(
                                  didFavorite
                                      ? "Added $subName to favorites"
                                      : "Removed $subName from favorites",
                                  context,
                                  duration: Toast.LENGTH_SHORT,
                                  gravity: Toast.CENTER);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ).toList(),
              )
            : Text('Loading subs...'),
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

  _sortSubreddits() {
    _subreddits.sort((a,b) => a.toLowerCase().compareTo(b.toLowerCase()));
    _favorites.sort((a,b) => a.toLowerCase().compareTo(b.toLowerCase()));
    _subreddits.insert(0, 'popular');
    var index = _subreddits.lastIndexWhere((x) => x == 'popular');
    _subreddits.removeAt(index);
    _subreddits.insert(0, 'all');
    index = _subreddits.lastIndexWhere((x) => x == 'all');
    _subreddits.removeAt(index);
    _subreddits.insert(0, 'frontpage');
    index = _subreddits.lastIndexWhere((x) => x == 'frontpage');
    _subreddits.removeAt(index);
    _subreddits.forEach((s) {
      if (_favorites.contains(s)) {
        _subreddits.insert(0, s);
        var index = _subreddits.lastIndexWhere((x) => x == s);
        _subreddits.removeAt(index);
      }
    });
  }

  _getFavorites() async {
    var sp = await SharedPreferences.getInstance();
    var favs = sp.getStringList('favorite_subreddits');
    if (favs != null)
      _favorites = favs;
    _favorites.sort((a,b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  _saveFavorites() async {
    var sp = await SharedPreferences.getInstance();
    sp.setStringList('favorite_subreddits', _favorites);
  }

  _handleSubFavorite(subName) {
    var didFavorite = false;
    setState(() {
      if (_favorites.contains(subName)) {
        _favorites.remove(subName);
      } else {
        _favorites.add(subName);
        didFavorite = true;
      }
    });
    _favorites.sort((a,b) => a.toLowerCase().compareTo(b.toLowerCase()));
    _saveFavorites();
    return didFavorite;
  }
}
