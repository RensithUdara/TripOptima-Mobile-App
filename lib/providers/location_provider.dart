import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trip_optima_mobile_app/models/location_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_place/google_place.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trip_optima_mobile_app/constants/app_config.dart';

enum LocationPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  limited,
  undetermined
}

class LocationProvider with ChangeNotifier {
  LocationModel? _currentLocation;
  List<LocationModel> _searchHistory = [];
  List<LocationModel> _favoriteLocations = [];
  List<AutocompletePrediction> _searchSuggestions = [];
  
  bool _isLoading = false;
  String? _errorMessage;
  LocationPermissionStatus _permissionStatus = LocationPermissionStatus.undetermined;
  
  late GooglePlace _googlePlace;
  final _uuid = const Uuid();
  
  // Getters
  LocationModel? get currentLocation => _currentLocation;
  List<LocationModel> get searchHistory => _searchHistory;
  List<LocationModel> get favoriteLocations => _favoriteLocations;
  List<AutocompletePrediction> get searchSuggestions => _searchSuggestions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LocationPermissionStatus get permissionStatus => _permissionStatus;
  
  LocationProvider() {
    _googlePlace = GooglePlace(AppConfig.googleMapsApiKey);
    _initializeLocation();
  }
  
  Future<void> _initializeLocation() async {
    _checkLocationPermission();
    _loadFavoriteLocations();
    _loadSearchHistory();
  }
  
