import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String? imageUrl;
  final String type; // 'trip', 'system', 'alert', etc.
  final bool isRead;
  final Map<String, dynamic> data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.imageUrl,
    required this.type,
    this.isRead = false,
    this.data = const {},
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<NotificationModel> _notifications;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    // In a real app, fetch notifications from API or local database
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Mock notifications for demonstration
    _notifications = [
      NotificationModel(
        id: '1',
        title: 'Trip Reminder',
        message: 'Your trip to Paris starts tomorrow. Don\'t forget to pack!',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'trip',
        isRead: false,
        data: {
          'tripId': 'trip123',
        },
      ),
      NotificationModel(
        id: '2',
        title: 'Weather Alert',
        message: 'Expect rain in London during your stay. Pack an umbrella!',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: 'alert',
        isRead: true,
        data: {
          'tripId': 'trip456',
          'locationId': 'london123',
        },
      ),
      NotificationModel(
        id: '3',
        title: 'Special Offer',
        message: '50% off on activities in Barcelona for premium members!',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        type: 'promotion',
        isRead: true,
        data: {
          'promotionId': 'promo789',
        },
      ),
      NotificationModel(
        id: '4',
        title: 'New Feature Available',
        message: 'Try our new route optimization for better trip planning.',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        type: 'system',
        isRead: true,
      ),
      NotificationModel(
        id: '5',
        title: 'Trip Memory',
        message: 'One year ago today: Your amazing trip to Tokyo!',
        timestamp: DateTime.now().subtract(const Duration(days: 7)),
        type: 'memory',
        isRead: false,
        data: {
          'tripId': 'trip789',
        },
      ),
    ];
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            tooltip: 'Mark all as read',
            onPressed: () {
              // Mark all notifications as read
              setState(() {
                _notifications = _notifications.map((notification) {
                  return NotificationModel(
                    id: notification.id,
                    title: notification.title,
                    message: notification.message,
                    timestamp: notification.timestamp,
                    imageUrl: notification.imageUrl,
                    type: notification.type,
                    isRead: true,
                    data: notification.data,
                  );
                }).toList();
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState()
              : _buildNotificationsList(),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'You\'re all caught up! We\'ll notify you of important updates.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNotificationsList() {
    return ListView.builder(
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return Dismissible(
          key: Key(notification.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            setState(() {
              _notifications.removeAt(index);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notification removed'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            color: notification.isRead
                ? null
                : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              leading: _buildNotificationIcon(notification.type),
              title: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(notification.message),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(notification.timestamp),
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
              onTap: () {
                // Mark as read and navigate to related screen
                setState(() {
                  _notifications[index] = NotificationModel(
                    id: notification.id,
                    title: notification.title,
                    message: notification.message,
                    timestamp: notification.timestamp,
                    imageUrl: notification.imageUrl,
                    type: notification.type,
                    isRead: true,
                    data: notification.data,
                  );
                });
                
                // Handle navigation based on notification type
                _handleNotificationTap(notification);
              },
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildNotificationIcon(String type) {
    IconData iconData;
    Color iconColor;
    
    switch (type) {
      case 'trip':
        iconData = Icons.flight;
        iconColor = Colors.blue;
        break;
      case 'alert':
        iconData = Icons.warning_amber;
        iconColor = Colors.orange;
        break;
      case 'promotion':
        iconData = Icons.local_offer;
        iconColor = Colors.purple;
        break;
      case 'system':
        iconData = Icons.system_update;
        iconColor = Colors.green;
        break;
      case 'memory':
        iconData = Icons.photo_album;
        iconColor = Colors.pink;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }
    
    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.2),
      child: Icon(
        iconData,
        color: iconColor,
      ),
    );
  }
  
  void _handleNotificationTap(NotificationModel notification) {
    switch (notification.type) {
      case 'trip':
        if (notification.data.containsKey('tripId')) {
          Navigator.pushNamed(
            context,
            '/trip-details',
            arguments: notification.data['tripId'],
          );
        }
        break;
      case 'alert':
        if (notification.data.containsKey('tripId')) {
          Navigator.pushNamed(
            context,
            '/trip-details',
            arguments: notification.data['tripId'],
          );
        }
        break;
      case 'promotion':
        // Navigate to promotions page
        break;
      case 'system':
        // Navigate to settings or relevant screen
        break;
      case 'memory':
        if (notification.data.containsKey('tripId')) {
          Navigator.pushNamed(
            context,
            '/trip-details',
            arguments: notification.data['tripId'],
          );
        }
        break;
      default:
        // Do nothing or show details in a dialog
    }
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today, ${DateFormat.jm().format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${DateFormat.jm().format(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat.yMMMd().format(date);
    }
  }
}
