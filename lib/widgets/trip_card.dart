// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:absence_watch/pages/trip_summary.dart';
import '../models/profile.dart';
import '../models/trip.dart';

class TripCard extends StatelessWidget {
  final Trip trip;

  const TripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final Profile profile = Provider.of<Profile>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.blueGrey.shade100, width: 1.0),
        ),
        child: InkWell(
          // Change Container to InkWell
          onTap: () {
            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    TripSummaryPage(profile: profile, trip: trip),
              ),
            );
          },

          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    DateFormat.yMMMd("en_GB").format(trip.departureDate),
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  const Expanded(
                      child: RotatedBox(
                          quarterTurns: 1,
                          child: Icon(
                            Icons.flight,
                            color: Color(0xFFFFD23F),
                          ))),
                  Text(
                    DateFormat.yMMMd("en_GB").format(trip.arrivalDate),
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(
                height: 16.0,
              ),
              const Text(
                "Total Absence Days",
                style: TextStyle(color: Color(0xFF919198), fontSize: 10),
              ),
              Text("${trip.totalAbsenceDays}",
                  style: const TextStyle(
                      color: Color(0xFF3D5A6C),
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
