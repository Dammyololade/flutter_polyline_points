/// Traffic information for routes from the Google Routes API
class TrafficInfo {
  /// Current traffic conditions along the route
  final TrafficCondition overallCondition;

  /// Detailed traffic segments with specific conditions
  final List<TrafficSegment>? segments;

  /// Traffic-aware duration in seconds
  final int? durationInTraffic;

  /// Traffic-aware duration as human-readable text
  final String? durationInTrafficText;

  /// Delay caused by traffic in seconds
  final int? trafficDelay;

  /// Last updated timestamp for traffic data
  final DateTime? lastUpdated;

  const TrafficInfo({
    required this.overallCondition,
    this.segments,
    this.durationInTraffic,
    this.durationInTrafficText,
    this.trafficDelay,
    this.lastUpdated,
  });

  /// Create from JSON response
  factory TrafficInfo.fromJson(Map<String, dynamic> json) {
    return TrafficInfo(
      overallCondition:
          TrafficCondition.fromString(json['overallCondition'] ?? 'UNKNOWN') ??
              TrafficCondition.unknown,
      segments: json['segments'] != null
          ? (json['segments'] as List)
              .map((segment) => TrafficSegment.fromJson(segment))
              .toList()
          : null,
      durationInTraffic: json['durationInTraffic'],
      durationInTrafficText: json['durationInTrafficText'],
      trafficDelay: json['trafficDelay'],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'overallCondition': overallCondition.value,
      if (segments != null)
        'segments': segments!.map((segment) => segment.toJson()).toList(),
      if (durationInTraffic != null) 'durationInTraffic': durationInTraffic,
      if (durationInTrafficText != null)
        'durationInTrafficText': durationInTrafficText,
      if (trafficDelay != null) 'trafficDelay': trafficDelay,
      if (lastUpdated != null) 'lastUpdated': lastUpdated!.toIso8601String(),
    };
  }

  /// Get traffic delay in minutes
  double? get trafficDelayMinutes {
    return trafficDelay != null ? trafficDelay! / 60.0 : null;
  }

  /// Check if traffic data is recent (within last 10 minutes)
  bool get isDataFresh {
    if (lastUpdated == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastUpdated!);
    return difference.inMinutes <= 10;
  }

  /// Get the most severe traffic condition from segments
  TrafficCondition get worstCondition {
    if (segments == null || segments!.isEmpty) return overallCondition;

    TrafficCondition worst = TrafficCondition.light;
    for (final segment in segments!) {
      if (segment.condition.severity > worst.severity) {
        worst = segment.condition;
      }
    }
    return worst;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrafficInfo &&
        other.overallCondition == overallCondition &&
        _listEquals(other.segments, segments) &&
        other.durationInTraffic == durationInTraffic &&
        other.durationInTrafficText == durationInTrafficText &&
        other.trafficDelay == trafficDelay &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return Object.hash(
      overallCondition,
      segments,
      durationInTraffic,
      durationInTrafficText,
      trafficDelay,
      lastUpdated,
    );
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}

/// Individual traffic segment information
class TrafficSegment {
  /// Traffic condition for this segment
  final TrafficCondition condition;

  /// Start index in the route polyline
  final int startPolylinePointIndex;

  /// End index in the route polyline
  final int endPolylinePointIndex;

  /// Length of this segment in meters
  final double? lengthMeters;

  /// Speed in this segment (km/h)
  final double? speedKmh;

  const TrafficSegment({
    required this.condition,
    required this.startPolylinePointIndex,
    required this.endPolylinePointIndex,
    this.lengthMeters,
    this.speedKmh,
  });

  /// Create from JSON response
  factory TrafficSegment.fromJson(Map<String, dynamic> json) {
    return TrafficSegment(
      condition: TrafficCondition.fromString(json['condition'] ?? 'UNKNOWN') ??
          TrafficCondition.unknown,
      startPolylinePointIndex: json['startPolylinePointIndex'] ?? 0,
      endPolylinePointIndex: json['endPolylinePointIndex'] ?? 0,
      lengthMeters: json['lengthMeters']?.toDouble(),
      speedKmh: json['speedKmh']?.toDouble(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'condition': condition.value,
      'startPolylinePointIndex': startPolylinePointIndex,
      'endPolylinePointIndex': endPolylinePointIndex,
      if (lengthMeters != null) 'lengthMeters': lengthMeters,
      if (speedKmh != null) 'speedKmh': speedKmh,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrafficSegment &&
        other.condition == condition &&
        other.startPolylinePointIndex == startPolylinePointIndex &&
        other.endPolylinePointIndex == endPolylinePointIndex &&
        other.lengthMeters == lengthMeters &&
        other.speedKmh == speedKmh;
  }

  @override
  int get hashCode {
    return Object.hash(
      condition,
      startPolylinePointIndex,
      endPolylinePointIndex,
      lengthMeters,
      speedKmh,
    );
  }
}

/// Traffic condition levels
enum TrafficCondition {
  /// Light traffic, normal flow
  light('LIGHT', 1, 'Light traffic'),

  /// Moderate traffic, some delays
  moderate('MODERATE', 2, 'Moderate traffic'),

  /// Heavy traffic, significant delays
  heavy('HEAVY', 3, 'Heavy traffic'),

  /// Severe traffic, major delays
  severe('SEVERE', 4, 'Severe traffic'),

  /// Unknown traffic condition
  unknown('UNKNOWN', 0, 'Unknown');

  const TrafficCondition(this.value, this.severity, this.description);

  /// The string value used in API responses
  final String value;

  /// Numeric severity level (higher = worse)
  final int severity;

  /// Human-readable description
  final String description;

  /// Convert from string value to enum
  static TrafficCondition? fromString(String value) {
    for (TrafficCondition condition in TrafficCondition.values) {
      if (condition.value == value) {
        return condition;
      }
    }
    return null;
  }

  /// Get color representation for UI display
  String get colorHex {
    switch (this) {
      case TrafficCondition.light:
        return '#4CAF50'; // Green
      case TrafficCondition.moderate:
        return '#FF9800'; // Orange
      case TrafficCondition.heavy:
        return '#F44336'; // Red
      case TrafficCondition.severe:
        return '#9C27B0'; // Purple
      case TrafficCondition.unknown:
        return '#9E9E9E'; // Grey
    }
  }

  /// Check if this condition indicates congestion
  bool get isCongested {
    return severity >= 2; // Moderate or worse
  }
}
