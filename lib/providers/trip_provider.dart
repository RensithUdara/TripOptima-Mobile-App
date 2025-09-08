import 'package:flutter/foundation.dart';
import 'package:trip_optima_mobile_app/models/trip_model.dart';
import 'package:trip_optima_mobile_app/models/location_model.dart';
import 'package:uuid/uuid.dart';

class TripProvider with ChangeNotifier {
  List<TripModel> _trips = [];
  TripModel? _currentTrip;
  bool _isLoading = false;
  String? _errorMessage;
  
  final _uuid = const Uuid();
  
  // Getters
  List<TripModel> get trips => _trips;
  TripModel? get currentTrip => _currentTrip;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  TripProvider() {
    _loadTrips();
  }
  
  // Load trips from storage or API (internal implementation)
  Future<void> _loadTrips() async {
    _setLoading(true);
    
    try {
      // TODO: Implement loading from storage or API
      // This is a placeholder - in a real app, you would load from your backend
      _trips = [];
      
      _setLoading(false);
    } catch (e) {
      _handleError('Failed to load trips: ${e.toString()}');
    }
  }
  
  // Public method to reload trips
  Future<void> loadTrips() async {
    await _loadTrips();
  }
  
  // Create a new trip
  Future<TripModel?> createTrip({
    required String name,
    required String userId,
    String description = '',
    required LocationModel startLocation,
    required List<LocationModel> destinations,
    required DateTime startDate,
    DateTime? endDate,
    TripStatus status = TripStatus.planned,
    TripVisibility visibility = TripVisibility.private,
    List<String> tags = const [],
  }) async {
    _setLoading(true);
    
    try {
      final trip = TripModel(
        id: _uuid.v4(),
        name: name,
        userId: userId,
        description: description,
        startLocation: startLocation,
        destinations: destinations,
        startDate: startDate,
        endDate: endDate,
        status: status,
        visibility: visibility,
        tags: tags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save to storage or API
      await _saveTrip(trip);
      
      // Add to local list
      _trips.add(trip);
      _currentTrip = trip;
      
      notifyListeners();
      _setLoading(false);
      
      return trip;
    } catch (e) {
      _handleError('Failed to create trip: ${e.toString()}');
      return null;
    }
  }
  
  // Get trip by ID
  Future<TripModel?> getTripById(String tripId) async {
    // Try to find in local list first
    final localTrip = _trips.firstWhere(
      (trip) => trip.id == tripId,
      orElse: () => throw Exception('Trip not found'),
    );
    
    if (localTrip != null) {
      _currentTrip = localTrip;
      notifyListeners();
      return localTrip;
    }
    
    // If not found locally, try to fetch from API
    _setLoading(true);
    
    try {
      // TODO: Implement fetching from API
      // This is a placeholder - in a real app, you would fetch from your backend
      
      _setLoading(false);
      return null;
    } catch (e) {
      _handleError('Failed to get trip: ${e.toString()}');
      return null;
    }
  }
  
  // Update existing trip
  Future<TripModel?> updateTrip(TripModel updatedTrip) async {
    _setLoading(true);
    
    try {
      // Update timestamp
      updatedTrip = updatedTrip.copyWith(
        updatedAt: DateTime.now(),
      );
      
      // Save to storage or API
      await _saveTrip(updatedTrip);
      
      // Update in local list
      final index = _trips.indexWhere((trip) => trip.id == updatedTrip.id);
      
      if (index != -1) {
        _trips[index] = updatedTrip;
      } else {
        _trips.add(updatedTrip);
      }
      
      // Update current trip if it's the same
      if (_currentTrip?.id == updatedTrip.id) {
        _currentTrip = updatedTrip;
      }
      
      notifyListeners();
      _setLoading(false);
      
      return updatedTrip;
    } catch (e) {
      _handleError('Failed to update trip: ${e.toString()}');
      return null;
    }
  }
  
  // Delete trip
  Future<bool> deleteTrip(String tripId) async {
    _setLoading(true);
    
    try {
      // Delete from storage or API
      await _deleteTrip(tripId);
      
      // Remove from local list
      _trips.removeWhere((trip) => trip.id == tripId);
      
      // Clear current trip if it's the same
      if (_currentTrip?.id == tripId) {
        _currentTrip = null;
      }
      
      notifyListeners();
      _setLoading(false);
      
      return true;
    } catch (e) {
      _handleError('Failed to delete trip: ${e.toString()}');
      return false;
    }
  }
  
  // Duplicate trip
  Future<TripModel?> duplicateTrip(String tripId) async {
    _setLoading(true);
    
    try {
      // Find original trip
      final originalTrip = _trips.firstWhere(
        (trip) => trip.id == tripId,
        orElse: () => throw Exception('Trip not found'),
      );
      
      // Create a copy with new ID
      final duplicateTrip = TripModel(
        id: _uuid.v4(),
        name: '${originalTrip.name} (Copy)',
        userId: originalTrip.userId,
        description: originalTrip.description,
        startLocation: originalTrip.startLocation,
        destinations: originalTrip.destinations,
        startDate: originalTrip.startDate,
        endDate: originalTrip.endDate,
        status: TripStatus.planned, // Always start as planned
        visibility: originalTrip.visibility,
        tags: originalTrip.tags,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Save to storage or API
      await _saveTrip(duplicateTrip);
      
      // Add to local list
      _trips.add(duplicateTrip);
      _currentTrip = duplicateTrip;
      
      notifyListeners();
      _setLoading(false);
      
      return duplicateTrip;
    } catch (e) {
      _handleError('Failed to duplicate trip: ${e.toString()}');
      return null;
    }
  }
  
  // Get trips by user ID
  List<TripModel> getTripsByUserId(String userId) {
    return _trips.where((trip) => trip.userId == userId).toList();
  }
  
  // Get trips by status
  List<TripModel> getTripsByStatus(TripStatus status) {
    return _trips.where((trip) => trip.status == status).toList();
  }
  
  // Filter trips by dates
  List<TripModel> filterTripsByDateRange(DateTime start, DateTime end) {
    return _trips.where((trip) {
      return (trip.startDate.isAfter(start) || trip.startDate.isAtSameMomentAs(start)) && 
             (trip.startDate.isBefore(end) || trip.startDate.isAtSameMomentAs(end));
    }).toList();
  }
  
  // Search trips by name or description
  List<TripModel> searchTrips(String query) {
    final normalizedQuery = query.toLowerCase();
    
    return _trips.where((trip) {
      return trip.name.toLowerCase().contains(normalizedQuery) ||
             trip.description.toLowerCase().contains(normalizedQuery);
    }).toList();
  }
  
  // Filter trips by tags
  List<TripModel> filterTripsByTags(List<String> tags) {
    return _trips.where((trip) {
      return tags.any((tag) => trip.tags.contains(tag));
    }).toList();
  }
  
  // Set current trip
  void setCurrentTrip(TripModel trip) {
    _currentTrip = trip;
    notifyListeners();
  }
  
  // Clear current trip
  void clearCurrentTrip() {
    _currentTrip = null;
    notifyListeners();
  }
  
  // Add destination to current trip
  Future<TripModel?> addDestinationToCurrentTrip(LocationModel location) async {
    if (_currentTrip == null) {
      _handleError('No current trip selected');
      return null;
    }
    
    final updatedDestinations = List<LocationModel>.from(_currentTrip!.destinations);
    updatedDestinations.add(location);
    
    final updatedTrip = _currentTrip!.copyWith(
      destinations: updatedDestinations,
      updatedAt: DateTime.now(),
    );
    
    return await updateTrip(updatedTrip);
  }
  
  // Remove destination from current trip
  Future<TripModel?> removeDestinationFromCurrentTrip(String locationId) async {
    if (_currentTrip == null) {
      _handleError('No current trip selected');
      return null;
    }
    
    final updatedDestinations = _currentTrip!.destinations
        .where((location) => location.id != locationId)
        .toList();
    
    final updatedTrip = _currentTrip!.copyWith(
      destinations: updatedDestinations,
      updatedAt: DateTime.now(),
    );
    
    return await updateTrip(updatedTrip);
  }
  
  // Update trip status
  Future<TripModel?> updateTripStatus(String tripId, TripStatus status) async {
    final tripToUpdate = _trips.firstWhere(
      (trip) => trip.id == tripId,
      orElse: () => throw Exception('Trip not found'),
    );
    
    final updatedTrip = tripToUpdate.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
    
    return await updateTrip(updatedTrip);
  }
  
  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _handleError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> _saveTrip(TripModel trip) async {
    // TODO: Implement saving to storage or API
    // This is a placeholder - in a real app, you would save to your backend
  }
  
  Future<void> _deleteTrip(String tripId) async {
    // TODO: Implement deleting from storage or API
    // This is a placeholder - in a real app, you would delete from your backend
  }
}
