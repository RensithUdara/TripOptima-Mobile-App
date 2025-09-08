import 'package:flutter/foundation.dart';
import 'package:trip_optima_mobile_app/models/route_model.dart';
import 'package:trip_optima_mobile_app/models/location_model.dart';
import 'package:trip_optima_mobile_app/models/trip_model.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:trip_optima_mobile_app/constants/app_config.dart';

class RouteProvider with ChangeNotifier {
  Map<String, RouteModel> _cachedRoutes = {};
  RouteModel? _currentRoute;
  bool _isLoading = false;
  String? _errorMessage;
  
  final _uuid = const Uuid();
  final PolylinePoints _polylinePoints = PolylinePoints();
  
  // Getters
  Map<String, RouteModel> get cachedRoutes => _cachedRoutes;
  RouteModel? get currentRoute => _currentRoute;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Calculate optimal route for a trip
  Future<RouteModel?> calculateOptimalRoute(TripModel trip) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Check if we have this route cached
      final cacheKey = _generateRouteCacheKey(trip);
      if (_cachedRoutes.containsKey(cacheKey)) {
        _currentRoute = _cachedRoutes[cacheKey];
        _setLoading(false);
        return _currentRoute;
      }
      
      // Prepare waypoints
      final waypoints = <LocationModel>[trip.startLocation];
      waypoints.addAll(trip.destinations);
      
      // Get optimized waypoint order
      final optimizedOrder = await _calculateOptimizedWaypointOrder(waypoints);
      
      // Reorder waypoints based on optimization
      final optimizedWaypoints = optimizedOrder.map((index) => waypoints[index]).toList();
      
      // Get route details for optimized waypoints
      final route = await _getRouteDetails(optimizedWaypoints, trip.id);
      
      if (route != null) {
        // Cache the route
        _cachedRoutes[cacheKey] = route;
        _currentRoute = route;
        
        notifyListeners();
        _setLoading(false);
        return route;
      }
      
