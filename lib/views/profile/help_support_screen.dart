import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Support options
            _buildSectionHeader(context, 'Contact Support'),
            const SizedBox(height: 16),
            
            _buildContactCard(
              context,
              title: 'Email Support',
              description: 'Get help via email. We usually respond within 24 hours.',
              icon: Icons.email_outlined,
              onTap: () {
                // Launch email
              },
            ),
            
            _buildContactCard(
              context,
              title: 'Live Chat',
              description: 'Chat with our support team for immediate assistance.',
              icon: Icons.chat_outlined,
              onTap: () {
                // Launch chat
              },
            ),
            
            _buildContactCard(
              context,
              title: 'Help Center',
              description: 'Browse our help articles and tutorials.',
              icon: Icons.help_outline,
              onTap: () {
                // Open help center
              },
            ),
            
            const SizedBox(height: 32),
            
            // FAQs section
            _buildSectionHeader(context, 'Frequently Asked Questions'),
            const SizedBox(height: 16),
            
            _buildFaqItem(
              context,
              question: 'How do I create a new trip?',
              answer: 'To create a new trip, go to the Trips tab and tap the + button in the '
                  'bottom right corner. Fill in your trip details including destination, dates, '
                  'and preferences, then tap "Create Trip".',
            ),
            
            _buildFaqItem(
              context,
              question: 'Can I share my trip with friends?',
              answer: 'Yes! Open any trip, tap the share icon in the top right corner, '
                  'and choose how you want to share your trip. You can share via email, '
                  'messaging apps, or generate a shareable link.',
            ),
            
            _buildFaqItem(
              context,
              question: 'How does the weather feature work?',
              answer: 'TripOptima automatically fetches weather forecasts for your trip dates '
                  'and destinations. We show you the expected conditions to help you pack '
                  'appropriately and plan outdoor activities. For trips further in the future, '
                  'we show historical weather patterns.',
            ),
            
            _buildFaqItem(
              context,
              question: 'How can I optimize my route?',
              answer: 'When viewing your trip details, go to the Route tab and tap "Optimize Route". '
                  'The app will automatically rearrange your destinations to create the most '
                  'efficient travel path based on distance and travel time.',
            ),
            
            _buildFaqItem(
              context,
              question: 'Can I use the app offline?',
              answer: 'Yes, many features work offline. You can view and edit your trips without '
                  'an internet connection. However, features like maps, weather forecasts, and '
                  'location search require an internet connection to update.',
            ),
            
            const SizedBox(height: 32),
            
            // Troubleshooting
            _buildSectionHeader(context, 'Troubleshooting'),
            const SizedBox(height: 16),
            
            _buildExpandableTroubleshootingTile(
              context,
              title: 'App is crashing',
              steps: [
                'Make sure your app is updated to the latest version',
                'Restart your device',
                'Check for system updates',
                'If the problem persists, try uninstalling and reinstalling the app',
              ],
            ),
            
            _buildExpandableTroubleshootingTile(
              context,
              title: 'Can\'t log in to my account',
              steps: [
                'Check your internet connection',
                'Make sure your email and password are correct',
                'Try resetting your password',
                'Check if you\'re using the correct social login method',
              ],
            ),
            
            _buildExpandableTroubleshootingTile(
              context,
              title: 'Maps not loading correctly',
              steps: [
                'Check your internet connection',
                'Ensure location permissions are granted',
                'Restart the app',
                'Clear the app cache in your device settings',
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Feedback section
            _buildSectionHeader(context, 'Send Feedback'),
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'We\'d love to hear your thoughts on how we can improve the app!',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Type your feedback here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Submit feedback
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Thank you for your feedback!'),
                            ),
                          );
                        },
                        child: const Text('Submit Feedback'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 100,
          height: 3,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }
  
  Widget _buildContactCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
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
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFaqItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildExpandableTroubleshootingTile(
    BuildContext context, {
    required String title,
    required List<String> steps,
  }) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: steps
                .asMap()
                .entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${entry.key + 1}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(entry.value),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
