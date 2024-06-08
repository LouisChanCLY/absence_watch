// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:absence_watch/pages/trip_details.dart';
import 'package:absence_watch/widgets/bottom_navigator.dart';
import 'package:absence_watch/widgets/trip_card.dart';
import '../common/theme.dart';
import '../models/profile.dart';

class TripsPage extends StatefulWidget {
  const TripsPage({super.key});

  @override
  _TripsPageState createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<Profile>(context, listen: true);

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        title: const Text('Trips'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: profile.trips.isEmpty
              ? [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        children: [
                          const Text(
                            "You haven't logged any trips yet.",
                            style: TextStyle(fontSize: 18.0),
                          ),
                          const SizedBox(height: 10),
                          FilledButton(
                            style: primaryButtonStyle,
                            onPressed: () {
                              if (!mounted) return;

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TripDetailsPage(profile: profile),
                                ),
                              );
                            },
                            child: const Text("Log your first trip"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
              : [
                  ...profile.trips.map((trip) {
                    return TripCard(trip: trip); // Create a widget instance
                  }),
                ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3D5A6C),
        foregroundColor: Colors.white,
        onPressed: () {
          // Navigate to a new screen for creating a trip
          if (!mounted) return;

          final Profile profile = Provider.of<Profile>(context, listen: false);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TripDetailsPage(profile: profile),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const CustomBottomNavigator(currentIndex: 1),
    );
  }
}
