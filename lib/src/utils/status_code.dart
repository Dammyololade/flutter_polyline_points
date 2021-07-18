/// Information for each code can be found at: https://developers.google.com/maps/documentation/directions/get-directions#StatusCodes
class StatusCode {
  final String _value;

  const StatusCode(String value) : _value = value;

  String get value => _value;

  static const OK = StatusCode("OK");
  static const NOT_FOUND = StatusCode("NOT_FOUND");
  static const ZERO_RESULTS = StatusCode("ZERO_RESULTS");
  static const MAX_WAYPOINTS_EXCEEDED = StatusCode("MAX_WAYPOINTS_EXCEEDED");
  static const MAX_ROUTE_LENGTH_EXCEEDED =
      StatusCode("MAX_ROUTE_LENGTH_EXCEEDED");
  static const INVALID_REQUEST = StatusCode("INVALID_REQUEST");
  static const OVER_DAILY_LIMIT = StatusCode("OVER_DAILY_LIMIT");
  static const OVER_QUERY_LIMIT = StatusCode("OVER_QUERY_LIMIT");
  static const REQUEST_DENIED = StatusCode("REQUEST_DENIED");
  static const UNKNOWN_ERROR = StatusCode("UNKNOWN_ERROR");

  @override
  bool operator ==(other) {
    if (identical(this, other)) return true;
    return other is StatusCode && other._value == _value;
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => _value;
}
