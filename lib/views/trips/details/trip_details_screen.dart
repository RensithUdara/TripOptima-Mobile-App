import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trip_optima_mobile_app/models/trip_model.dart';
import 'package:trip_optima_mobile_app/providers/route_provider.dart';
import 'package:trip_optima_mobile_app/providers/trip_provider.dart';
import 'package:trip_optima_mobile_app/providers/weather_provider.dart';
import 'package:trip_optima_mobile_app/views/map/trip_map_view.dart';
import 'package:trip_optima_mobile_app/views/weather/trip_weather_view.dart';

class TripDetailsScreen extends StatefulWidget {
  final TripModel trip;

  const TripDetailsScreen({
    super.key,
    required this.trip,
  });

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load trip data when the screen initializes
    _loadTripData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTripData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get providers
      final routeProvider = Provider.of<RouteProvider>(context, listen: false);
      final weatherProvider =
          Provider.of<WeatherProvider>(context, listen: false);

      // Load route information
      await routeProvider.loadRouteForTrip(widget.trip.id);

      // Load weather information
      if (widget.trip.destinations.isNotEmpty) {
        await weatherProvider.getWeatherForecast(
          widget.trip.destinations.first.latitude,
          widget.trip.destinations.first.longitude,
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading trip data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(widget.trip.name),
                background: _buildHeaderImage(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/edit-trip',
                      arguments: widget.trip,
                    );
                  },
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'share',
                      child: Text('Share Trip'),
                    ),
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: Text('Duplicate Trip'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete Trip'),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'share':
                        // Handle share
                        break;
                      case 'duplicate':
                        _duplicateTrip();
                        break;
                      case 'delete':
                        _confirmDeleteTrip();
                        break;
                    }
                  },
                ),
              ],
            ),
            SliverPersistentHeader(
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Itinerary'),
                    Tab(text: 'Map'),
                    Tab(text: 'Weather'),
                  ],
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildItineraryTab(),
            TripMapView(trip: widget.trip),
            TripWeatherView(trip: widget.trip),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add activity/itinerary item
          Navigator.pushNamed(
            context,
            '/add-activity',
            arguments: widget.trip,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeaderImage() {
    if (widget.trip.metadata['coverImageUrl'] != null &&
        widget.trip.metadata['coverImageUrl'].isNotEmpty) {
      return Image.network(
        widget.trip.metadata['coverImageUrl'],
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultHeaderBackground();
        },
      );
    }
    return _buildDefaultHeaderBackground();
  }

  Widget _buildDefaultHeaderBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.map,
          size: 80,
          color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Trip score card
        if (widget.trip.tripScore != null) _buildScoreCard(),

        const SizedBox(height: 16),

        // Trip summary
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trip Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                const SizedBox(height: 8),

                // Trip dates
                Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _formatDateRange(
                            widget.trip.startDate, widget.trip.endDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Trip duration
                Row(
                  children: [
                    const Icon(Icons.timelapse),
                    const SizedBox(width: 8),
                    Text(
                      '${_calculateDuration(widget.trip.startDate, widget.trip.endDate)} days',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Trip destinations
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Destinations',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          ...widget.trip.destinations.map((location) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  '• ${location.name}',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.8),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),

                if (widget.trip.description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    widget.trip.description,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Weather overview
        Consumer<WeatherProvider>(
          builder: (context, weatherProvider, _) {
            if (weatherProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (weatherProvider.weatherData == null) {
              return const SizedBox.shrink();
            }

            final currentWeather = weatherProvider.weatherData!;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.wb_sunny_outlined),
                        const SizedBox(width: 8),
                        const Text(
                          'Weather Forecast',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            _tabController
                                .animateTo(3); // Navigate to Weather tab
                          },
                          child: const Text('View Details'),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Weather summary
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        _getWeatherIcon(currentWeather.condition),
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(
                        '${currentWeather.temperature.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        currentWeather.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Route summary
        Consumer<RouteProvider>(
          builder: (context, routeProvider, _) {
            if (routeProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (routeProvider.currentRoute == null) {
              return const SizedBox.shrink();
            }

            final route = routeProvider.currentRoute!;

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.route),
                        const SizedBox(width: 8),
                        const Text(
                          'Route Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            _tabController.animateTo(2); // Navigate to Map tab
                          },
                          child: const Text('View Map'),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Route details
                    Row(
                      children: [
                        const Icon(Icons.straighten),
                        const SizedBox(width: 8),
                        Text(
                          'Total Distance: ${(route.totalDistance / 1000).toStringAsFixed(1)} km',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Icon(Icons.timer),
                        const SizedBox(width: 8),
                        Text(
                          'Travel Time: ${_formatDuration(route.totalDuration)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildItineraryTab() {
    // This would fetch and display the trip's itinerary/activities
    return const Center(
      child: Text('Itinerary will be displayed here'),
    );
  }

  Widget _buildScoreCard() {
    final score = widget.trip.tripScore!;

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getScoreColor(score),
                shape: BoxShape.circle,
              ),
              child: Text(
                score.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getScoreDescription(score),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getScoreTips(score),
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _duplicateTrip() async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);

    try {
      await tripProvider.duplicateTrip(widget.trip.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip duplicated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error duplicating trip: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteTrip() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trip'),
        content: Text(
            'Are you sure you want to delete "${widget.trip.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      final tripProvider = Provider.of<TripProvider>(context, listen: false);

      try {
        await tripProvider.deleteTrip(widget.trip.id);

        if (mounted) {
          Navigator.pop(context); // Go back to previous screen
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting trip: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _formatDateRange(DateTime start, DateTime? end) {
    final formatter = DateFormat('MMM d, yyyy');
    if (end == null || start == end) {
      return formatter.format(start);
    }
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }

  int _calculateDuration(DateTime start, DateTime? end) {
    if (end == null) {
      return 1;
    }
    return end.difference(start).inDays + 1;
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    return '$hours hr ${minutes.toString().padLeft(2, '0')} min';
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

  Color _getScoreColor(double score) {
    if (score >= 9) return Colors.green;
    if (score >= 7) return Colors.lightGreen;
    if (score >= 5) return Colors.amber;
    if (score >= 3) return Colors.orange;
    return Colors.red;
  }

  String _getScoreDescription(double score) {
    if (score >= 9) return 'Excellent Trip Plan';
    if (score >= 7) return 'Very Good Trip Plan';
    if (score >= 5) return 'Good Trip Plan';
    if (score >= 3) return 'Fair Trip Plan';
    return 'Needs Improvement';
  }

  String _getScoreTips(double score) {
    if (score >= 9) return 'Perfect balance of activities, routes, and timing!';
    if (score >= 7) return 'Great plan with minor improvements possible.';
    if (score >= 5)
      return 'Consider optimizing your route or adding rest days.';
    if (score >= 3)
      return 'Review your timing and distances between destinations.';
    return 'Consider reworking your plan for better experience.';
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
