import "dart:async";
import "package:draw/draw.dart";
import "package:oauth2/oauth2.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:url_launcher/url_launcher.dart";
import "package:quiver/strings.dart";
import 'package:device_info/device_info.dart';

class RedditSession {
  static final _userCredKey = "userCreds";
  static final _clientId = "iC80jTVJZ9URdA";
  static final _clientSecret = "";
  static final _userAgent = "Lurkers-for-Reddit by /u/lurkers-for-reddit";
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

  Future<List<Subreddit>> getSubreddits() async {
    List<Subreddit> subs = List<Subreddit>();
    await for (final sub in reddit.user.subreddits(limit: 99999)) subs.add(sub);
    return subs;
  }

  Future<List<String>> getSubredditsDisplayNames() async {
    var sp = await SharedPreferences.getInstance();
    var subs = sp.getStringList('subreddits');
    bool newSubs = false;
    if (subs == null) {
      subs = List<String>();
      newSubs = true;
    }
    if (user != null) {
      await for (final sub in reddit.user.subreddits(limit: 99999)) {
        if (!subs.contains(sub.displayName))
          subs.add(sub.displayName);
      }
    }
    if (!subs.contains('popular'))
      subs.insert(0, "popular");
    if (!subs.contains('all'))
      subs.insert(0, "all");
    if (!subs.contains('frontpage'))
      subs.insert(0, "frontpage");

    if (newSubs)
      subs.sort((a,b) => a.toLowerCase().compareTo(b.toLowerCase()));

    saveSubreddits(subs);
    return subs;
  }

  saveSubreddits(subs) async {
    var sp = await SharedPreferences.getInstance();
    sp.setStringList('subreddits', subs);
  }

  static final RedditSession instance = RedditSession._privateConstructor();
}
