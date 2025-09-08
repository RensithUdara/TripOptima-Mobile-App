import 'package:flutter/material.dart';

import 'package:trip_optima_mobile_app/models/user_model.dart';
import 'package:trip_optima_mobile_app/providers/auth_provider.dart';
import 'package:trip_optima_mobile_app/providers/trip_provider.dart';
import 'package:trip_optima_mobile_app/views/profile/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load user profile data
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // Get auth provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Make sure user data is loaded
      if (authProvider.currentUser == null) {
        await authProvider.getUserProfile();
      }

      // Get trip provider
      final tripProvider = Provider.of<TripProvider>(context, listen: false);

      // Load user's trips statistics
      await tripProvider.loadUserTripsStats();
    } catch (e) {
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
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
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;

          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (user == null) {
            return _buildNotLoggedInView();
          }

          return _buildProfileView(user);
        },
      ),
    );
  }

  Widget _buildNotLoggedInView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle,
            size: 100,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Not Logged In',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('Please log in to view your profile'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Log In'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView(UserModel user) {
    return CustomScrollView(
      slivers: [
        // App bar
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(user.displayName ?? 'Your Profile'),
            background: Container(
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
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),

        // Profile content
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile image
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: user.photoUrl != null
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user.photoUrl == null
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: Theme.of(context).colorScheme.onPrimary,
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // User name
              Text(
                user.displayName ?? 'User',
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              // Email
              Text(
                user.email ?? '',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
              ),

              const SizedBox(height: 8),

              // Member since
              Text(
                'Member since ${_formatDate(user.createdAt)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 24),

              // Stats section
              Consumer<TripProvider>(
                builder: (context, tripProvider, _) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard(
                          context: context,
                          icon: Icons.map,
                          value: tripProvider.tripStats.totalTrips.toString(),
                          label: 'Trips',
                        ),
                        _buildStatCard(
                          context: context,
                          icon: Icons.location_on,
                          value: tripProvider.tripStats.totalDestinations
                              .toString(),
                          label: 'Places',
                        ),
                        _buildStatCard(
                          context: context,
                          icon: Icons.public,
                          value:
                              tripProvider.tripStats.totalCountries.toString(),
                          label: 'Countries',
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Divider
              const Divider(),

              // Edit profile button
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Profile'),
                onTap: () {
                  Navigator.pushNamed(context, '/edit-profile');
                },
              ),

              // Travel preferences
              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('Travel Preferences'),
                onTap: () {
                  Navigator.pushNamed(context, '/travel-preferences');
                },
              ),

              // Saved places
              ListTile(
                leading: const Icon(Icons.bookmark),
                title: const Text('Saved Places'),
                trailing: Consumer<TripProvider>(
                  builder: (context, tripProvider, _) {
                    return tripProvider.savedPlaces.isNotEmpty
                        ? Chip(
                            label: Text(
                                tripProvider.savedPlaces.length.toString()),
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          )
                        : null;
                  },
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/saved-places');
                },
              ),

              // Trip history
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Trip History'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/trip-history',
                    arguments: {'userId': user.id},
                  );
                },
              ),

              // Settings
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 365) {
      return '${difference.inDays} days ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    }
  }
}
