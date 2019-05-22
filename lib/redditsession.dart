import "dart:async";
import "package:draw/draw.dart";
import "package:oauth2/oauth2.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:url_launcher/url_launcher.dart";
import 'package:device_info/device_info.dart';

class RedditSession {
  static final _userCredKey = "userCreds";
  static final _clientId = "iC80jTVJZ9URdA";
  static final _clientSecret = "";
  static final _userAgent = "android:com.yusefouda.lurkers:v0.1.0 (by /u/lurkers-for-reddit)";
  static final _redirectUri = Uri.parse("comyusefoudalurkersforreddit://auth");
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  Reddit reddit;
  Redditor user;

  RedditSession._privateConstructor();

  Future<void> onReady() async {
    var sp = await SharedPreferences.getInstance();
    var userCredsString = sp.getString(_userCredKey);
    var androidInfo = await deviceInfo.androidInfo;
    var deviceId = androidInfo.androidId;
    if (userCredsString == null) {
      reddit = await Reddit.createUntrustedReadOnlyInstance(
          clientId: _clientId,
          userAgent: _userAgent,
          deviceId: "$deviceId$deviceId");
    } else {
      var creds = Credentials.fromJson(userCredsString).toJson();
      reddit = await Reddit.restoreAuthenticatedInstance(creds,
          clientId: _clientId,
          clientSecret: _clientSecret,
          userAgent: _userAgent,
          redirectUri: _redirectUri);
      user = await reddit.user.me();
    }
  }

  Future<void> login() async {
    reddit = Reddit.createWebFlowInstance(
        clientId: _clientId,
        clientSecret: _clientSecret,
        userAgent: _userAgent,
        redirectUri: _redirectUri);

    final authUrl = reddit.auth.url(["*"], _userAgent);
    await launch(authUrl.toString());
  }

  Future<void> logout() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.remove(_userCredKey);
    var androidInfo = await deviceInfo.androidInfo;
    var deviceId = androidInfo.androidId;
    reddit = await Reddit.createUntrustedReadOnlyInstance(
        clientId: _clientId, userAgent: _userAgent, deviceId: deviceId);
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
