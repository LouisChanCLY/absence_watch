import 'dart:math';

import 'package:absence_watch/pages/trips.dart';
import 'package:country_pickers/country.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../common/theme.dart';
import '../common/util.dart';
import '../models/itinerary.dart';
import '../models/profile.dart';
import '../models/trip.dart';
import '../widgets/edit_itinerary_dialog.dart';
import 'trip_summary.dart';
import '../widgets/itinerary_card.dart';

class TripDetailsPage extends StatefulWidget {
  final Profile profile;
  final Trip? trip;
  final bool isEditing;

  const TripDetailsPage({
    super.key,
    required this.profile,
    this.trip,
    this.isEditing = false,
  });

  @override
  _TripDetailsPageState createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  late Trip trip;
  Country lastArrivalCountry = ukCountry;
  DateTime? lastArrivalDate;
  List<DateTime> blackoutDates = [];
  int absenceDays1Y = 0;
  int absenceDays5Y = 0;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  void _initializePage() {
    if (FirebaseAuth.instance.currentUser?.uid == null) {
      _redirectToLogin();
      return;
    }
    _initializeTrip();
  }

  void _redirectToLogin() {
    print('User not logged in. Redirecting to login page...');
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _initializeTrip() {
    trip = widget.trip ?? Trip(userId: widget.profile.userId, itineraries: []);
    lastArrivalCountry = ukCountry;
    lastArrivalDate = DateTime(2000, 1, 1);
    blackoutDates = _generateBlackoutDates();
    _updateAbsenceDays();
  }

  List<DateTime> _generateBlackoutDates() {
    return widget.profile.trips.expand<DateTime>((trip) {
      // Cast to List<DateTime>
      if (widget.isEditing && trip.id == (widget.trip?.id ?? '')) {
        return []; // Return an empty list
      } else {
        return List.generate(
          trip.arrivalDate.difference(trip.departureDate).inDays - 1,
          (index) => trip.departureDate.add(Duration(days: index + 1)),
        );
      }
    }).toList();
  }

  void _showEditItineraryDialog({Itinerary? initialItinerary, int? index}) {
    showDialog<Itinerary>(
      context: context,
      builder: (BuildContext context) {
        return EditItineraryDialog(
          initialItinerary: initialItinerary,
          lastArrivalCountry: lastArrivalCountry,
          lastArrivalDate: lastArrivalDate,
          userId: widget.profile.userId,
          blackoutDates: blackoutDates,
        );
      },
    ).then((itinerary) {
      if (itinerary != null) {
        if (index != null) {
          _updateItinerary(itinerary, index);
        } else {
          _addNewItinerary(itinerary);
        }
      }
    });
  }

  void _updateAbsenceDays() {
    if (trip.itineraries.isEmpty) {
      return;
    }
    setState(() {
      Set<DateTime> absenceDates = widget.profile.absenceDates();
      absenceDays1Y = calculateAbsenceDays(absenceDates, trip, 1);
      absenceDays5Y = calculateAbsenceDays(absenceDates, trip, 5);
    });
  }

  void _addNewItinerary(Itinerary newItinerary) {
    setState(() {
      trip.itineraries.add(newItinerary);
      trip.sortItinerariesByDate();
      _updateLastArrivalInfo();
      _updateAbsenceDays();
    });
  }

  void _updateItinerary(Itinerary updatedItinerary, int index) {
    setState(() {
      trip.itineraries[index] = updatedItinerary;
      trip.sortItinerariesByDate();
      _updateLastArrivalInfo();
      _updateAbsenceDays();
    });
  }

  void _updateLastArrivalInfo() {
    lastArrivalCountry = trip.itineraries.isNotEmpty
        ? trip.itineraries.last.arrivalCountry
        : ukCountry;
    lastArrivalDate = trip.itineraries.isNotEmpty
        ? trip.itineraries.last.arrivalDate
        : DateTime(2000, 1, 1);
  }

  void _saveTrip() async {
    final profile = Provider.of<Profile>(context, listen: false);

    if (widget.isEditing) {
      await profile.updateTrip(trip); // Update existing trip
    } else {
      await profile.addTrip(trip); // Add new trip
    }
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            TripSummaryPage(profile: widget.profile, trip: trip),
      ),
    );
  }

  Widget _buildItineraryList() {
    return Column(
      children: trip.itineraries.asMap().entries.map((entry) {
        int index = entry.key + 1;
        Itinerary itinerary = entry.value;
        return ItineraryCard(
          itinerary_order: index,
          itinerary: itinerary,
          isEditable: true,
          onEdit: (Itinerary itin) => showModalBottomSheet<Itinerary>(
            isScrollControlled: true,
            context: context,
            builder: (BuildContext context) {
              return EditItineraryDialog(
                initialItinerary: itin,
                userId: widget.profile.userId,
                blackoutDates: blackoutDates,
              );
            },
          ).then((updatedItinerary) {
            if (updatedItinerary != null) {
              _updateItinerary(
                  updatedItinerary, entry.key); // Update existing itinerary
            }
          }),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons() {
    return Center(
      child: ActionChip(
        avatar: Icon(trip.isValid ? Icons.check : Icons.add),
        label: Text(trip.isValid ? 'Save trip' : 'Add an itinerary'),
        onPressed: trip.isValid ? _saveTrip : () => _showEditItineraryDialog(),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Trip'),
          content: const Text('Are you sure you want to delete this trip?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      // User confirmed deletion, proceed with removing the trip
      final profile = Provider.of<Profile>(context, listen: false);
      try {
        await profile.removeTrip(trip);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TripsPage(),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting trip: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalAbsenceDays = trip.totalAbsenceDays;

    DateTime today = DateTime.now();
    DateTime? arrivalDate = trip.itineraries.isNotEmpty
        ? trip.itineraries.last.arrivalDate
        : DateTime.now();

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        backgroundColor: pageBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        title: Text(widget.isEditing ? 'Edit Trip' : 'Add Trip'),
        actions: widget.isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _showDeleteConfirmationDialog(context);
                  },
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 24.0,
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
              decoration: BoxDecoration(
                  color: primaryElementBackgroundColor,
                  border: Border.symmetric(
                    horizontal: primaryElementBorderSide,
                  )),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Expanded(
                        child: Text(
                          'Total Absence Days',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '$totalAbsenceDays',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  if (totalAbsenceDays > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            getRAGIcon(
                                absenceDays1Y,
                                (arrivalDate.isAfter(today))
                                    ? absenceBudget1Y
                                    : absenceBudget12M,
                                absenceBudget12M),
                            const SizedBox(
                              width: 8.0,
                            ),
                            Text(
                                "Rolling 12-Month ($absenceDays1Y / $absenceBudget12M)"),
                          ],
                        ),
                        if ((absenceDays1Y >= absenceBudget1Y) &&
                            (absenceDays1Y < absenceBudget12M) &&
                            (arrivalDate.isAfter(today)))
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                            ),
                            child: Text(
                              "You will be exceeding the 1 year threshold if you are planning to apply for citizenship after the trip.",
                              style: subtitleStyle,
                            ),
                          ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        Row(
                          children: [
                            getRAGIcon(absenceDays5Y, absenceBudget5Y,
                                absenceBudget5Y),
                            const SizedBox(
                              width: 8.0,
                            ),
                            Text(
                                "Rolling 5-Year ($absenceDays5Y / $absenceBudget5Y)"),
                          ],
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          'Calculation based on your travel history, future trip(s) and the current trip ending on ${DateFormat.yMMMd("en_GB").format(arrivalDate)}',
                          style: subtitleStyle,
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(
              height: 8.0,
            ),
            _buildItineraryList(),
            Container(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                height: 55.0,
                child: OutlinedButton(
                  style: outlineButtonStyle,
                  onPressed: () {
                    showModalBottomSheet<Itinerary>(
                      isScrollControlled: true,
                      context: context,
                      builder: (BuildContext context) {
                        return EditItineraryDialog(
                          initialItinerary: null,
                          lastArrivalCountry: lastArrivalCountry,
                          lastArrivalDate: lastArrivalDate,
                          userId: widget.profile.userId,
                          blackoutDates: blackoutDates,
                        );
                      },
                    ).then((itinerary) {
                      if (itinerary != null) {
                        _addNewItinerary(itinerary);
                      }
                    });
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add),
                      SizedBox(
                        width: 8.0,
                      ),
                      Text(
                        'Add itinerary',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0.0,
        color: pageBackgroundColor,
        child: FilledButton(
          style: trip.isValid ? primaryButtonStyle : primaryDisabledButtonStyle,
          onPressed: trip.isValid ? _saveTrip : null,
          child: widget.isEditing
              ? const Text("Save Trip")
              : const Text('Add Trip'),
        ),
      ),
    );
  }
}
