import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trip_optima_mobile_app/models/trip_model.dart';
import 'package:trip_optima_mobile_app/providers/route_provider.dart';

class TripMapView extends StatefulWidget {
  final TripModel trip;

  const TripMapView({
    super.key,
    required this.trip,
  });

  @override
  State<TripMapView> createState() => _TripMapViewState();
}

class _TripMapViewState extends State<TripMapView> {
  GoogleMapController? _mapController;
  bool _mapReady = false;
  Map<String, Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    // Setup markers and polylines once map is ready
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map view
        GoogleMap(
          initialCameraPosition: _getInitialCameraPosition(),
          onMapCreated: _onMapCreated,
          markers: Set<Marker>.of(_markers.values),
          polylines: _polylines,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: true,
        ),

        // Controls
        Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            children: [
              // Zoom in
              FloatingActionButton(
                heroTag: 'zoomIn',
                mini: true,
                onPressed: () {
                  _mapController?.animateCamera(CameraUpdate.zoomIn());
                },
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),

              // Zoom out
              FloatingActionButton(
                heroTag: 'zoomOut',
                mini: true,
                onPressed: () {
                  _mapController?.animateCamera(CameraUpdate.zoomOut());
                },
                child: const Icon(Icons.remove),
              ),
              const SizedBox(height: 8),

              // Fit bounds
              FloatingActionButton(
                heroTag: 'fitBounds',
                mini: true,
                onPressed: _fitMapBounds,
                child: const Icon(Icons.fullscreen),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _mapReady = true;
    });

    // Add markers and polylines
    _updateMap();
  }

  CameraPosition _getInitialCameraPosition() {
    // Default to first destination, or fallback to a default location
    if (widget.trip.destinations.isNotEmpty) {
      final firstLocation = widget.trip.destinations.first;
      return CameraPosition(
        target: LatLng(firstLocation.latitude, firstLocation.longitude),
        zoom: 12,
      );
    }

    // Default to a generic world view
    return const CameraPosition(
      target: LatLng(0, 0),
      zoom: 2,
    );
  }

  Future<void> _updateMap() async {
    if (!_mapReady) return;

    // Clear existing markers and polylines
    setState(() {
      _markers = {};
      _polylines = {};
    });

    // Add destination markers
    _addDestinationMarkers();

    // Get route polylines
    await _addRoutePolylines();

    // Fit map bounds
    _fitMapBounds();
  }

  void _addDestinationMarkers() {
    // Add markers for all destinations
    for (int i = 0; i < widget.trip.destinations.length; i++) {
      final destination = widget.trip.destinations[i];
      final markerId = MarkerId('destination_$i');

      final marker = Marker(
        markerId: markerId,
        position: LatLng(destination.latitude, destination.longitude),
        infoWindow: InfoWindow(
          title: destination.name,
          snippet: destination.address,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          i == 0
              ? BitmapDescriptor.hueGreen
              : i == widget.trip.destinations.length - 1
                  ? BitmapDescriptor.hueRed
                  : BitmapDescriptor.hueAzure,
        ),
      );

      setState(() {
        _markers[markerId.value] = marker;
      });
    }
  }

  Future<void> _addRoutePolylines() async {
    final routeProvider = Provider.of<RouteProvider>(context, listen: false);

    // Check if route is loaded
    if (routeProvider.currentRoute == null) {
      try {
        await routeProvider.loadRouteForTrip(widget.trip.id);
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load route: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final route = routeProvider.currentRoute;
    if (route == null || route.polylinePoints.isEmpty) return;

    // Create polyline
    final polyline = Polyline(
      polylineId: const PolylineId('trip_route'),
      points: route.polylinePoints
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList(),
      color: Theme.of(context).colorScheme.primary,
      width: 4,
    );

    setState(() {
      _polylines = {polyline};
    });
  }

  void _fitMapBounds() {
    if (_mapController == null || widget.trip.destinations.isEmpty) return;

    // Create bounds from all destinations
    final bounds = _calculateLatLngBounds();
    if (bounds == null) return;

    // Animate to bounds
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50.0), // 50 pixels padding
    );
  }

  LatLngBounds? _calculateLatLngBounds() {
    if (widget.trip.destinations.isEmpty) return null;

    // Find min and max lat/lng values
    double? minLat, maxLat, minLng, maxLng;

    for (final destination in widget.trip.destinations) {
      minLat = minLat == null
          ? destination.latitude
          : (destination.latitude < minLat ? destination.latitude : minLat);

      maxLat = maxLat == null
          ? destination.latitude
          : (destination.latitude > maxLat ? destination.latitude : maxLat);

      minLng = minLng == null
          ? destination.longitude
          : (destination.longitude < minLng ? destination.longitude : minLng);

      maxLng = maxLng == null
          ? destination.longitude
          : (destination.longitude > maxLng ? destination.longitude : maxLng);
    }

    if (minLat == null || maxLat == null || minLng == null || maxLng == null) {
      return null;
    }

    // Create bounds
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}
