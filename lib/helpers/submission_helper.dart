class SubmissionHelper {
  static String getImageUrl(submission) {
    String imageUrl = "";
    if (submission.isSelf) return imageUrl;

    if (submission.variants.length > 0) {
      var gifVariant = submission.variants
          .firstWhere((x) => x['gif'] != null)
          .values
          .toList()[0];
      if (gifVariant != null) {
        imageUrl = gifVariant.source.url.toString();
      } else {
        var mp4Variant = submission.variants
          .firstWhere((x) => x['mp4'] != null)
          .values
          .toList()[0];
          if (mp4Variant != null) {
            imageUrl = mp4Variant;
          }
      }
    } else if (submission.url.toString().contains('.jpg') ||
        submission.url.toString().contains('.jpeg') ||
        submission.url.toString().contains('.png') ||
        submission.url.toString().contains('.gif') ||
        submission.url.toString().contains('.webm')) {
      imageUrl = submission.url.toString();
    } else if (submission.preview.length > 0) {
      imageUrl = submission.preview[0].source.url.toString();
    }

    imageUrl = imageUrl.replaceAll('amp;', '').replaceAll('.gifv', '.mp4');
    return imageUrl;
  }
}