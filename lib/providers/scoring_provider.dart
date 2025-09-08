import 'package:flutter/foundation.dart';
import 'package:trip_optima_mobile_app/models/trip_score_model.dart';
import 'package:trip_optima_mobile_app/models/trip_model.dart';
import 'package:trip_optima_mobile_app/models/weather_model.dart';
import 'package:trip_optima_mobile_app/models/route_model.dart';
import 'package:uuid/uuid.dart';

class ScoringProvider with ChangeNotifier {
  Map<String, TripScoreModel> _tripScores = {};
  bool _isLoading = false;
  String? _errorMessage;
  
  final _uuid = Uuid();
  
  // Getters
  Map<String, TripScoreModel> get tripScores => _tripScores;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Generate score for a trip
  Future<TripScoreModel?> generateTripScore({
    required TripModel trip,
    required RouteModel route,
    required List<WeatherModel> weatherData,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Check if we already have a score for this trip
      if (_tripScores.containsKey(trip.id)) {
        _setLoading(false);
        return _tripScores[trip.id];
      }
      
      // Calculate individual scores
      final weatherScore = _calculateWeatherScore(weatherData);
      final distanceScore = _calculateDistanceScore(route);
      final seasonalScore = _calculateSeasonalScore(trip, weatherData);
      final costScore = _calculateCostScore(trip, route);
      
      // Calculate category-specific scores
      final categoryScores = _calculateCategoryScores(trip, route, weatherData);
      
      // Calculate overall score (weighted average)
      final overallScore = _calculateOverallScore(
        weatherScore: weatherScore,
        distanceScore: distanceScore,
        seasonalScore: seasonalScore,
        costScore: costScore,
        categoryScores: categoryScores,
      );
      
      // Generate recommendation
      final recommendation = _generateRecommendation(
        overallScore,
        weatherScore,
        distanceScore,
        seasonalScore,
      );
      
      // Generate alternative suggestions
      final alternatives = _generateAlternativeSuggestions(
        trip,
        overallScore,
        weatherScore,
        distanceScore,
        seasonalScore,
      );
      
      // Create score model
      final scoreModel = TripScoreModel(
        id: _uuid.v4(),
        tripId: trip.id,
        overallScore: overallScore,
        weatherScore: weatherScore,
        distanceScore: distanceScore,
        seasonalScore: seasonalScore,
        costScore: costScore,
        categoryScores: categoryScores,
        recommendation: recommendation,
        alternativeSuggestions: alternatives,
        createdAt: DateTime.now(),
      );
      
      // Save to cache
      _tripScores[trip.id] = scoreModel;
      
      // Update trip with score if needed
      if (trip.tripScore == null) {
        // Update trip score logic would go here
        // Typically would call a TripProvider method to update the trip
      }
      
      notifyListeners();
      _setLoading(false);
      
      return scoreModel;
    } catch (e) {
      _handleError('Error generating trip score: ${e.toString()}');
      return null;
    }
  }
  
  // Get score for a trip
  TripScoreModel? getTripScore(String tripId) {
    return _tripScores[tripId];
  }
  
  // Clear score for a trip
  void clearTripScore(String tripId) {
    _tripScores.remove(tripId);
    notifyListeners();
  }
  
  // Clear all scores
  void clearAllScores() {
    _tripScores.clear();
    notifyListeners();
  }
  
  // Compare two trips and return the better option
  Map<String, dynamic> compareTrips(String tripId1, String tripId2) {
    final score1 = _tripScores[tripId1];
    final score2 = _tripScores[tripId2];
    
    if (score1 == null || score2 == null) {
      return {
        'error': 'One or both trip scores not found',
      };
    }
    
    final betterTripId = score1.overallScore > score2.overallScore ? tripId1 : tripId2;
    final scoreDifference = (score1.overallScore - score2.overallScore).abs();
    
    Map<String, dynamic> comparison = {
      'betterTripId': betterTripId,
      'scoreDifference': scoreDifference,
      'comparisonDetails': {
        'weather': {
          'tripId1': score1.weatherScore,
          'tripId2': score2.weatherScore,
          'difference': (score1.weatherScore - score2.weatherScore).abs(),
          'betterTripId': score1.weatherScore > score2.weatherScore ? tripId1 : tripId2,
        },
        'distance': {
          'tripId1': score1.distanceScore,
          'tripId2': score2.distanceScore,
          'difference': (score1.distanceScore - score2.distanceScore).abs(),
          'betterTripId': score1.distanceScore > score2.distanceScore ? tripId1 : tripId2,
        },
        'seasonal': {
          'tripId1': score1.seasonalScore,
          'tripId2': score2.seasonalScore,
          'difference': (score1.seasonalScore - score2.seasonalScore).abs(),
          'betterTripId': score1.seasonalScore > score2.seasonalScore ? tripId1 : tripId2,
        },
        'cost': {
          'tripId1': score1.costScore,
          'tripId2': score2.costScore,
          'difference': (score1.costScore - score2.costScore).abs(),
          'betterTripId': score1.costScore > score2.costScore ? tripId1 : tripId2,
        },
      }
    };
    
    return comparison;
  }
  
