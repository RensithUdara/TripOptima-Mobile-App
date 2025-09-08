import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trip_optima_mobile_app/models/trip_model.dart';
import 'package:trip_optima_mobile_app/models/weather_model.dart';
import                    ...List.generate(
                    forecast?.length != null ? (forecast!.length > 5 ? 5 : forecast.length) : 0,
                    (index) {ackage:trip_optima_mobile_app/providers/weather_provider.dart';

class TripWeatherView extends StatefulWidget {
  final TripModel trip;

  const TripWeatherView({
    super.key,
    required this.trip,
  });

  @override
  State<TripWeatherView> createState() => _TripWeatherViewState();
}

class _TripWeatherViewState extends State<TripWeatherView> {
  int _selectedDestinationIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch weather data for the first destination if needed
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    if (widget.trip.destinations.isEmpty) return;

    final weatherProvider =
        Provider.of<WeatherProvider>(context, listen: false);

    try {
      final selectedDestination =
          widget.trip.destinations[_selectedDestinationIndex];
      await weatherProvider.getWeatherForecast(
        selectedDestination.latitude,
        selectedDestination.longitude,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load weather data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.trip.destinations.length > 1) _buildDestinationSelector(),
        Expanded(
          child: Consumer<WeatherProvider>(
            builder: (context, weatherProvider, _) {
              if (weatherProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (weatherProvider.weatherData == null ||
                  weatherProvider.forecast == null ||
                  weatherProvider.forecast!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_off,
                        size: 64,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Weather data not available',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text('Please try again later'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchWeatherData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return _buildWeatherContent(weatherProvider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(widget.trip.destinations.length, (index) {
            final destination = widget.trip.destinations[index];
            final isSelected = index == _selectedDestinationIndex;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(destination.name),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _selectedDestinationIndex = index;
                  });
                  _fetchWeatherData();
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildWeatherContent(WeatherProvider weatherProvider) {
    final currentWeather = weatherProvider.weatherData!;
    final forecast = weatherProvider.forecast!;
    final selectedDestination =
        widget.trip.destinations[_selectedDestinationIndex];

    return RefreshIndicator(
      onRefresh: _fetchWeatherData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Current weather card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location and date
                  Row(
                    children: [
                      const Icon(Icons.location_on),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selectedDestination.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Text(
                        DateFormat('E, MMM d').format(DateTime.now()),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Current weather
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Temperature and conditions
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${currentWeather.temperature.toStringAsFixed(1)}°C',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            currentWeather.description,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Feels like ${currentWeather.feelsLike.toStringAsFixed(1)}°C',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),

                      // Weather icon
                      Icon(
                        _getWeatherIcon(currentWeather.condition),
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Weather details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildWeatherDetail(
                        icon: Icons.water_drop,
                        label: 'Humidity',
                        value: '${currentWeather.humidity}%',
                      ),
                      _buildWeatherDetail(
                        icon: Icons.air,
                        label: 'Wind',
                        value: '${currentWeather.windSpeed} km/h',
                      ),
                      _buildWeatherDetail(
                        icon: Icons.visibility,
                        label: 'Visibility',
                        value:
                            '${(currentWeather.visibility / 1000).toStringAsFixed(1)} km',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Daily forecast
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '5-Day Forecast',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  ...List.generate(
                    forecast.length > 5 ? 5 : forecast.length,
                    (index) {
                      final day = forecast[index];
                      final date = day?.timestamp ?? DateTime.now();

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            // Day
                            SizedBox(
                              width: 100,
                              child: Text(
                                index == 0
                                    ? 'Today'
                                    : DateFormat('EEEE').format(date),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),

                            // Icon
                            Icon(
                              _getWeatherIcon(day?.condition ?? 'Unknown'),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 16),

                            // Description
                            Expanded(
                              child: Text(day?.description ?? 'No description'),
                            ),

                            // Temperature
                            Row(
                              children: [
                                Text(
                                  '${day != null ? day.maxTemp.toStringAsFixed(0) : 'N/A'}°',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${day != null ? day.minTemp.toStringAsFixed(0) : 'N/A'}°',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Hourly forecast
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hourly Forecast',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: weatherProvider.hourlyForecast?.length ?? 0,
                      itemBuilder: (context, index) {
                        final hourlyData =
                            weatherProvider.hourlyForecast![index];
                        final hour = hourlyData.timestamp;

                        return Container(
                          width: 80,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: [
                              // Hour
                              Text(
                                DateFormat('h a').format(hour),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),

                              // Icon
                              Icon(
                                _getWeatherIcon(hourlyData.condition),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 8),

                              // Temperature
                              Text(
                                '${hourlyData.temperature.toStringAsFixed(0)}°C',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Weather note
          const SizedBox(height: 16),
          Text(
            'Weather data last updated: ${DateFormat('MMM d, yyyy h:mm a').format(weatherProvider.lastUpdated ?? DateTime.now())}',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
      case 'sunny':
        return Icons.wb_sunny;
      case 'clouds':
      case 'partly cloudy':
      case 'mostly cloudy':
        return Icons.cloud;
      case 'rain':
      case 'light rain':
      case 'moderate rain':
      case 'heavy rain':
        return Icons.grain;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snow':
      case 'light snow':
      case 'moderate snow':
      case 'heavy snow':
        return Icons.ac_unit;
      case 'mist':
      case 'fog':
      case 'haze':
        return Icons.cloud_queue;
      default:
        return Icons.wb_cloudy;
    }
  }
}
