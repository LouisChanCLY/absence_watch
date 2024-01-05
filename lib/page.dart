import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'itinerary.dart';
import 'countries.dart';
import 'purposes.dart';
import 'trip.dart';

class AddNewTripPage extends StatefulWidget {
  const AddNewTripPage({Key? key}) : super(key: key);

  @override
  _AddNewTripPageState createState() => _AddNewTripPageState();
}

String _formatDate(DateTime? date) {
  if (date == null) return 'N/A';
  return DateFormat('yyyy-MM-dd').format(date);
}

class _AddNewTripPageState extends State<AddNewTripPage> {
  Trip? trip;
  List<Itinerary> itineraries = [];
  String lastArrivalCountry = '';
  DateTime? lastArrivalDate;

  int calculateTotalAbsenceDays() {
    if (trip == null || trip!.itineraries.isEmpty) {
      return 0;
    }

    DateTime firstAbsenceDate =
        itineraries.first.departureDate.add(const Duration(days: 1));
    DateTime lastAbsenceDate = itineraries.last.arrivalCountry == 'UK'
        ? itineraries.last.arrivalDate
        : itineraries.last.arrivalDate.add(const Duration(days: 1));

    return lastAbsenceDate.difference(firstAbsenceDate).inDays;
  }

  bool get isTripValid {
    if (itineraries.isEmpty) {
      return false;
    }
    if (itineraries.last.arrivalCountry != 'UK') {
      return false;
    }
    return true;
  }

  void _saveTrip() {
    // Implement the logic to save the trip
    // This might involve storing the trip data in a database or a state management solution
    print('Trip saved with ${trip?.itineraries.length ?? 0} itineraries.');
  }

  @override
  void initState() {
    super.initState();
    lastArrivalCountry =
        itineraries.isNotEmpty ? itineraries.last.arrivalCountry : 'UK';
    lastArrivalDate = itineraries.isNotEmpty
        ? itineraries.last.arrivalDate
        : DateTime(2000, 1, 1);
  }

  void _addItinerary() {
    // Called when pressing add itinerary button

    showDialog<Itinerary>(
      context: context,
      builder: (BuildContext context) {
        return AddItineraryDialog(
          lastArrivalCountry: lastArrivalCountry,
          lastArrivalDate: lastArrivalDate,
        );
      },
    ).then((newItinerary) {
      if (newItinerary != null) {
        setState(() {
          itineraries.add(newItinerary);
          lastArrivalCountry =
              itineraries.isNotEmpty ? itineraries.last.arrivalCountry : 'UK';
          lastArrivalDate = itineraries.isNotEmpty
              ? itineraries.last.arrivalDate
              : DateTime(2000, 1, 1);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalAbsenceDays = calculateTotalAbsenceDays();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add New Trip'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Total Absence Days: $totalAbsenceDays'),
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
                          Text(
                              'Arrival: ${_formatDate(itinerary.arrivalDate)}'),
                        ],
                      ),
                    ),
                  ),
                if (isTripValid)
                  Center(
                      child: ActionChip(
                    avatar: const Icon(Icons.check),
                    label: const Text('Save trip'),
                    onPressed: _saveTrip,
                  )),
                if (!isTripValid)
                  Center(
                      child: ActionChip(
                    avatar: const Icon(Icons.add),
                    label: const Text('Add an itinerary'),
                    onPressed: _addItinerary,
                  ))
              ]),
        ),
      ),
    );
  }
}

class AddItineraryDialog extends StatefulWidget {
  final String? lastArrivalCountry;
  final DateTime? lastArrivalDate;

  const AddItineraryDialog({
    Key? key,
    this.lastArrivalCountry,
    this.lastArrivalDate,
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
  String? purpose;
  bool isSameDayArrival = true; // New state variable for the checkbox

  @override
  void initState() {
    super.initState();
    departureCountry = widget.lastArrivalCountry;
  }

  Future<void> _selectDepartureDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: widget.lastArrivalDate!, // Adjust as needed
      lastDate: DateTime.now(), // Today
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
      initialDate: departureDate,
      firstDate: departureDate!, // Adjust as needed
      lastDate: DateTime.now(), // Today
    );
    if (picked != null && picked != arrivalDate) {
      setState(() {
        arrivalDate = picked;
      });
    }
  }

  bool _validateForm() {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      if (departureCountry == arrivalCountry) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Departure and arrival countries should be different')),
        );
        return false;
      }
      if (isSameDayArrival) {
        arrivalDate = departureDate;
      }
      if (arrivalDate != null &&
          departureDate != null &&
          arrivalDate!.isBefore(departureDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Arrival date should be on or after the departure date')),
        );
        return false;
      }
      if (departureDate!.isAfter(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Departure date cannot be in the future')),
        );
        return false;
      }
      if (arrivalDate!.isAfter(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Arrival date cannot be in the future')),
        );
        return false;
      }
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Itinerary'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DropdownButtonFormField<String>(
                  value: departureCountry,
                  decoration:
                      const InputDecoration(labelText: 'Departure Country'),
                  items:
                      countries.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: null),
              DropdownButtonFormField<String>(
                value: arrivalCountry,
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
                title: const Text('Departure Date'),
                subtitle: Text(departureDate == null
                    ? 'Select Date'
                    : _formatDate(departureDate!)),
                onTap: () => _selectDepartureDate(context),
              ),
              if (departureDate != null)
                CheckboxListTile(
                  title: const Text("Arrived on the same day"),
                  value: isSameDayArrival,
                  onChanged: (bool? value) {
                    setState(() {
                      isSameDayArrival = value!;
                      if (isSameDayArrival) {
                        arrivalDate =
                            departureDate; // Set arrival date same as departure
                      }
                    });
                  },
                ),
              if (!isSameDayArrival) // Conditionally display the arrival date picker
                ListTile(
                  title: const Text('Arrival Date'),
                  subtitle: Text(arrivalDate == null
                      ? 'Select Date'
                      : _formatDate(arrivalDate!)),
                  onTap: () => _selectArrivalDate(context),
                ),
              DropdownButtonFormField<String>(
                decoration:
                    const InputDecoration(labelText: 'Purpose of Travel'),
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
                validator: (value) => value == null
                    ? 'Please select the purpose of travel'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_validateForm()) {
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