  // Request location permission
  Future<bool> requestLocationPermission() async {
    _setLoading(true);
    
    try {
      final status = await Permission.location.request();
      _updatePermissionStatus(status);
      
      if (_permissionStatus == LocationPermissionStatus.granted) {
        // Get current location if permission is granted
        await getCurrentLocation();
        _setLoading(false);
        return true;
      }
      
      _setLoading(false);
      return false;
    } catch (e) {
      _handleError('Failed to request location permission: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }
  
  // Check location permission status
  Future<void> _checkLocationPermission() async {
    try {
      final status = await Permission.location.status;
      _updatePermissionStatus(status);
      
      if (_permissionStatus == LocationPermissionStatus.granted) {
        // Get current location if permission is already granted
        getCurrentLocation();
      }
    } catch (e) {
      _handleError('Failed to check location permission: ${e.toString()}');
    }
  }
  
  // Get current location
  Future<LocationModel?> getCurrentLocation() async {
    if (_permissionStatus != LocationPermissionStatus.granted) {
      _handleError('Location permission not granted');
      return null;
    }
    
    _setLoading(true);
    
    try {
      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      
      // Get address from coordinates
      final addresses = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (addresses.isNotEmpty) {
        final place = addresses.first;
        final address = _formatAddress(place);
        
        _currentLocation = LocationModel(
          id: _uuid.v4(),
          name: address,
          latitude: position.latitude,
          longitude: position.longitude,
          address: address,
          timestamp: DateTime.now(),
        );
        
        notifyListeners();
      }
      
      _setLoading(false);
      return _currentLocation;
    } catch (e) {
      _handleError('Failed to get current location: ${e.toString()}');
      _setLoading(false);
      return null;
    }
  }
  
  // Search places
  Future<List<LocationModel>> searchPlaces(String query) async {
    if (query.isEmpty) {
      return [];
    }
    
    _setLoading(true);
    
    try {
      final result = await _googlePlace.search.getTextSearch(query);
      
      if (result != null && result.results != null) {
        final locations = result.results!
            .where((result) => result.geometry?.location != null)
            .map((result) => LocationModel(
                id: result.placeId ?? _uuid.v4(),
                name: result.name ?? 'Unknown place',
                latitude: result.geometry!.location!.lat ?? 0.0,
                longitude: result.geometry!.location!.lng ?? 0.0,
                address: result.formattedAddress,
                placeId: result.placeId,
                timestamp: DateTime.now(),
              ))
            .toList();
            
        // Add to search history (only if not already there)
        if (locations.isNotEmpty) {
          _addToSearchHistory(locations.first);
        }
        
        _setLoading(false);
        return locations;
      }
      
      _setLoading(false);
      return [];
    } catch (e) {
      _handleError('Failed to search places: ${e.toString()}');
      _setLoading(false);
      return [];
    }
  }
  
  // Get place suggestions (autocomplete)
  Future<void> getPlaceSuggestions(String query) async {
    if (query.isEmpty) {
      _searchSuggestions = [];
      notifyListeners();
      return;
    }
    
    try {
      final result = await _googlePlace.autocomplete.get(query);
      
      if (result != null && result.predictions != null) {
        _searchSuggestions = result.predictions!;
        notifyListeners();
      }
    } catch (e) {
      _handleError('Failed to get place suggestions: ${e.toString()}');
    }
  }
  
  // Get location details from place ID
  Future<LocationModel?> getPlaceDetails(String placeId) async {
    _setLoading(true);
    
    try {
      final result = await _googlePlace.details.get(placeId);
      
      if (result != null && result.result != null && result.result!.geometry != null) {
        final location = LocationModel(
          id: placeId,
          name: result.result!.name ?? 'Unknown place',
          latitude: result.result!.geometry!.location!.lat ?? 0.0,
          longitude: result.result!.geometry!.location!.lng ?? 0.0,
          address: result.result!.formattedAddress,
          placeId: placeId,
          timestamp: DateTime.now(),
        );
        
        // Add to search history
        _addToSearchHistory(location);
        
        _setLoading(false);
        return location;
      }
      
      _setLoading(false);
      return null;
    } catch (e) {
      _handleError('Failed to get place details: ${e.toString()}');
      _setLoading(false);
      return null;
    }
  }
  
  // Add to favorites
  Future<void> addToFavorites(LocationModel location) async {
    if (_favoriteLocations.any((loc) => loc.id == location.id)) {
      return; // Already in favorites
    }
    
    _favoriteLocations.add(location);
    notifyListeners();
    
    // Save to local storage
    _saveFavoriteLocations();
  }
  
  // Remove from favorites
  Future<void> removeFromFavorites(String locationId) async {
    _favoriteLocations.removeWhere((loc) => loc.id == locationId);
    notifyListeners();
    
    // Save to local storage
    _saveFavoriteLocations();
  }
  
  // Toggle favorite status
  Future<void> toggleFavorite(LocationModel location) async {
    final index = _favoriteLocations.indexWhere((loc) => loc.id == location.id);
    
    if (index >= 0) {
      // Remove if already in favorites
      _favoriteLocations.removeAt(index);
    } else {
      // Add if not in favorites
      _favoriteLocations.add(location);
    }
    
    notifyListeners();
    
    // Save to local storage
    _saveFavoriteLocations();
  }
  
  // Clear search history
  Future<void> clearSearchHistory() async {
    _searchHistory = [];
    notifyListeners();
    
    // Save to local storage
    _saveSearchHistory();
  }
  
  // Calculate distance between two locations (in meters)
  double calculateDistance(LocationModel location1, LocationModel location2) {
    return Geolocator.distanceBetween(
      location1.latitude, 
      location1.longitude, 
      location2.latitude, 
      location2.longitude
    );
  }
  
  // Check if a location is within radius (in meters)
  bool isLocationWithinRadius(LocationModel center, LocationModel target, double radius) {
    final distance = calculateDistance(center, target);
    return distance <= radius;
  }
  
  // Get address from coordinates
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final addresses = await placemarkFromCoordinates(latitude, longitude);
      
      if (addresses.isNotEmpty) {
        return _formatAddress(addresses.first);
      }
      
      return 'Unknown location';
    } catch (e) {
      _handleError('Failed to get address: ${e.toString()}');
      return 'Unknown location';
    }
  }
  
  // Get coordinates from address
  Future<LocationModel?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      
      if (locations.isNotEmpty) {
        final location = locations.first;
        
        return LocationModel(
          id: _uuid.v4(),
          name: address,
          latitude: location.latitude,
          longitude: location.longitude,
          address: address,
          timestamp: DateTime.now(),
        );
      }
      
      return null;
    } catch (e) {
      _handleError('Failed to get coordinates: ${e.toString()}');
      return null;
    }
  }
  
  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _handleError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }
  
  String _formatAddress(Placemark place) {
    final components = [
      place.name,
      place.street,
      place.subLocality,
      place.locality,
      place.administrativeArea,
      place.postalCode,
      place.country,
    ];
    
    return components
        .where((component) => component != null && component.isNotEmpty)
        .join(', ');
  }
  
  void _updatePermissionStatus(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        _permissionStatus = LocationPermissionStatus.granted;
        break;
      case PermissionStatus.denied:
        _permissionStatus = LocationPermissionStatus.denied;
        break;
      case PermissionStatus.permanentlyDenied:
        _permissionStatus = LocationPermissionStatus.permanentlyDenied;
        break;
      case PermissionStatus.restricted:
        _permissionStatus = LocationPermissionStatus.restricted;
        break;
      case PermissionStatus.limited:
        _permissionStatus = LocationPermissionStatus.limited;
        break;
      default:
        _permissionStatus = LocationPermissionStatus.undetermined;
    }
    
    notifyListeners();
  }
  
  void _addToSearchHistory(LocationModel location) {
    // Remove existing if present (to avoid duplicates)
    _searchHistory.removeWhere(
      (loc) => loc.id == location.id || loc.placeId == location.placeId
    );
    
    // Add to beginning of list
    _searchHistory.insert(0, location);
    
    // Limit history size
    if (_searchHistory.length > 20) {
      _searchHistory = _searchHistory.sublist(0, 20);
    }
    
    // Save to local storage
    _saveSearchHistory();
    
    notifyListeners();
  }
  
  Future<void> _loadFavoriteLocations() async {
    // TODO: Implement loading from SharedPreferences
    // This is a placeholder - in a real app, you would load from local storage
    _favoriteLocations = [];
    notifyListeners();
  }
  
  // Load favorite locations by IDs
  Future<void> loadFavoriteLocations(List<String> locationIds) async {
    if (locationIds.isEmpty) {
      _favoriteLocations = [];
      notifyListeners();
      return;
    }
    
    _setLoading(true);
    
    try {
      // In a real app, you would fetch these from an API or local database
      // For now, we'll create placeholder locations
      _favoriteLocations = locationIds.map((id) => LocationModel(
        id: id,
        name: 'Favorite Location $id',
        latitude: 0.0,
        longitude: 0.0,
        address: 'Sample address for location $id',
        timestamp: DateTime.now(),
        imageUrl: 'https://picsum.photos/seed/$id/300/200',
        tags: ['cities', 'nature'],
      )).toList();
      
      notifyListeners();
    } catch (e) {
      _handleError('Failed to load favorite locations: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> _saveFavoriteLocations() async {
    // TODO: Implement saving to SharedPreferences
    // This is a placeholder - in a real app, you would save to local storage
  }
  
  Future<void> _loadSearchHistory() async {
    // TODO: Implement loading from SharedPreferences
    // This is a placeholder - in a real app, you would load from local storage
    _searchHistory = [];
  }
  
  Future<void> _saveSearchHistory() async {
    // TODO: Implement saving to SharedPreferences
    // This is a placeholder - in a real app, you would save to local storage
  }
}
