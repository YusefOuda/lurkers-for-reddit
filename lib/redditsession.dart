import "dart:async";
import "package:draw/draw.dart";
import "package:oauth2/oauth2.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:url_launcher/url_launcher.dart";
import 'dart:js' as js;
import 'package:random_string/random_string.dart';

class RedditSession {
  static final _userCredKey = "userCreds";
  static final _deviceIdKey = "deviceId";
  static final _clientId = "Ld0WG1LTL9HZ_g";
  static final _userAgent =
      js.context['navigator']['userAgent'];
  static final _redirectUri = Uri.parse("https://lurkers.yusefouda.com/");
  static final Future<String> _deviceId = getDeviceId();

  static Future<String> getDeviceId() async {
    var sp = await SharedPreferences.getInstance();
    var deviceId = sp.getString(_deviceIdKey);
    if (deviceId == null || deviceId == "") {
      deviceId = randomAlpha(10);
      sp.setString(_deviceIdKey, deviceId);
    }
    return Future.value(deviceId);
  }


  Reddit reddit;
  Redditor user;

  RedditSession._privateConstructor();

  Future<void> onReady() async {
    var x = await _deviceId;
    print(x);
    var sp = await SharedPreferences.getInstance();
    var userCredsString = sp.getString(_userCredKey);
    if (userCredsString == null) {
      reddit = await Reddit.createUntrustedReadOnlyInstance(
          clientId: _clientId,
          userAgent: _userAgent,
          deviceId: "$x$x");
    } else {
      var creds = Credentials.fromJson(userCredsString).toJson();
      reddit = Reddit.restoreInstalledAuthenticatedInstance(creds,
          clientId: _clientId,
          userAgent: _userAgent,
          redirectUri: _redirectUri);
      user = await reddit.user.me();
    }
  }

  Future<void> login({shouldLaunch = true}) async {
    reddit = Reddit.createWebFlowInstance(
        clientId: _clientId,
        clientSecret: "",
        userAgent: _userAgent,
        redirectUri: _redirectUri
    );
    final authUrl = reddit.auth.url(["*"], _userAgent);
    if (shouldLaunch) {
      await launch(authUrl.toString());
    } else {
      await Future.value(true);
    }
  }

  Future<void> logout() async {
    var x = await _deviceId;
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.remove(_userCredKey);
    reddit = await Reddit.createUntrustedReadOnlyInstance(
        clientId: _clientId, userAgent: _userAgent, deviceId: x);
    user = null;
  }

  Future<void> onAuthCode(code) async {
    await reddit.auth.authorize(code);
    var sp = await SharedPreferences.getInstance();
    sp.setString(_userCredKey, reddit.auth.credentials.toJson());
    user = await reddit.user.me();
  }

  Future<List<dynamic>> getSubreddits() async {
    if (user == null) {
      var subs = List<dynamic>();
      subs.addAll(['popular', 'all', 'frontpage']);
      return subs;
    }

    List<dynamic> subs = List<dynamic>();
    List<String> subNameList;
    var sp = await SharedPreferences.getInstance();
    subNameList = sp.getStringList('subreddits');
    bool noSavedSubs = subNameList == null;

    await reddit.user.multireddits().then((list) {
      list.forEach((m) {
        subs.add("/m/${m.displayName}");
      });
    });

    await for (final sub in reddit.user.subreddits(limit: 99999)) {
      subs.add(sub);
    }

    if (noSavedSubs) {
      subNameList = List<String>();
      subs.sort((a, b) {
        String aName = a.runtimeType == Subreddit
            ? a.displayName.toLowerCase()
            : a.toLowerCase();
        String bName = b.runtimeType == Subreddit
            ? b.displayName.toLowerCase()
            : b.toLowerCase();
        return aName.compareTo(bName);
      });
      subs.insert(0, 'popular');
      subs.insert(0, 'all');
      subs.insert(0, 'frontpage');
      subs.forEach((s) {
        var name = s.runtimeType == Subreddit ? s.displayName : s;
        subNameList.add(name);
      });
    } else {
      List<dynamic> tempSubs = List<dynamic>();
      subs.insert(0, 'popular');
      subs.insert(0, 'all');
      subs.insert(0, 'frontpage');
      subNameList.forEach((s) {
        var sub = subs.firstWhere(
            (x) => (x.runtimeType == Subreddit ? x.displayName : x) == s);
        if (sub != null) {
          subs.remove(sub);
          tempSubs.add(sub);
        }
      });
      subs.forEach((s) {
        subNameList.add(s.runtimeType == Subreddit ? s.displayName : s);
        tempSubs.add(s);
      });
      subs = tempSubs;
    }

    saveSubreddits(subNameList);
    return subs;
  }

  saveSubreddits(subs) async {
    var sp = await SharedPreferences.getInstance();
    var subNameList = List<String>();
    subs.forEach((s) {
      subNameList.add(s.runtimeType == Subreddit ? s.displayName : s);
    });
    sp.setStringList('subreddits', subNameList);
  }

  static final RedditSession instance = RedditSession._privateConstructor();
}
