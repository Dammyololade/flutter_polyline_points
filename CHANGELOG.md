## [3.0.1] - 2024-07-23
- **NEW**: Add support for custom headers in Routes API requests.

## [3.0.0] - 2024-07-22

### 🚀 Major Refactor - Simplified and Unified API

#### Unified PolylinePoints Class
- **BREAKING**: Simplified API with single `PolylinePoints` class for both APIs
- **BREAKING**: Constructor now requires `apiKey` parameter
- **NEW**: Factory constructors: `PolylinePoints.legacy()`, `PolylinePoints.enhanced()`, `PolylinePoints.custom()`
- **ENHANCED**: Unified interface supporting both Directions API and Routes API

#### Enhanced Routes API Integration
- **NEW**: `RoutesApiRequest` model with comprehensive parameter support
- **NEW**: `RoutesApiResponse` model with improved type safety
- **NEW**: Custom body parameters support for advanced use cases
- **NEW**: Field mask support for response optimization
- **NEW**: Two-wheeler routing mode support

#### Improved Request/Response Models
- **NEW**: `RouteModifiers` for enhanced route customization
- **NEW**: Timing preferences with departure/arrival time support
- **NEW**: Convenience getters: `durationMinutes`, `staticDurationMinutes`, `distanceKm`
- **ENHANCED**: Better type safety and null handling
- **ENHANCED**: Polyline decoding integration with automatic point conversion

#### Developer Experience
- **NEW**: Comprehensive test coverage for reliability
- **NEW**: `convertToLegacyResult()` method for API compatibility
- **NEW**: Enhanced error handling and validation
- **IMPROVED**: Code documentation and examples
- **IMPROVED**: Better parameter validation and error messages

### 🔧 Technical Improvements
- **ENHANCED**: Network utilities with better error handling
- **ENHANCED**: Polyline decoder with robust error handling
- **NEW**: Static `decodePolyline` method for utility usage
- **IMPROVED**: JSON serialization and deserialization
- **IMPROVED**: Memory efficiency and performance

### 🛠️ Breaking Changes
- **BREAKING**: `PolylinePoints` constructor now requires `apiKey` parameter
- **BREAKING**: Removed `googleApiKey` parameter from method calls
- **BREAKING**: Simplified class structure (removed separate V2 classes)
- **MIGRATION**: Update constructor calls and remove `googleApiKey` from method parameters

### 📚 Migration Support
- **MAINTAINED**: Full backward compatibility for legacy Directions API
- **NEW**: Clear migration path from v2.x to v3.0
- **NEW**: Updated documentation with migration examples
- **NEW**: Factory constructors for different use cases

---

## [2.1.0] - 02-06-2024
- Breaking change,
  `getRouteBetweenCoordinates` now requires a `PolylineRequest` object
- Updated http package
- Bug fixes and general improvements
  Special thanks to these contributors:
- [@tetrix](https://github.com/TetrixGauss)
- [@fadimanakilci](https://github.com/fadimanakilci)
- [@anixsam](https://github.com/anixsam)
## [2.0.0] - 22-08-2023
Updated dependencies and added some new functionalities such as:
- Fetching alternative routes
- Optimised algorithm for web
Special thanks to this contibutors for landing such huge PRs:
- [@nnadir35](https://github.com/nnadir35)
- [@shkvoretz](https://github.com/shkvoretz)
## [1.0.0] - 16-04-2021
Released a null safety version
## [0.2.6] - 07-03-2021
updated http package
## [0.2.5] - 07-03-2021
updating http dependency to ^0.13.0
## [0.2.4] - 29-09-2020
Fixed issues with waypoint
## [0.2.3] - 24-08-2020
Fixed a bug with adding waypoint to request thanks to [EnzoSeason](https://github.com/EnzoSeason)
## [0.2.2] - 10-06-2020
FIxed issues with incorrect key being passed as travelmode
Changed waypoint documentation
## [0.2.1] - 05-04-2020.
Breaking change, the response object has been refined to a more
suitable object that contains the status of the api and the error message.
## [0.2.0] - 05-04-2020.
Add travel mode, thanks to [@tuxbook](https://github.com/tuxbook)
Fixed unhandled error exception.
## [0.1.0] - 25-04-2019.
update readme.
## [0.0.1] - 25-04-2019.
initial release.