  // Get best travel date suggestions
  List<Map<String, dynamic>> getBestTravelDateSuggestions(
    TripModel trip,
    int daysToCheck,
  ) {
    // This would typically involve querying weather forecasts for multiple dates
    // and calculating scores for each possible date
    // For demo purposes, we'll return dummy data
    
    final today = DateTime.now();
    final suggestions = <Map<String, dynamic>>[];
    
    for (int i = 1; i <= 5; i++) {
      final suggestedDate = today.add(Duration(days: i * 2));
      suggestions.add({
        'date': suggestedDate.toIso8601String(),
        'predictedScore': 85 + (i % 3) * 5.0,
        'reason': 'Better weather conditions expected',
      });
    }
    
    // Sort by score descending
    suggestions.sort((a, b) => (b['predictedScore'] as double).compareTo(a['predictedScore'] as double));
    
    return suggestions;
  }
  
  // Private scoring methods
  double _calculateWeatherScore(List<WeatherModel> weatherData) {
    if (weatherData.isEmpty) {
      return 50.0; // Default score if no weather data
    }
    
    double totalScore = 0.0;
    
    for (var weather in weatherData) {
      // Start with perfect score
      double score = 100.0;
      
      // Penalize for bad conditions
      if (weather.condition.toLowerCase().contains('rain')) {
        score -= 20;
      } else if (weather.condition.toLowerCase().contains('snow')) {
        score -= 30;
      } else if (weather.condition.toLowerCase().contains('storm')) {
        score -= 50;
      }
      
      // Adjust for temperature
      final idealTemp = 23.0; // ideal temperature in Celsius
      final tempDiff = (weather.temperature - idealTemp).abs();
      if (tempDiff > 10) {
        score -= (tempDiff - 10) * 2; // Penalize for each degree away from ideal range
      }
      
      // Adjust for wind
      if (weather.windSpeed > 10) {
        score -= (weather.windSpeed - 10) * 2;
      }
      
      // Adjust for visibility
      if (weather.visibility < 5000) {
        score -= (5000 - weather.visibility) / 100;
      }
      
      // Adjust for humidity
      if (weather.humidity > 80) {
        score -= (weather.humidity - 80) * 0.5;
      }
      
      // Ensure score is within range
      score = score.clamp(0, 100);
      totalScore += score;
    }
    
    // Return average score
    return totalScore / weatherData.length;
  }
  
  double _calculateDistanceScore(RouteModel route) {
    // Higher score for shorter routes
    // Example implementation: 100 - penalty for distance
    
    // Convert meters to kilometers
    final distanceKm = route.totalDistance / 1000;
    
    // Base score
    double score = 100.0;
    
    // Penalize long distances
    // For example, 1 point penalty per 10km after the first 50km
    if (distanceKm > 50) {
      score -= (distanceKm - 50) / 10;
    }
    
    // Penalize long durations
    // For example, 1 point penalty per 10 minutes after the first hour
    final durationHours = route.totalDuration / 3600;
    if (durationHours > 1) {
      score -= (durationHours - 1) * 6;
    }
    
    // Ensure score is within range
    return score.clamp(0, 100);
  }
  
