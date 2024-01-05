import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'itinerary.dart';

class AddNewTripPage extends StatefulWidget {
  const AddNewTripPage({Key? key}) : super(key: key);

  @override
  _AddNewTripPageState createState() => _AddNewTripPageState();
}

String _formatDate(DateTime? date) {
  if (date == null) return 'N/A';
  return DateFormat('yyyy-MM-dd').format(date);
}

// Sample list of countries. Replace with your full list.
final List<String> countries = [
  'USA',
  'UK',
  'Canada',
  'Germany',
  'France',
  'Japan'
];

class _AddNewTripPageState extends State<AddNewTripPage> {
  List<Itinerary> itineraries = [];

  bool get isTripValid {
    if (itineraries.isEmpty) {
      return false;
    }
    return itineraries.first.departureCountry == 'UK' &&
        itineraries.last.arrivalCountry == 'UK';
  }

  void _addItinerary() {
    bool isFirstItinerary = itineraries.isEmpty;
    Itinerary? lastItinerary = itineraries.isNotEmpty ? itineraries.last : null;

    showDialog<Itinerary>(
      context: context,
      builder: (BuildContext context) {
        return AddItineraryDialog(
          isFirstItinerary: isFirstItinerary,
          initialDepartureCountry:
              isFirstItinerary ? 'UK' : lastItinerary?.arrivalCountry,
          initialDepartureDate: lastItinerary?.arrivalDate,
        );
      },
    ).then((newItinerary) {
      if (newItinerary != null) {
        setState(() {
          itineraries.add(newItinerary);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add New Trip'),
        actions: <Widget>[
          TextButton(
            onPressed: isTripValid
                ? () {
                    // TODO: Implement save trip logic
                  }
                : null,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (var itinerary in itineraries)
                Card(
                  child: ListTile(
                    title: Text(
                        '${itinerary.departureCountry} to ${itinerary.arrivalCountry}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                            'Departure: ${_formatDate(itinerary.departureDate)}'),
                        Text('Arrival: ${_formatDate(itinerary.arrivalDate)}'),
                      ],
                    ),
                  ),
                ),
              if (itineraries.isEmpty)
                ElevatedButton(
                  onPressed: _addItinerary,
                  child: const Text('Add your first itinerary'),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: itineraries.isNotEmpty
          ? FloatingActionButton(
              onPressed: _addItinerary,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class AddItineraryDialog extends StatefulWidget {
  final bool isFirstItinerary;
  final String? initialDepartureCountry;
  final DateTime? initialDepartureDate;

  const AddItineraryDialog({
    Key? key,
    this.isFirstItinerary = false,
    this.initialDepartureCountry,
    this.initialDepartureDate,
  }) : super(key: key);

  @override
  _AddItineraryDialogState createState() => _AddItineraryDialogState();
}

class _AddItineraryDialogState extends State<AddItineraryDialog> {
  final _formKey = GlobalKey<FormState>();
  String? departureCountry;
  DateTime? departureDate;
  String? arrivalCountry;
  DateTime? arrivalDate;
  String? purpose = '';

  // Sample list of countries. Replace with your full list.
  final List<String> purposes = ['Business', 'Leisure', 'Family & Friends'];

  @override
  void initState() {
    super.initState();
    departureCountry =
        widget.isFirstItinerary ? 'UK' : (widget.initialDepartureCountry ?? '');
    departureDate = widget.initialDepartureDate ?? DateTime.now();
  }

  Future<void> _selectDepartureDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: departureDate ?? DateTime.now(),
      firstDate: DateTime(2000), // Adjust as needed
      lastDate: DateTime.now(), // Today
      // lastDate: DateTime.now().subtract(const Duration(days: 1)), // Yesterday
    );
    if (picked != null && picked != departureDate) {
      setState(() {
        departureDate = picked;
      });
    }
  }

  Future<void> _selectArrivalDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: arrivalDate ?? (departureDate ?? DateTime.now()),
      firstDate: departureDate ?? DateTime.now(),
      lastDate: DateTime.now(), // Today
    );
    if (picked != null && picked != arrivalDate) {
      setState(() {
        arrivalDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Itinerary'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (!widget.isFirstItinerary)
              DropdownButtonFormField<String>(
                value: departureCountry,
                decoration:
                    const InputDecoration(labelText: 'Departure Country'),
                items: countries.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    departureCountry = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a country' : null,
              ),
            if (widget.isFirstItinerary)
              TextFormField(
                initialValue: 'UK',
                enabled: false, // Disable editing if it's the first itinerary
                decoration:
                    const InputDecoration(labelText: 'Departure Country'),
              ),
            ListTile(
              title: const Text('Departure Date'),
              subtitle: Text(departureDate == null
                  ? 'Select Date'
                  : _formatDate(departureDate!)),
              onTap: () => _selectDepartureDate(context),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Arrival Country'),
              items: countries.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  arrivalCountry = newValue;
                });
              },
              validator: (value) =>
                  value == null ? 'Please select a country' : null,
            ),
            ListTile(
              title: const Text('Arrival Date'),
              subtitle: Text(arrivalDate == null
                  ? 'Select Date'
                  : _formatDate(departureDate!)),
              onTap: () => _selectArrivalDate(context),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Purpose of Travel'),
              items: purposes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  purpose = newValue;
                });
              },
              validator: (value) =>
                  value == null ? 'Please select a country' : null,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              Navigator.pop(
                context,
                Itinerary(
                  departureCountry: departureCountry!,
                  departureDate: departureDate!,
                  arrivalCountry: arrivalCountry!,
                  arrivalDate: arrivalDate!,
                  purpose: purpose!,
                ),
              );
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
