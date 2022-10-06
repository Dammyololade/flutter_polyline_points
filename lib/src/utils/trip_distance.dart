/// A pair of text and meters.
class TripDistance {
  const TripDistance(String text, int meters)
      : this.text = text,
        this.meters = meters;

  /// Distance in text. The text key in distance that's returned from the Distance API
  final String text;

  /// Distance in meters. The value key in distance that's returned from the Distance API
  final int meters;

  @override
  String toString() {
    return "text: $text/ seconds: $meters";
  }
}