  double _calculateSeasonalScore(TripModel trip, List<WeatherModel> weatherData) {
    // Higher score for traveling during appropriate seasons
    // Example: Beach destinations score higher in summer, ski destinations in winter
    
    // Get the season for the trip start date
    final tripMonth = trip.startDate.month;
    String season;
    
    if (tripMonth >= 3 && tripMonth <= 5) {
      season = 'spring';
    } else if (tripMonth >= 6 && tripMonth <= 8) {
      season = 'summer';
    } else if (tripMonth >= 9 && tripMonth <= 11) {
      season = 'autumn';
    } else {
      season = 'winter';
    }
    
    // Default score
    double score = 70.0;
    
    // Example logic - can be expanded with more destination types
    // Check trip tags for destination type indicators
    if (trip.tags.any((tag) => tag.toLowerCase().contains('beach'))) {
      // Beach destinations score higher in summer
      if (season == 'summer') {
        score += 25;
      } else if (season == 'spring' || season == 'autumn') {
        score += 10;
      } else {
        score -= 10; // Winter is not ideal for beaches
      }
    } else if (trip.tags.any((tag) => tag.toLowerCase().contains('ski'))) {
      // Ski destinations score higher in winter
      if (season == 'winter') {
        score += 25;
      } else if (season == 'autumn') {
        score += 5;
      } else {
        score -= 20; // Summer is not ideal for skiing
      }
    } else if (trip.tags.any((tag) => tag.toLowerCase().contains('city'))) {
      // City destinations score higher in spring and autumn
      if (season == 'spring' || season == 'autumn') {
        score += 15;
      }
    } else if (trip.tags.any((tag) => tag.toLowerCase().contains('hiking'))) {
      // Hiking destinations score higher in spring and autumn
      if (season == 'spring' || season == 'autumn') {
        score += 20;
      } else if (season == 'summer') {
        score += 10;
      } else {
        score -= 5; // Winter is not ideal for most hiking
      }
    }
    
    // Check for average temperature and adjust score accordingly
    if (weatherData.isNotEmpty) {
      final avgTemp = weatherData.map((w) => w.temperature).reduce((a, b) => a + b) / weatherData.length;
      
      // Different ideal temperature ranges based on trip type
      if (trip.tags.any((tag) => tag.toLowerCase().contains('beach'))) {
        // For beach: ideal temp 25-30°C
        if (avgTemp >= 25 && avgTemp <= 30) {
          score += 10;
        } else if (avgTemp < 20) {
          score -= 15; // Too cold for beach
        }
      } else if (trip.tags.any((tag) => tag.toLowerCase().contains('ski'))) {
        // For skiing: ideal temp -5 to 2°C
        if (avgTemp >= -5 && avgTemp <= 2) {
          score += 10;
        } else if (avgTemp > 5) {
          score -= 15; // Too warm for skiing
        }
      } else {
        // For general travel: ideal temp 18-25°C
        if (avgTemp >= 18 && avgTemp <= 25) {
          score += 10;
        } else if (avgTemp > 32 || avgTemp < 5) {
          score -= 10; // Too extreme
        }
      }
    }
    
    // Ensure score is within range
    return score.clamp(0, 100);
  }
  
  double _calculateCostScore(TripModel trip, RouteModel route) {
    // Higher score for more cost-effective trips
    // This would typically incorporate fuel costs, accommodation costs, etc.
    
    // For demonstration, we'll use a simple model based on distance and duration
    
    // Base score
    double score = 80.0;
    
    // Distance factor - longer trips cost more
    final distanceKm = route.totalDistance / 1000;
    score -= distanceKm / 50; // Rough estimate: -1 point per 50km
    
    // Duration factor - longer stays cost more
    if (trip.endDate != null) {
      final tripDurationDays = trip.endDate!.difference(trip.startDate).inDays;
      score -= tripDurationDays * 0.5; // -0.5 points per day
    }
    
    // Number of destinations factor - more destinations increase costs
    final destinationCount = trip.destinations.length;
    score -= destinationCount * 2; // -2 points per additional destination
    
    // Adjust for accommodation type if available in metadata
    if (trip.metadata.containsKey('accommodationType')) {
      final accomodationType = trip.metadata['accommodationType'] as String?;
      
      if (accomodationType == 'camping') {
        score += 10; // Camping is cheaper
      } else if (accomodationType == 'hostel') {
        score += 5; // Hostels are relatively cheap
      } else if (accomodationType == 'luxury') {
        score -= 15; // Luxury accommodations are expensive
      }
    }
    
    // Adjust for transportation type if available in metadata
    if (trip.metadata.containsKey('transportationType')) {
      final transportationType = trip.metadata['transportationType'] as String?;
      
      if (transportationType == 'walking' || transportationType == 'cycling') {
        score += 15; // Free transportation
      } else if (transportationType == 'public') {
        score += 10; // Public transit is relatively cheap
      } else if (transportationType == 'taxi') {
        score -= 10; // Taxis are expensive
      }
    }
    
    // Ensure score is within range
    return score.clamp(0, 100);
  }
  
