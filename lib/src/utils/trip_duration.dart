/// A pair of text and seconds.
class TripDuration {
  const TripDuration(String text, int seconds)
      : this.text = text,
        this.seconds = seconds;

  /// Duration in text. The text key in duration that's returned from the Distance API
  final String text;

  /// Duration in seconds. The value key in duration that's returned from the Distance API
  final int seconds;

  @override
  String toString() {
    return "text: $text/ seconds: $seconds";
  }
}
