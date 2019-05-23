import 'package:draw/draw.dart';

enum PostType { Pic, Vid, Web, YouTube, Self }

class PostTypeHelper {
  static getPostType(Submission submission) {
    Uri postUrl = submission.url;
    if (postUrl.host.contains('v.redd.it') ||
        postUrl.host.contains('streamable') ||
        postUrl.host.contains('gfycat')) {
      return PostType.Vid;
    } else if (postUrl.host.contains('youtube') || postUrl.host.contains('youtu.be')) {
      return PostType.YouTube;
    } else if (postUrl.toString().isNotEmpty &&
        (postUrl.toString().contains('.mp4') ||
            postUrl.toString().contains('.gif') ||
            postUrl.toString().contains('.jpg') ||
            postUrl.toString().contains('.jpeg') ||
            postUrl.toString().contains('.png'))) {
      return PostType.Pic;
    } else if (submission.isSelf) {
      return PostType.Self;
    } else {
      return PostType.Web;
    }
  }
}