  Map<String, double> _calculateCategoryScores(
    TripModel trip,
    RouteModel route,
    List<WeatherModel> weatherData
  ) {
    final Map<String, double> categoryScores = {};
    
    // Calculate scores for different trip categories/purposes
    // This allows for specialized scoring based on trip purpose
    
    // Family trip score
    if (trip.tags.contains('family')) {
      double familyScore = 80.0;
      
      // Prefer moderate distances for family trips
      final distanceKm = route.totalDistance / 1000;
      if (distanceKm > 200) {
        familyScore -= (distanceKm - 200) / 20; // Penalty for long trips
      }
      
      // Prefer mild weather for family trips
      for (var weather in weatherData) {
        if (weather.temperature < 10 || weather.temperature > 30) {
          familyScore -= 5; // Penalty for extreme temperatures
        }
        if (weather.condition.toLowerCase().contains('rain') || 
            weather.condition.toLowerCase().contains('storm')) {
          familyScore -= 10; // Penalty for bad weather
        }
      }
      
      categoryScores['family'] = familyScore.clamp(0, 100);
    }
    
    // Adventure trip score
    if (trip.tags.contains('adventure')) {
      double adventureScore = 80.0;
      
      // Adventure trips can handle more extreme conditions
      for (var weather in weatherData) {
        if (weather.condition.toLowerCase().contains('clear')) {
          adventureScore += 5; // Bonus for clear weather
        }
        // Less penalty for challenging conditions
        if (weather.condition.toLowerCase().contains('rain')) {
          adventureScore -= 5; // Smaller penalty for rain
        }
      }
      
      categoryScores['adventure'] = adventureScore.clamp(0, 100);
    }
    
    // Business trip score
    if (trip.tags.contains('business')) {
      double businessScore = 80.0;
      
      // Business trips prioritize reliable travel conditions
      for (var weather in weatherData) {
        if (weather.condition.toLowerCase().contains('storm') || 
            weather.condition.toLowerCase().contains('snow')) {
          businessScore -= 15; // Higher penalty for disruptive weather
        }
      }
      
      // Prefer shorter trips for business
      final durationHours = route.totalDuration / 3600;
      if (durationHours > 3) {
        businessScore -= (durationHours - 3) * 5; // Penalty for long trips
      }
      
      categoryScores['business'] = businessScore.clamp(0, 100);
    }
    
    // Relaxation trip score
    if (trip.tags.contains('relaxation')) {
      double relaxScore = 80.0;
      
      // Relaxation trips highly prioritize good weather
      for (var weather in weatherData) {
        if (weather.condition.toLowerCase().contains('clear') || 
            weather.condition.toLowerCase().contains('sunny')) {
          relaxScore += 10; // Higher bonus for nice weather
        }
        if (weather.condition.toLowerCase().contains('rain') || 
            weather.condition.toLowerCase().contains('storm')) {
          relaxScore -= 15; // Higher penalty for bad weather
        }
        
        // Ideal temperature range for relaxation
        if (weather.temperature >= 22 && weather.temperature <= 28) {
          relaxScore += 5;
        }
      }
      
      categoryScores['relaxation'] = relaxScore.clamp(0, 100);
    }
    
    // Add a default general score
    categoryScores['general'] = (
      _calculateWeatherScore(weatherData) * 0.4 +
      _calculateDistanceScore(route) * 0.3 +
      _calculateSeasonalScore(trip, weatherData) * 0.2 +
      _calculateCostScore(trip, route) * 0.1
    ).clamp(0, 100);
    
    return categoryScores;
  }
  
  double _calculateOverallScore({
    required double weatherScore,
    required double distanceScore,
    required double seasonalScore,
    required double costScore,
    required Map<String, double> categoryScores,
  }) {
    // Weighted average of all scores
    // Weights can be adjusted based on importance
    double overallScore = 0.0;
    
    // Default weights
    final Map<String, double> weights = {
      'weather': 0.4,     // Weather is very important
      'distance': 0.25,   // Distance is moderately important
      'seasonal': 0.2,    // Seasonal appropriateness is somewhat important
      'cost': 0.15,       // Cost is less important but still a factor
    };
    
    // Calculate weighted score
    overallScore += weatherScore * weights['weather']!;
    overallScore += distanceScore * weights['distance']!;
    overallScore += seasonalScore * weights['seasonal']!;
    overallScore += costScore * weights['cost']!;
    
    // Adjust for any special category weights
    // This can be expanded based on trip type/purpose
    
    return overallScore.clamp(0, 100);
  }
  
