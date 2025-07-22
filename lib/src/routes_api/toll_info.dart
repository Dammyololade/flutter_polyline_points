/// Toll information for routes from the Google Routes API
class TollInfo {
  /// Estimated toll costs for the route
  final List<TollCost>? estimatedPrice;
  
  /// Whether the route contains toll roads
  final bool hasTolls;
  
  /// Toll passes that can be used on this route
  final List<String>? applicableTollPasses;

  const TollInfo({
    this.estimatedPrice,
    this.hasTolls = false,
    this.applicableTollPasses,
  });

  /// Create from JSON response
  factory TollInfo.fromJson(Map<String, dynamic> json) {
    return TollInfo(
      estimatedPrice: json['estimatedPrice'] != null
          ? (json['estimatedPrice'] as List)
              .map((cost) => TollCost.fromJson(cost))
              .toList()
          : null,
      hasTolls: json['hasTolls'] ?? false,
      applicableTollPasses: json['applicableTollPasses'] != null
          ? List<String>.from(json['applicableTollPasses'])
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (estimatedPrice != null)
        'estimatedPrice': estimatedPrice!.map((cost) => cost.toJson()).toList(),
      'hasTolls': hasTolls,
      if (applicableTollPasses != null)
        'applicableTollPasses': applicableTollPasses,
    };
  }

  /// Get the total estimated toll cost in the specified currency
  double? getTotalCost([String? currencyCode]) {
    if (estimatedPrice == null || estimatedPrice!.isEmpty) return null;
    
    if (currencyCode != null) {
      final costs = estimatedPrice!
          .where((cost) => cost.currencyCode == currencyCode)
          .toList();
      if (costs.isEmpty) return null;
      return costs.fold<double>(0.0, (sum, cost) => sum + cost.amount);
    }
    
    // Return the first currency's total if no specific currency requested
    final firstCurrency = estimatedPrice!.first.currencyCode;
    return estimatedPrice!
        .where((cost) => cost.currencyCode == firstCurrency)
        .fold<double>(0.0, (sum, cost) => sum + cost.amount);
  }

  /// Get all available currencies for toll costs
  List<String> getAvailableCurrencies() {
    if (estimatedPrice == null) return [];
    return estimatedPrice!
        .map((cost) => cost.currencyCode)
        .toSet()
        .toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TollInfo &&
        _listEquals(other.estimatedPrice, estimatedPrice) &&
        other.hasTolls == hasTolls &&
        _listEquals(other.applicableTollPasses, applicableTollPasses);
  }

  @override
  int get hashCode {
    return Object.hash(
      estimatedPrice,
      hasTolls,
      applicableTollPasses,
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

/// Individual toll cost information
class TollCost {
  /// The monetary amount of the toll
  final double amount;
  
  /// The currency code (e.g., 'USD', 'EUR')
  final String currencyCode;
  
  /// Human-readable description of the toll
  final String? description;
  
  /// The toll plaza or section name
  final String? tollPlaza;

  const TollCost({
    required this.amount,
    required this.currencyCode,
    this.description,
    this.tollPlaza,
  });

  /// Create from JSON response
  factory TollCost.fromJson(Map<String, dynamic> json) {
    return TollCost(
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currencyCode: json['currencyCode'] ?? '',
      description: json['description'],
      tollPlaza: json['tollPlaza'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currencyCode': currencyCode,
      if (description != null) 'description': description,
      if (tollPlaza != null) 'tollPlaza': tollPlaza,
    };
  }

  /// Format the toll cost as a currency string
  String formatCurrency() {
    final symbols = {
      'USD': r'$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'CAD': r'C$',
      'AUD': r'A$',
    };
    
    final symbol = symbols[currencyCode] ?? currencyCode;
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TollCost &&
        other.amount == amount &&
        other.currencyCode == currencyCode &&
        other.description == description &&
        other.tollPlaza == tollPlaza;
  }

  @override
  int get hashCode {
    return Object.hash(
      amount,
      currencyCode,
      description,
      tollPlaza,
    );
  }

  @override
  String toString() {
    return 'TollCost(${formatCurrency()}${description != null ? ' - $description' : ''})';
  }
}