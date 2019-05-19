class TextHelper {
  static String convertScoreToAbbreviated(int score) {
    if (score < 1000) {
      return score.toString();
    } else if (score < 10000) {
      return (score / 1000).toStringAsFixed(1) + 'k';
    } else if (score < 1000000) {
      return (score / 10000).toStringAsFixed(1) + 'k';
    } else if (score < 100000000) {
      return (score / 1000000).toStringAsFixed(1) + 'm';
    }
    return score.toString();
  }
}