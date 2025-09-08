import 'package:flutter/foundation.dart';
import 'package:trip_optima_mobile_app/models/weather_model.dart';
import 'package:trip_optima_mobile_app/models/location_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:trip_optima_mobile_app/constants/app_config.dart';

class WeatherProvider with ChangeNotifier {
  Map<String, WeatherModel> _weatherCache = {};
  bool _isLoading = false;
  String? _errorMessage;
  WeatherModel? _currentWeatherData;
  Map<String, WeatherModel>? _forecast;
  List<WeatherModel>? _hourlyForecast;
  DateTime? _lastUpdated;
  
  final _uuid = const Uuid();
  
  // Cache TTL in milliseconds (30 minutes)
  final int _cacheTtl = 30 * 60 * 1000;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, WeatherModel> get weatherCache => _weatherCache;
  WeatherModel? get weatherData => _currentWeatherData;
  Map<String, WeatherModel>? get forecast => _forecast;
  List<WeatherModel>? get hourlyForecast => _hourlyForecast;
  DateTime? get lastUpdated => _lastUpdated;
  
  // Get current weather for a location
  Future<WeatherModel?> getCurrentWeather(LocationModel location) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Check cache first
      final cacheKey = _generateWeatherCacheKey(location);
      final cachedWeather = _getCachedWeather(cacheKey);
      
      if (cachedWeather != null) {
        _setLoading(false);
        return cachedWeather;
      }
      
      // Fetch from API if not cached
      final weather = await _fetchWeatherData(location);
      
      if (weather != null) {
        // Cache the result
        _weatherCache[cacheKey] = weather;
        
        notifyListeners();
        _setLoading(false);
        return weather;
      }
      
