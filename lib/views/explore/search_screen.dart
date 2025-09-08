import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_optima_mobile_app/providers/location_provider.dart';
import 'package:trip_optima_mobile_app/models/location_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search for places...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          autofocus: true,
          onChanged: (query) {
            if (query.length >= 3) {
              setState(() {
                _searchQuery = query;
                _isSearching = true;
              });
              _performSearch(query);
            } else if (query.isEmpty) {
              setState(() {
                _searchQuery = '';
                _isSearching = false;
              });
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _isSearching = false;
              });
            },
          ),
        ],
      ),
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, _) {
          if (_searchQuery.isEmpty) {
            return _buildSearchPrompt();
          }
          
          if (_isSearching && locationProvider.isSearching) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (locationProvider.searchResults.isEmpty) {
            return _buildNoResultsFound();
          }
          
          return _buildSearchResults(locationProvider.searchResults);
        },
      ),
    );
  }
  
  void _performSearch(String query) {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    locationProvider.searchLocations(query);
  }
  
  Widget _buildSearchPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Search for destinations',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Enter a city, country, or point of interest to start exploring',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoResultsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Try a different search term or explore popular destinations',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Show popular destinations
            },
            child: const Text('Explore Popular Destinations'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchResults(List<LocationModel> results) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final location = results[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.location_on,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(location.name),
            subtitle: location.address != null 
                ? Text(location.address!) 
                : null,
            trailing: IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: () {
                // Save to favorites
              },
            ),
            onTap: () {
              Navigator.pop(context, location);
            },
          ),
        );
      },
    );
  }
}