      _handleError('Failed to calculate route');
      return null;
    } catch (e) {
      _handleError('Route calculation error: ${e.toString()}');
      return null;
    }
  }
  
  // Calculate route between two points
  Future<RouteModel?> calculateDirectRoute(
    LocationModel origin,
    LocationModel destination,
    String tripId,
  ) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Create waypoints list
      final waypoints = [origin, destination];
      
      // Get route details
      final route = await _getRouteDetails(waypoints, tripId);
      
      if (route != null) {
        _currentRoute = route;
        notifyListeners();
        _setLoading(false);
        return route;
      }
      
      _handleError('Failed to calculate direct route');
      return null;
    } catch (e) {
      _handleError('Direct route calculation error: ${e.toString()}');
      return null;
    }
  }
  
  // Calculate alternative routes
  Future<List<RouteModel>> calculateAlternativeRoutes(
    LocationModel origin,
    LocationModel destination,
    String tripId,
  ) async {
    _setLoading(true);
    _clearError();
    
    try {
      final alternatives = <RouteModel>[];
      
      // Get alternatives with different parameters
      final defaultRoute = await calculateDirectRoute(origin, destination, tripId);
      if (defaultRoute != null) {
        alternatives.add(defaultRoute);
      }
      
      // Add alternative routes with different parameters
      // Note: In a real implementation, you would call the Directions API with
      // different parameters such as avoid highways, avoid tolls, etc.
      
      _setLoading(false);
      return alternatives;
    } catch (e) {
      _handleError('Alternative routes calculation error: ${e.toString()}');
      return [];
    }
  }
  
  // Clear route cache
  void clearRouteCache() {
    _cachedRoutes.clear();
    notifyListeners();
  }
  
  // Clear current route
  void clearCurrentRoute() {
    _currentRoute = null;
    notifyListeners();
  }
  
  // Remove route from cache
  void removeCachedRoute(String tripId) {
    _cachedRoutes.removeWhere((key, route) => route.tripId == tripId);
    
    if (_currentRoute?.tripId == tripId) {
      _currentRoute = null;
    }
    
    notifyListeners();
  }
  
  // Get estimated travel time
  Duration getEstimatedTravelTime(RouteModel route, {bool withTraffic = true}) {
    final seconds = withTraffic && route.trafficInfo.isNotEmpty
        ? route.trafficInfo['duration_in_traffic'] as int? ?? route.totalDuration
        : route.totalDuration;
    
    return Duration(seconds: seconds);
  }
  
  // Get distance in preferred units (km or miles)
  double getDistanceInPreferredUnits(RouteModel route, bool useImperial) {
    final distanceInMeters = route.totalDistance;
    
    if (useImperial) {
      // Convert meters to miles
      return distanceInMeters / 1609.34;
    } else {
      // Convert meters to kilometers
      return distanceInMeters / 1000;
    }
  }
  
  // Calculate fuel consumption (based on average car consumption)
  double calculateFuelConsumption(RouteModel route, {double litersPer100km = 7.0}) {
    // Convert meters to kilometers
    final distanceInKm = route.totalDistance / 1000;
    
    // Calculate consumption
    return (distanceInKm * litersPer100km) / 100;
  }
  
  // Calculate CO2 emissions (based on average car emissions)
  double calculateCO2Emissions(RouteModel route, {double gramsPerKm = 120.0}) {
    // Convert meters to kilometers
    final distanceInKm = route.totalDistance / 1000;
    
    // Calculate emissions in kg
    return (distanceInKm * gramsPerKm) / 1000;
  }
  
  // Private helper methods
  Future<List<int>> _calculateOptimizedWaypointOrder(List<LocationModel> waypoints) async {
    if (waypoints.length <= 2) {
      // No optimization needed for 0, 1 or 2 waypoints
      return List.generate(waypoints.length, (index) => index);
    }
    
    try {
      // Format waypoints for Google Directions API
      final origin = waypoints.first;
      final destination = waypoints.last;
      final middleWaypoints = waypoints.sublist(1, waypoints.length - 1);
      
      // Build waypoints string for API
      final waypointsStr = middleWaypoints
          .map((wp) => '${wp.latitude},${wp.longitude}')
          .join('|');
      
      // Build URL
      final url = Uri.parse(
        '${AppConfig.googleDirectionsBaseUrl}/json'
        '?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&waypoints=optimize:true|$waypointsStr'
        '&key=${AppConfig.googleMapsApiKey}'
      );
      
      // Make request
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          // Get optimized waypoint order
          final waypointOrder = List<int>.from(data['routes'][0]['waypoint_order']);
          
          // Adjust waypoint order to include origin and destination
          final fullOrder = <int>[];
          fullOrder.add(0); // Origin is always first
          
          // Adjust the indexes to account for the origin waypoint
          for (int index in waypointOrder) {
            fullOrder.add(index + 1); // +1 because we skipped the origin in middleWaypoints
          }
          
          fullOrder.add(waypoints.length - 1); // Destination is always last
          
          return fullOrder;
        }
      }
      
      // Fallback: return sequential order
      return List.generate(waypoints.length, (index) => index);
    } catch (e) {
      // Fallback: return sequential order
      print('Error optimizing waypoints: ${e.toString()}');
      return List.generate(waypoints.length, (index) => index);
    }
  }
  
  Future<RouteModel?> _getRouteDetails(List<LocationModel> waypoints, String tripId) async {
    if (waypoints.length < 2) {
      return null; // Need at least origin and destination
    }
    
    try {
      // Format waypoints for Google Directions API
      final origin = waypoints.first;
      final destination = waypoints.last;
      
      // Build waypoints string for middle points
      String waypointsStr = '';
      if (waypoints.length > 2) {
        waypointsStr = waypoints
            .sublist(1, waypoints.length - 1)
            .map((wp) => '${wp.latitude},${wp.longitude}')
            .join('|');
      }
      
      // Build URL
      Uri url = Uri.parse(
        '${AppConfig.googleDirectionsBaseUrl}/json'
        '?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&key=${AppConfig.googleMapsApiKey}'
      );
      
      // Add waypoints if any
      if (waypointsStr.isNotEmpty) {
        url = url.replace(
          queryParameters: {
            ...url.queryParameters,
            'waypoints': waypointsStr
          }
        );
      }
      
      // Make request
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final legs = route['legs'];
          
          // Calculate total distance and duration
          double totalDistance = 0;
          int totalDuration = 0;
          
          for (var leg in legs) {
            totalDistance += leg['distance']['value'] as double;
            totalDuration += leg['duration']['value'] as int;
          }
          
          // Decode polyline points
          final encodedPolyline = route['overview_polyline']['points'] as String;
          final List<PointLatLng> decodedPoints = 
              _polylinePoints.decodePolyline(encodedPolyline);
              
          // Convert to list of [lat, lng] for storage
          final polylinePoints = decodedPoints
              .map((point) => [point.latitude, point.longitude])
              .toList();
          
          // Extract traffic info if available
          Map<String, dynamic> trafficInfo = {};
          
          if (legs.isNotEmpty && legs[0].containsKey('duration_in_traffic')) {
            trafficInfo = {
              'duration_in_traffic': legs[0]['duration_in_traffic']['value'],
              'duration_in_traffic_text': legs[0]['duration_in_traffic']['text'],
            };
          }
          
          // Create route model
          return RouteModel(
            id: _uuid.v4(),
            tripId: tripId,
            waypoints: waypoints,
            polylinePoints: polylinePoints,
            totalDistance: totalDistance,
            totalDuration: totalDuration,
            trafficInfo: trafficInfo,
            legs: List<Map<String, dynamic>>.from(legs),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      }
      
      _handleError('Failed to get route details: ${response.body}');
      return null;
    } catch (e) {
      _handleError('Route details error: ${e.toString()}');
      return null;
    }
  }
  
  String _generateRouteCacheKey(TripModel trip) {
    final points = [trip.startLocation, ...trip.destinations]
        .map((loc) => '${loc.latitude},${loc.longitude}')
        .join('|');
    
    return '$points-${trip.id}';
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _handleError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
  }
}