  String _generateRecommendation(
    double overallScore,
    double weatherScore,
    double distanceScore,
    double seasonalScore,
  ) {
    // Generate a human-readable recommendation based on scores
    
    if (overallScore >= 80) {
      return 'Excellent travel conditions! This trip is highly recommended.';
    } else if (overallScore >= 70) {
      return 'Good travel conditions. This trip is recommended.';
    } else if (overallScore >= 60) {
      // Check what's bringing the score down
      if (weatherScore < 60) {
        return 'Average conditions. Weather might not be ideal for this trip.';
      } else if (distanceScore < 60) {
        return 'Average conditions. Consider if the travel distance is worth it.';
      } else if (seasonalScore < 60) {
        return 'Average conditions. This might not be the best season for this destination.';
      } else {
        return 'Average travel conditions. The trip is acceptable but not ideal.';
      }
    } else if (overallScore >= 50) {
      return 'Below average conditions. Consider postponing or modifying this trip.';
    } else {
      return 'Poor travel conditions. Not recommended at this time.';
    }
  }
  
  List<Map<String, dynamic>> _generateAlternativeSuggestions(
    TripModel trip,
    double overallScore,
    double weatherScore,
    double distanceScore,
    double seasonalScore,
  ) {
    // Generate alternative suggestions based on scores
    final List<Map<String, dynamic>> suggestions = [];
    
    // Only generate alternatives if score is below threshold
    if (overallScore >= 75) {
      return suggestions; // No need for alternatives
    }
    
    // Weather-based suggestions
    if (weatherScore < 60) {
      // Calculate better dates
      final today = DateTime.now();
      
      // Suggest dates with potentially better weather
      for (int i = 1; i <= 3; i++) {
        final suggestedDate = today.add(Duration(days: i * 7)); // Try weekly intervals
        
        suggestions.add({
          'type': 'date',
          'suggestion': 'Consider traveling on ${_formatDate(suggestedDate)} for potentially better weather',
          'adjustedScore': (overallScore + 10 + (i * 2)).clamp(0, 100), // Estimated improvement
          'details': {
            'date': suggestedDate.toIso8601String(),
            'reason': 'Weather patterns suggest more favorable conditions',
          }
        });
      }
    }
    
    // Distance-based suggestions
    if (distanceScore < 60 && trip.destinations.length > 1) {
      suggestions.add({
        'type': 'itinerary',
        'suggestion': 'Consider removing some destinations to optimize your route',
        'adjustedScore': (overallScore + 15).clamp(0, 100), // Estimated improvement
        'details': {
          'recommendedDestinationsCount': trip.destinations.length - 1,
          'reason': 'A shorter itinerary would reduce travel time and improve the experience',
        }
      });
    }
    
    // Season-based suggestions
    if (seasonalScore < 60) {
      // Suggest better season
      final currentMonth = trip.startDate.month;
      int betterMonth;
      String betterSeason;
      
      if (currentMonth >= 3 && currentMonth <= 8) {
        // If spring/summer, suggest fall
        betterMonth = 10;
        betterSeason = 'autumn';
      } else {
        // If fall/winter, suggest spring
        betterMonth = 4;
        betterSeason = 'spring';
      }
      
      final suggestedDate = DateTime(trip.startDate.year, betterMonth, 15);
      
      suggestions.add({
        'type': 'season',
        'suggestion': 'Consider traveling during $betterSeason for better seasonal conditions',
        'adjustedScore': (overallScore + 20).clamp(0, 100), // Estimated improvement
        'details': {
          'recommendedTimeframe': _formatDate(suggestedDate),
          'reason': 'This destination is more suitable during $betterSeason',
        }
      });
    }
    
    return suggestions;
  }
  
  String _formatDate(DateTime date) {
    // Simple date formatter
    final month = _getMonthName(date.month);
    return '${date.day} $month ${date.year}';
  }
  
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
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
