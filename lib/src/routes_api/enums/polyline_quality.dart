/// Quality levels for polyline encoding in the Routes API
/// Higher quality provides more detailed route geometry
enum PolylineQuality {
  /// High-quality polyline with detailed geometry
  /// Recommended for precise route visualization
  highQuality('HIGH_QUALITY'),
  
  /// Overview polyline with simplified geometry
  /// Suitable for route overviews and reduced data usage
  overview('OVERVIEW');

  const PolylineQuality(this.value);
  
  /// The string value used in API requests
  final String value;
  
  /// Convert from string value to enum
  static PolylineQuality? fromString(String value) {
    for (PolylineQuality quality in PolylineQuality.values) {
      if (quality.value == value) {
        return quality;
      }
    }
    return null;
  }
  
  /// Get a description of the polyline quality
  String get description {
    switch (this) {
      case PolylineQuality.highQuality:
        return 'Detailed polyline with high precision for accurate route visualization';
      case PolylineQuality.overview:
        return 'Simplified polyline for route overview with reduced data usage';
    }
  }
  
  /// Recommended use case for this quality level
  String get useCase {
    switch (this) {
      case PolylineQuality.highQuality:
        return 'Turn-by-turn navigation, detailed route display';
      case PolylineQuality.overview:
        return 'Route overview, list views, reduced bandwidth scenarios';
    }
  }
}