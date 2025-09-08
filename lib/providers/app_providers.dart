import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trip_optima_mobile_app/providers/auth_provider.dart';
import 'package:trip_optima_mobile_app/providers/location_provider.dart';
import 'package:trip_optima_mobile_app/providers/trip_provider.dart';
import 'package:trip_optima_mobile_app/providers/route_provider.dart';
import 'package:trip_optima_mobile_app/providers/weather_provider.dart';
import 'package:trip_optima_mobile_app/providers/scoring_provider.dart';
import 'package:trip_optima_mobile_app/providers/ui_provider.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // UI provider should be first as other providers may need to update UI state
        ChangeNotifierProvider(create: (_) => UIProvider()),
        
        // Auth provider should be before other data providers
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        
        // Location provider
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        
        // Core data providers
        ChangeNotifierProvider(create: (_) => TripProvider()),
        ChangeNotifierProvider(create: (_) => RouteProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        
        // Scoring provider depends on several other providers
        ChangeNotifierProvider(create: (_) => ScoringProvider()),
      ],
      child: child,
    );
  }
}
