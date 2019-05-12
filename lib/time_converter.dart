class TimeConverter {
  static String convertUtcToDiffString(DateTime utc) {
    var now = DateTime.now();
    var diff = now.difference(utc);
    if (diff.inSeconds < 60) {
      return "${diff.inSeconds} second${diff.inSeconds == 1 ? "" : "s"}";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes} minute${diff.inMinutes == 1 ? "" : "s"}";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} hour${diff.inHours == 1 ? "" : "s"}";
    } else {
      return "${diff.inDays} day${diff.inDays == 1 ? "" : "s"}";
    }
  }
}