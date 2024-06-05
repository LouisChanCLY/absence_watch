import 'package:absence_watch/common/theme.dart';
import 'package:absence_watch/common/util.dart';
import 'package:absence_watch/models/itinerary.dart';
import 'package:absence_watch/pages/trips.dart';
import 'package:absence_watch/widgets/absence_days_card.dart';
import 'package:absence_watch/widgets/itinerary_card.dart';
import 'package:flutter/material.dart';
import 'package:absence_watch/models/profile.dart';
import 'package:absence_watch/models/trip.dart';
import 'package:absence_watch/pages/trip_details.dart';

class TripSummaryPage extends StatelessWidget {
  final Trip trip;
  final Profile profile;

  const TripSummaryPage({Key? key, required this.profile, required this.trip})
      : super(key: key);

  Widget _buildItineraryList() {
    return Column(
      children: trip.itineraries.asMap().entries.map((entry) {
        int index = entry.key + 1;
        Itinerary itinerary = entry.value;
        return ItineraryCard(
          itinerary_order: index,
          itinerary: itinerary,
          isEditable: false,
          onEdit: (Itinerary itin) => null,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Set<DateTime> absenceDates = profile.absenceDates();
    int absenceDays1Y = calculateAbsenceDays(absenceDates, trip, 1);
    int absenceDays5Y = calculateAbsenceDays(absenceDates, trip, 5);
    DateTime today = DateTime.now();
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        backgroundColor: pageBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        title: const Text('Trip Summary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TripDetailsPage(
                    profile: profile,
                    trip: trip,
                    isEditing: true,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 24.0,
            ),
            AbsenceDayesCard(
                tripTotalAbsenceDays: trip.totalAbsenceDays,
                tripArrivalDate: trip.arrivalDate,
                absenceDays1Y: absenceDays1Y,
                absenceDays5Y: absenceDays5Y),
            const SizedBox(
              height: 8.0,
            ),
            _buildItineraryList(),
            Container(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                height: 55.0,
                child: FilledButton(
                  style: primaryButtonStyle,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TripsPage(),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'View All Trips',
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
    );
  }
}
