/// Route modifiers for the Google Routes API
/// Provides enhanced control over route calculation preferences
class RouteModifiers {
  /// Avoid tolls when calculating the route
  final bool avoidTolls;

  /// Avoid highways when calculating the route
  final bool avoidHighways;

  /// Avoid ferries when calculating the route
  final bool avoidFerries;

  /// Avoid indoor navigation when calculating the route
  final bool avoidIndoor;

  /// Vehicle information for more accurate routing
  final VehicleInfo? vehicleInfo;

  /// Toll passes that the vehicle has access to
  final List<TollPass>? tollPasses;

  const RouteModifiers({
    this.avoidTolls = false,
    this.avoidHighways = false,
    this.avoidFerries = false,
    this.avoidIndoor = false,
    this.vehicleInfo,
    this.tollPasses,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (avoidTolls) json['avoidTolls'] = true;
    if (avoidHighways) json['avoidHighways'] = true;
    if (avoidFerries) json['avoidFerries'] = true;
    if (avoidIndoor) json['avoidIndoor'] = true;

    if (vehicleInfo != null) {
      json['vehicleInfo'] = vehicleInfo!.toJson();
    }

    if (tollPasses != null && tollPasses!.isNotEmpty) {
      json['tollPasses'] = tollPasses!.map((pass) => pass.toJson()).toList();
    }

    return json;
  }

  /// Create from JSON response
  factory RouteModifiers.fromJson(Map<String, dynamic> json) {
    return RouteModifiers(
      avoidTolls: json['avoidTolls'] ?? false,
      avoidHighways: json['avoidHighways'] ?? false,
      avoidFerries: json['avoidFerries'] ?? false,
      avoidIndoor: json['avoidIndoor'] ?? false,
      vehicleInfo: json['vehicleInfo'] != null
          ? VehicleInfo.fromJson(json['vehicleInfo'])
          : null,
      tollPasses: json['tollPasses'] != null
          ? (json['tollPasses'] as List)
              .map((pass) => TollPass.fromJson(pass))
              .toList()
          : null,
    );
  }

  /// Create a copy with modified values
  RouteModifiers copyWith({
    bool? avoidTolls,
    bool? avoidHighways,
    bool? avoidFerries,
    bool? avoidIndoor,
    VehicleInfo? vehicleInfo,
    List<TollPass>? tollPasses,
  }) {
    return RouteModifiers(
      avoidTolls: avoidTolls ?? this.avoidTolls,
      avoidHighways: avoidHighways ?? this.avoidHighways,
      avoidFerries: avoidFerries ?? this.avoidFerries,
      avoidIndoor: avoidIndoor ?? this.avoidIndoor,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      tollPasses: tollPasses ?? this.tollPasses,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RouteModifiers &&
        other.avoidTolls == avoidTolls &&
        other.avoidHighways == avoidHighways &&
        other.avoidFerries == avoidFerries &&
        other.avoidIndoor == avoidIndoor &&
        other.vehicleInfo == vehicleInfo &&
        _listEquals(other.tollPasses, tollPasses);
  }

  @override
  int get hashCode {
    return Object.hash(
      avoidTolls,
      avoidHighways,
      avoidFerries,
      avoidIndoor,
      vehicleInfo,
      tollPasses,
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

/// Vehicle information for more accurate routing
class VehicleInfo {
  /// License plate information for toll calculation
  final LicensePlate? licensePlate;

  /// Vehicle emission type
  final EmissionType? emissionType;

  const VehicleInfo({
    this.licensePlate,
    this.emissionType,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (licensePlate != null) {
      json['licensePlate'] = licensePlate!.toJson();
    }

    if (emissionType != null) {
      json['emissionType'] = emissionType!.value;
    }

    return json;
  }

  /// Create from JSON response
  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      licensePlate: json['licensePlate'] != null
          ? LicensePlate.fromJson(json['licensePlate'])
          : null,
      emissionType: json['emissionType'] != null
          ? EmissionType.fromString(json['emissionType'])
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VehicleInfo &&
        other.licensePlate == licensePlate &&
        other.emissionType == emissionType;
  }

  @override
  int get hashCode => Object.hash(licensePlate, emissionType);
}

/// License plate information
class LicensePlate {
  /// The license plate text
  final String text;

  /// The region code (e.g., 'US', 'CA')
  final String regionCode;

  const LicensePlate({
    required this.text,
    required this.regionCode,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'regionCode': regionCode,
    };
  }

  /// Create from JSON response
  factory LicensePlate.fromJson(Map<String, dynamic> json) {
    return LicensePlate(
      text: json['text'] ?? '',
      regionCode: json['regionCode'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LicensePlate &&
        other.text == text &&
        other.regionCode == regionCode;
  }

  @override
  int get hashCode => Object.hash(text, regionCode);
}

/// Vehicle emission types
enum EmissionType {
  gasoline('GASOLINE'),
  electric('ELECTRIC'),
  hybrid('HYBRID'),
  diesel('DIESEL');

  const EmissionType(this.value);

  final String value;

  static EmissionType? fromString(String value) {
    for (EmissionType type in EmissionType.values) {
      if (type.value == value) {
        return type;
      }
    }
    return null;
  }
}

/// Toll pass information
class TollPass {
  /// The toll pass identifier
  final String passId;

  /// The toll pass network
  final String? network;

  const TollPass({
    required this.passId,
    this.network,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    final json = {'passId': passId};
    if (network != null) json['network'] = network!;
    return json;
  }

  /// Create from JSON response
  factory TollPass.fromJson(Map<String, dynamic> json) {
    return TollPass(
      passId: json['passId'] ?? '',
      network: json['network'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TollPass &&
        other.passId == passId &&
        other.network == network;
  }

  @override
  int get hashCode => Object.hash(passId, network);
}
