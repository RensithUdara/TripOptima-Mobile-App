import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trip_optima_mobile_app/models/location_model.dart';
import 'package:trip_optima_mobile_app/providers/trip_provider.dart';
import 'package:trip_optima_mobile_app/providers/ui_provider.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  final List<LocationModel> _selectedDestinations = [];

  bool _isCreatingTrip = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Trip'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trip name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Trip Name',
                  hintText: 'e.g., Summer Vacation 2024',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a trip name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Trip description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Add some notes about your trip',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Date range selection
              _buildDateRangeSelector(),
              const SizedBox(height: 16),

              // Destinations
              _buildDestinationsSection(),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isCreatingTrip ? null : _submitTrip,
                  child: _isCreatingTrip
                      ? const CircularProgressIndicator()
                      : const Text('Create Trip'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trip Dates',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),

        // Start date
        ListTile(
          title: const Text('Start Date'),
          subtitle: Text(dateFormat.format(_startDate)),
          trailing: const Icon(Icons.calendar_today),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
          ),
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: _startDate,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
            );

            if (pickedDate != null) {
              setState(() {
                _startDate = pickedDate;

                // If end date is before start date, update it
                if (_endDate != null && _endDate!.isBefore(_startDate)) {
                  _endDate = _startDate;
                }
              });
            }
          },
        ),
        const SizedBox(height: 8),

        // End date
        ListTile(
          title: const Text('End Date (Optional)'),
          subtitle:
              Text(_endDate != null ? dateFormat.format(_endDate!) : 'Not set'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_endDate != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _endDate = null;
                    });
                  },
                ),
              const Icon(Icons.calendar_today),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
          ),
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: _endDate ?? _startDate,
              firstDate: _startDate,
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
            );

            if (pickedDate != null) {
              setState(() {
                _endDate = pickedDate;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildDestinationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Destinations',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add'),
              onPressed: _addDestination,
            ),
          ],
        ),

        if (_selectedDestinations.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text('No destinations added yet'),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedDestinations.length,
            itemBuilder: (context, index) {
              final destination = _selectedDestinations[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(destination.name),
                  subtitle: destination.address != null
                      ? Text(destination.address!,
                          maxLines: 1, overflow: TextOverflow.ellipsis)
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Reorder up
                      if (index > 0)
                        IconButton(
                          icon: const Icon(Icons.arrow_upward),
                          onPressed: () {
                            setState(() {
                              final item =
                                  _selectedDestinations.removeAt(index);
                              _selectedDestinations.insert(index - 1, item);
                            });
                          },
                          tooltip: 'Move up',
                        ),

                      // Reorder down
                      if (index < _selectedDestinations.length - 1)
                        IconButton(
                          icon: const Icon(Icons.arrow_downward),
                          onPressed: () {
                            setState(() {
                              final item =
                                  _selectedDestinations.removeAt(index);
                              _selectedDestinations.insert(index + 1, item);
                            });
                          },
                          tooltip: 'Move down',
                        ),

                      // Remove
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          setState(() {
                            _selectedDestinations.removeAt(index);
                          });
                        },
                        tooltip: 'Remove',
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

        // Validation error message
        if (_selectedDestinations.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'At least one destination is required',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  void _addDestination() async {
    // This would normally open a location search screen
    // For now, we'll just add a placeholder location

    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching for locations...'),
          ],
        ),
      ),
    );

    try {
      // Simulate searching for a location
      await Future.delayed(const Duration(seconds: 1));

      // Close the loading dialog
      Navigator.of(context).pop();

      // Show location search results
      final location = await showDialog<LocationModel>(
        context: context,
        builder: (context) => SimpleDialog(
          title: const Text('Select a Location'),
          children: [
            // Sample locations
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(
                  context,
                  LocationModel(
                    id: '1',
                    name: 'Paris, France',
                    address: 'Paris, France',
                    latitude: 48.8566,
                    longitude: 2.3522,
                    placeId: 'paris_france',
                  ),
                );
              },
              child: const ListTile(
                leading: Icon(Icons.location_on),
                title: Text('Paris, France'),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(
                  context,
                  LocationModel(
                    id: '2',
                    name: 'London, UK',
                    address: 'London, UK',
                    latitude: 51.5074,
                    longitude: -0.1278,
                    placeId: 'london_uk',
                  ),
                );
              },
              child: const ListTile(
                leading: Icon(Icons.location_on),
                title: Text('London, UK'),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(
                  context,
                  LocationModel(
                    id: '3',
                    name: 'New York, USA',
                    address: 'New York, NY, USA',
                    latitude: 40.7128,
                    longitude: -74.0060,
                    placeId: 'new_york_usa',
                  ),
                );
              },
              child: const ListTile(
                leading: Icon(Icons.location_on),
                title: Text('New York, USA'),
              ),
            ),
          ],
        ),
      );

      if (location != null) {
        setState(() {
          _selectedDestinations.add(location);
        });
      }
    } catch (e) {
      // Close the loading dialog if open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching for locations: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitTrip() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Validate destinations
    if (_selectedDestinations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one destination'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreatingTrip = true;
    });

    // Get providers
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final uiProvider = Provider.of<UIProvider>(context, listen: false);

    try {
      // We'll create the trip directly with the provider instead of creating a TripModel instance

      // Add the trip
      await tripProvider.createTrip(
        name: _nameController.text,
        userId: "current_user_id", // This would normally come from the AuthProvider
        description: _descriptionController.text,
        startDate: _startDate,
        endDate: _endDate,
        startLocation: _selectedDestinations.isNotEmpty
            ? _selectedDestinations.first
            : LocationModel(
                id: "default",
                name: "Starting Point",
                latitude: 0,
                longitude: 0,
                placeId: "default_place"),
        destinations: _selectedDestinations,
      );

      // Show success message
      uiProvider.showSnackBar(
        message: 'Trip created successfully!',
        type: SnackBarType.success,
      );

      // Navigate back
      Navigator.of(context).pop();
    } catch (e) {
      // Show error
      uiProvider.showSnackBar(
        message: 'Failed to create trip: ${e.toString()}',
        type: SnackBarType.error,
      );
    } finally {
      setState(() {
        _isCreatingTrip = false;
      });
    }
  }
}
