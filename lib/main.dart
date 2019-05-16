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
  String _currentSub = 'frontpage';
  String _currentSort = 'hot';
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

  void getSubreddits() {
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
                  print(newValue);
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
                          Expanded(child: Text(subName),),
                          IconButton(
                            icon: Icon(Icons.star_border),
                            onPressed: () {
                              _handleSubFavorite(subName);
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

  _handleSubFavorite(subName) {
    print("favorited " + subName);
  }
}