      _handleError('Failed to get weather data');
      return null;
    } catch (e) {
      _handleError('Weather fetch error: ${e.toString()}');
      return null;
    }
  }
  
  // Get forecast for multiple days
  Future<Map<String, WeatherModel>?> getForecast(LocationModel location, int days) async {
    _setLoading(true);
    _clearError();
    
    try {
      final Map<String, WeatherModel> forecast = {};
      
      // Build URL for forecast API
      final url = Uri.parse(
        '${AppConfig.weatherApiBaseUrl}/forecast?'
        'lat=${location.latitude}&lon=${location.longitude}'
        '&cnt=$days'
        '&units=metric'
        '&appid=${AppConfig.weatherApiKey}'
      );
      
      // Make request
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Parse forecast data for each day
        for (var item in data['list']) {
          final timestamp = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
          final dateKey = timestamp.toIso8601String().substring(0, 10);
          
          final weather = _parseWeatherData(item, location);
          forecast[dateKey] = weather;
        }
        
        _setLoading(false);
        return forecast;
      }
      
      _handleError('Failed to get forecast data');
      return null;
    } catch (e) {
      _handleError('Forecast fetch error: ${e.toString()}');
      return null;
    }
  }
  
  // Get hourly forecast
  Future<List<WeatherModel>?> getHourlyForecast(LocationModel location, int hours) async {
    _setLoading(true);
    _clearError();
    
    try {
      final List<WeatherModel> hourlyForecast = [];
      
      // Build URL for hourly forecast API
      final url = Uri.parse(
        '${AppConfig.weatherApiBaseUrl}/forecast?'
        'lat=${location.latitude}&lon=${location.longitude}'
        '&cnt=$hours'
        '&units=metric'
        '&appid=${AppConfig.weatherApiKey}'
      );
      
      // Make request
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Parse hourly forecast data
        for (var item in data['list']) {
          final weather = _parseWeatherData(item, location);
          hourlyForecast.add(weather);
        }
        
        _setLoading(false);
        return hourlyForecast;
      }
      
      _handleError('Failed to get hourly forecast data');
      return null;
    } catch (e) {
      _handleError('Hourly forecast fetch error: ${e.toString()}');
      return null;
    }
  }
  
  // Get historical weather data
  Future<WeatherModel?> getHistoricalWeather(LocationModel location, DateTime date) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Convert date to Unix timestamp
      final unixTimestamp = (date.millisecondsSinceEpoch / 1000).round();
      
      // Build URL for historical weather API
      final url = Uri.parse(
        '${AppConfig.weatherApiBaseUrl}/onecall/timemachine?'
        'lat=${location.latitude}&lon=${location.longitude}'
        '&dt=$unixTimestamp'
        '&units=metric'
        '&appid=${AppConfig.weatherApiKey}'
      );
      
      // Make request
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data.containsKey('current')) {
          final weather = _parseWeatherData(data['current'], location);
          
          _setLoading(false);
          return weather;
        }
      }
      
      _handleError('Failed to get historical weather data');
      return null;
    } catch (e) {
      _handleError('Historical weather fetch error: ${e.toString()}');
      return null;
    }
  }
  
  // Get weather alerts for a location
  Future<List<Map<String, dynamic>>?> getWeatherAlerts(LocationModel location) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Build URL for weather alerts API
      final url = Uri.parse(
        '${AppConfig.weatherApiBaseUrl}/onecall?'
        'lat=${location.latitude}&lon=${location.longitude}'
        '&exclude=minutely,hourly,daily'
        '&units=metric'
        '&appid=${AppConfig.weatherApiKey}'
      );
      
      // Make request
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data.containsKey('alerts')) {
          final alerts = List<Map<String, dynamic>>.from(data['alerts']);
          
          _setLoading(false);
          return alerts;
        } else {
          // No alerts
          _setLoading(false);
          return [];
        }
      }
      
      _handleError('Failed to get weather alerts');
      return null;
    } catch (e) {
      _handleError('Weather alerts fetch error: ${e.toString()}');
      return null;
    }
  }
  
  // Clear weather cache
  void clearWeatherCache() {
    _weatherCache.clear();
    notifyListeners();
  }
  
  // Remove specific location from cache
  void removeFromCache(LocationModel location) {
    final cacheKey = _generateWeatherCacheKey(location);
    _weatherCache.remove(cacheKey);
    notifyListeners();
  }
  
  // Check if weather is suitable for travel
  bool isWeatherSuitableForTravel(WeatherModel weather) {
    // Simple implementation - can be expanded with more complex logic
    final badConditions = [
      'thunderstorm', 'tornado', 'hurricane', 'blizzard', 'heavy snow',
      'freezing rain', 'heavy rain', 'heavy intensity rain', 'flood'
    ];
    
    final condition = weather.condition.toLowerCase();
    
    // Check for bad weather conditions
    if (badConditions.any((term) => condition.contains(term))) {
      return false;
    }
    
    // Check temperature extremes
    if (weather.temperature < -10 || weather.temperature > 40) {
      return false;
    }
    
    // Check for high winds
    if (weather.windSpeed > 15) {  // 15 m/s is around 54 km/h
      return false;
    }
    
    return true;
  }
  
  // Get weather suitability score (0-100)
  int getWeatherSuitabilityScore(WeatherModel weather) {
    int score = 100;
    
    // Condition factors
    final badConditions = {
      'thunderstorm': -40,
      'tornado': -100,
      'hurricane': -100,
      'blizzard': -80,
      'heavy snow': -60,
      'freezing rain': -70,
      'heavy rain': -50,
      'moderate rain': -30,
      'light rain': -10,
      'drizzle': -5,
      'fog': -20,
      'mist': -10,
      'haze': -15,
    };
    
    // Check weather condition and apply penalty
    for (final entry in badConditions.entries) {
      if (weather.condition.toLowerCase().contains(entry.key)) {
        score += entry.value;
        break;
      }
    }
    
    // Temperature factors (ideal range: 15-25°C)
    if (weather.temperature < 0) {
      score -= (0 - weather.temperature).round() * 3; // Colder = worse
    } else if (weather.temperature < 10) {
      score -= (10 - weather.temperature).round();
    } else if (weather.temperature > 30) {
      score -= (weather.temperature - 30).round() * 2; // Hotter = worse
    }
    
    // Wind factors
    if (weather.windSpeed > 10) {
      score -= ((weather.windSpeed - 10) * 3).round();
    }
    
    // Visibility factors
    if (weather.visibility < 5000) { // Less than 5km visibility
      score -= ((5000 - weather.visibility) / 100).round();
    }
    
    // UV Index factors
    if (weather.uvIndex > 8) {
      score -= ((weather.uvIndex - 8) * 5).round();
    }
    
    // Cap the score between 0 and 100
    return score.clamp(0, 100);
  }
  
  // Private helper methods
  Future<WeatherModel?> _fetchWeatherData(LocationModel location) async {
    try {
      // Build URL for current weather API
      final url = Uri.parse(
        '${AppConfig.weatherApiBaseUrl}/weather?'
        'lat=${location.latitude}&lon=${location.longitude}'
        '&units=metric'
        '&appid=${AppConfig.weatherApiKey}'
      );
      
      // Make request
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseWeatherData(data, location);
      }
      
      _handleError('Weather API error: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      _handleError('Weather API request failed: ${e.toString()}');
      return null;
    }
  }
  
  WeatherModel _parseWeatherData(dynamic data, LocationModel location) {
    // Parse weather condition
    final condition = data['weather']?[0]?['main'] ?? 'Unknown';
    final description = data['weather']?[0]?['description'] ?? 'Unknown';
    
    // Parse temperatures
    final temperature = data['main']?['temp']?.toDouble() ?? 0.0;
    final feelsLike = data['main']?['feels_like']?.toDouble() ?? 0.0;
    
    // Parse wind
    final windSpeed = data['wind']?['speed']?.toDouble() ?? 0.0;
    final windDirection = data['wind']?['deg'] ?? 0;
    
    // Parse other data
    final humidity = data['main']?['humidity']?.toDouble() ?? 0.0;
    final pressure = data['main']?['pressure']?.toDouble() ?? 0.0;
    final cloudCover = data['clouds']?['all'] ?? 0;
    final visibility = data['visibility']?.toDouble() ?? 0.0;
    
    // Parse precipitation (if available)
    double precipitation = 0.0;
    if (data.containsKey('rain')) {
      precipitation = data['rain']?['1h']?.toDouble() ?? 0.0;
    } else if (data.containsKey('snow')) {
      precipitation = data['snow']?['1h']?.toDouble() ?? 0.0;
    }
    
    // Parse UV index (if available)
    double uvIndex = 0.0;
    if (data.containsKey('uvi')) {
      uvIndex = data['uvi']?.toDouble() ?? 0.0;
    }
    
    // Parse sunrise/sunset
    DateTime sunrise;
    DateTime sunset;
    
    if (data.containsKey('sys') && data['sys'].containsKey('sunrise')) {
      sunrise = DateTime.fromMillisecondsSinceEpoch(data['sys']['sunrise'] * 1000);
      sunset = DateTime.fromMillisecondsSinceEpoch(data['sys']['sunset'] * 1000);
    } else {
      sunrise = DateTime.now();
      sunset = DateTime.now().add(const Duration(hours: 12));
    }
    
    // Create timestamp
    DateTime timestamp;
    if (data.containsKey('dt')) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(data['dt'] * 1000);
    } else {
      timestamp = DateTime.now();
    }
    
    // Create weather model
    return WeatherModel(
      id: _uuid.v4(),
      locationId: location.id,
      timestamp: timestamp,
      condition: condition,
      description: description,
      icon: icon,
      temperature: temperature,
      feelsLike: feelsLike,
      minTemp: temperature - 2.0, // Placeholder
      maxTemp: temperature + 2.0, // Placeholder
      windSpeed: windSpeed,
      windDirection: windDirection.toDouble(),
      humidity: humidity,
      pressure: pressure,
      visibility: visibility,
      clouds: cloudCover.toDouble(),
      rain: precipitation,
      snow: 0.0, // Placeholder
    );
  }
  
  String _generateWeatherCacheKey(LocationModel location) {
    return '${location.latitude},${location.longitude}';
  }
  
  WeatherModel? _getCachedWeather(String cacheKey) {
    if (!_weatherCache.containsKey(cacheKey)) {
      return null;
    }
    
    final cachedWeather = _weatherCache[cacheKey]!;
    final now = DateTime.now();
    final cacheAge = now.difference(cachedWeather.timestamp).inMilliseconds;
    
    // Return cached data if it's still valid
    if (cacheAge < _cacheTtl) {
      return cachedWeather;
    }
    
    // Remove expired data
    _weatherCache.remove(cacheKey);
    return null;
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
  
  // Get weather forecast for a specific location by coordinates
  Future<void> getWeatherForecast(double latitude, double longitude) async {
    _setLoading(true);
    _clearError();
    
    try {
      final location = LocationModel(
        id: _uuid.v4(), 
        name: 'Location', 
        address: '', 
        latitude: latitude, 
        longitude: longitude,
        placeId: '',
        imageUrl: '',
        tags: [],
      );
      
      // Get current weather
      _currentWeatherData = await getCurrentWeather(location);
      
      // Get daily forecast
      _forecast = await getForecast(location, 7);
      
      // Get hourly forecast (simulated with current API)
      await _fetchHourlyForecast(location);
      
      // Update last updated timestamp
      _lastUpdated = DateTime.now();
      
      notifyListeners();
    } catch (e) {
      _handleError('Weather forecast error: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Get hourly forecast for a location
  Future<void> _fetchHourlyForecast(LocationModel location) async {
    try {
      // Build URL for hourly forecast API
      final url = Uri.parse(
        '${AppConfig.weatherApiBaseUrl}/forecast?'
        'lat=${location.latitude}&lon=${location.longitude}'
        '&cnt=24'  // 24 hours
        '&units=metric'
        '&appid=${AppConfig.weatherApiKey}'
      );
      
      // Make request
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<WeatherModel> hourly = [];
        
        // Parse hourly forecast data
        for (var item in data['list']) {
          final weather = _parseWeatherData(item, location);
          hourly.add(weather);
        }
        
        _hourlyForecast = hourly;
      } else {
        _hourlyForecast = [];
      }
    } catch (e) {
      _hourlyForecast = [];
      print('Error fetching hourly forecast: ${e.toString()}');
    }
  }
}
