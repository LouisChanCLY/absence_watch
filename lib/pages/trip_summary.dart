import 'package:absence_watch/common/theme.dart';
import 'package:absence_watch/common/util.dart';
import 'package:absence_watch/models/itinerary.dart';
import 'package:absence_watch/pages/trips.dart';
import 'package:absence_watch/widgets/itinerary_card.dart';
import 'package:flutter/material.dart';

import 'package:absence_watch/models/profile.dart';
import 'package:absence_watch/models/trip.dart';
import 'package:absence_watch/pages/trip_details.dart';
import 'package:intl/intl.dart';
// import 'old_history.dart';

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
                              // color: primaryTextColor,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '${trip.totalAbsenceDays}',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ]),
                  const SizedBox(
                    height: 8.0,
                  ),
                  if (trip.totalAbsenceDays > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            getRAGIcon(
                                absenceDays1Y,
                                (trip.arrivalDate.isAfter(today))
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
                            (trip.arrivalDate.isAfter(today)))
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
                          'Calculation based on your travel history, future trip(s) and the current trip ending on ${DateFormat.yMMMd("en_GB").format(trip.arrivalDate)}',
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
