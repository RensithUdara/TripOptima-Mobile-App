import 'package:flutter/material.dart';
import 'package:trip_optima_mobile_app/constants/app_config.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About TripOptima'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            
            // App logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.map,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // App name and version
            Text(
              AppConfig.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version ${AppConfig.appVersion}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // App description
            const Text(
              'TripOptima is an intelligent travel planning app that helps you create optimized '
              'trip itineraries based on your preferences, weather conditions, and travel constraints.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            
            const SizedBox(height: 40),
            
            // Features section
            _buildSectionTitle(context, 'Key Features'),
            const SizedBox(height: 16),
            _buildFeatureItem(
              context,
              icon: Icons.route,
              title: 'Optimized Routes',
              description: 'Create the most efficient travel routes between destinations',
            ),
            _buildFeatureItem(
              context,
              icon: Icons.wb_sunny,
              title: 'Weather Integration',
              description: 'Plan your trips around optimal weather conditions',
            ),
            _buildFeatureItem(
              context,
              icon: Icons.map,
              title: 'Interactive Maps',
              description: 'Visualize your entire journey with detailed maps',
            ),
            _buildFeatureItem(
              context,
              icon: Icons.access_time,
              title: 'Time Management',
              description: 'Balance your itinerary to make the most of your trip',
            ),
            
            const SizedBox(height: 40),
            
            // Development team
            _buildSectionTitle(context, 'Development Team'),
            const SizedBox(height: 16),
            const Text(
              'TripOptima is developed with ❤️ by a team of passionate developers and travel enthusiasts.',
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            // Legal information
            _buildSectionTitle(context, 'Legal'),
            const SizedBox(height: 16),
            _buildLegalButton(
              context, 
              'Terms of Service',
              onTap: () => _openWebPage(context, 'https://tripoptima.com/terms'),
            ),
            _buildLegalButton(
              context, 
              'Privacy Policy',
              onTap: () => _openWebPage(context, 'https://tripoptima.com/privacy'),
            ),
            _buildLegalButton(
              context, 
              'Licenses',
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationName: AppConfig.appName,
                  applicationVersion: AppConfig.appVersion,
                );
              },
            ),
            
            const SizedBox(height: 40),
            
            // Contact section
            _buildSectionTitle(context, 'Contact Us'),
            const SizedBox(height: 16),
            const Text(
              'Have questions or feedback? We\'d love to hear from you!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialButton(
                  context,
                  icon: Icons.email_outlined,
                  onTap: () => _launchEmail('support@tripoptima.com'),
                ),
                const SizedBox(width: 16),
                _buildSocialButton(
                  context,
                  icon: Icons.web_outlined,
                  onTap: () => _openWebPage(context, 'https://tripoptima.com'),
                ),
                const SizedBox(width: 16),
                _buildSocialButton(
                  context,
                  icon: Icons.facebook_outlined,
                  onTap: () => _openWebPage(context, 'https://facebook.com/tripoptima'),
                ),
                const SizedBox(width: 16),
                _buildSocialButton(
                  context,
                  icon: Icons.chat_outlined,
                  onTap: () {
                    // Open in-app support chat
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Copyright notice
            Text(
              '© ${DateTime.now().year} TripOptima. All rights reserved.',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: 3,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }
  
  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLegalButton(
    BuildContext context,
    String title, {
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextButton(
        onPressed: onTap,
        child: Text(title),
      ),
    );
  }
  
  Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onTap,
      ),
    );
  }
  
  Future<void> _openWebPage(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Show error
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open the page'),
            ),
          );
        }
      }
    } catch (e) {
      // Show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
          ),
        );
      }
    }
  }
  
  Future<void> _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'TripOptima App Inquiry',
      },
    );
    
    try {
      await launchUrl(emailLaunchUri);
    } catch (e) {
      // Handle error
    }
  }
}
