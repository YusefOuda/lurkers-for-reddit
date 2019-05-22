import 'package:draw/draw.dart';

enum PostType { Pic, Vid, Web, YouTube, Self }

class PostTypeHelper {
  static getPostType(Submission submission) {
    String postUrl = submission.url.toString();
    if (postUrl.contains('v.redd.it') ||
        postUrl.contains('streamable') ||
        postUrl.contains('gfycat')) {
      return PostType.Vid;
    } else if (postUrl.contains('youtube') || postUrl.contains('youtu.be')) {
      return PostType.YouTube;
    } else if (postUrl.isNotEmpty &&
        (postUrl.contains('.mp4') ||
            postUrl.contains('.gif') ||
            postUrl.contains('.jpg') ||
            postUrl.contains('.jpeg') ||
            postUrl.contains('.png'))) {
      return PostType.Pic;
    } else if (submission.isSelf) {
      return PostType.Self;
    } else {
      return PostType.Web;
    }
  }
}
