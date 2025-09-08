import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_optima_mobile_app/providers/auth_provider.dart';
import 'package:trip_optima_mobile_app/providers/location_provider.dart';
import 'package:trip_optima_mobile_app/models/location_model.dart';

class FavoriteLocationsScreen extends StatefulWidget {
  const FavoriteLocationsScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteLocationsScreen> createState() => _FavoriteLocationsScreenState();
}

class _FavoriteLocationsScreenState extends State<FavoriteLocationsScreen> {
  bool _isLoading = true;
  List<String> _categories = ['All', 'Cities', 'Nature', 'Hotels', 'Restaurants', 'Activities'];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadFavoriteLocations();
  }

  Future<void> _loadFavoriteLocations() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // Get the current user's favorite locations
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      
      if (authProvider.currentUser != null) {
        // Get favorite locations from user data
        final favoriteLocationIds = authProvider.currentUser!.favoriteLocations;
        
        // Load locations data
        await locationProvider.loadFavoriteLocations(favoriteLocationIds);
      }
    } catch (e) {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading favorite locations: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Places'),
      ),
      body: Column(
        children: [
          // Category filter tabs
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Favorites list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Consumer<LocationProvider>(
                    builder: (context, locationProvider, _) {
                      final favorites = locationProvider.favoriteLocations;
                      
                      if (favorites.isEmpty) {
                        return _buildEmptyState();
                      }
                      
                      // Filter by category if needed
                      final filteredLocations = _selectedCategory == 'All'
                          ? favorites
                          : favorites.where((loc) => 
                              loc.tags?.contains(_selectedCategory.toLowerCase()) ?? false).toList();
                      
                      if (filteredLocations.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.filter_alt_off,
                                size: 60,
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No places in this category',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedCategory = 'All';
                                  });
                                },
                                child: const Text('Show all favorites'),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return _buildLocationGrid(filteredLocations);
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No favorite places yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Save locations you love for easy access when planning trips',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/explore');
            },
            icon: const Icon(Icons.explore),
            label: const Text('Explore Places'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLocationGrid(List<LocationModel> locations) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];
        
        return GestureDetector(
          onTap: () {
            // Navigate to location details
            Navigator.pushNamed(
              context, 
              '/location-details',
              arguments: location,
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Location image
                location.imageUrl != null && location.imageUrl!.isNotEmpty
                    ? Image.network(
                        location.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 40,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.place,
                          size: 40,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                
                // Gradient overlay for text visibility
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                ),
                
                // Location information
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (location.address != null && location.address!.isNotEmpty)
                          Text(
                            location.address!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ),
                
                // Favorite button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      iconSize: 20,
                      constraints: const BoxConstraints(
                        minWidth: 30,
                        minHeight: 30,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        // Remove from favorites
                        final locationProvider = Provider.of<LocationProvider>(context, listen: false);
                        locationProvider.toggleFavorite(location);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Removed ${location.name} from favorites'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                locationProvider.toggleFavorite(location);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
