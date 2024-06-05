import 'package:cloud_firestore/cloud_firestore.dart';

import 'trip.dart';
import 'dart:math';

class TripHistory {
  List<Trip> trips;
  final String userId;

  TripHistory({required this.userId, required this.trips});

  Map<String, dynamic> toMap() {
    return {
      'tripIds': trips.map((t) {
        return t.id!;
      })
    };
  }

  int get totalAbsenceDays {
    return trips.fold(
        0, (runningSum, trip) => runningSum + trip.totalAbsenceDays);
  }

  int get maxRollingTotalAbsenceDays {
    if (trips.isEmpty) return 0;

    // Sort trips by departure date
    trips.sort((a, b) => a.departureDate.compareTo(b.departureDate));

    DateTime previousArrivalDate = trips.first.departureDate;
    int threshold = 360;
    int absenceCounter = 0;
    int dayCounter = 0;
    List<int> maxAbsences = [];

    for (Trip trip in trips) {
      int allDays = trip.arrivalDate.difference(trip.departureDate).inDays +
          1 +
          trip.departureDate.difference(previousArrivalDate).inDays;
      previousArrivalDate = trip.arrivalDate;
      dayCounter += allDays;

      if (dayCounter < threshold) {
        absenceCounter += trip.totalAbsenceDays;
        maxAbsences.add(absenceCounter);
        continue;
      }

      int gap = dayCounter - threshold;
      dayCounter = threshold;
      if (gap > threshold) {
        absenceCounter = trip.totalAbsenceDays;
        maxAbsences.add(absenceCounter);
        continue;
      }

      absenceCounter = max(0, (absenceCounter - gap)) + trip.totalAbsenceDays;
      maxAbsences.add(absenceCounter);
    }
    print(maxAbsences);
    return maxAbsences.reduce(max);
  }

  // Static method to create a Trip from Firestore
  static Future<TripHistory> fromFirestore(DocumentSnapshot doc) async {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    var tripRefs = data['tripIds'] as List<dynamic>;

    List<Trip> trips = await Future.wait(tripRefs.map((ref) async {
      DocumentSnapshot tripDoc = await ref.get();
      return Trip.fromFirestore(tripDoc);
    }));

    return TripHistory(
      userId: data['userId'],
      trips: trips,
    );
  }

  static Future<TripHistory> getTripByUserId(String userId) async {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('tripHistory').doc(userId);
    DocumentSnapshot docSnap = await docRef.get();

    if (!docSnap.exists) {
      TripHistory tripHistory = TripHistory(userId: userId, trips: []);
      await FirebaseFirestore.instance
          .collection('tripHistory')
          .doc(userId)
          .set(tripHistory.toMap());
      return tripHistory;
    }

    return await TripHistory.fromFirestore(docSnap);
  }

  Future<void> addTrip(Trip trip) async {
    try {
      String tripId = await trip.upload();
      trips.add(trip);

      DocumentReference tripHistoryDoc =
          FirebaseFirestore.instance.collection('tripHistory').doc(userId);

      await tripHistoryDoc.update({
        "tripIds": FieldValue.arrayUnion([tripId])
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeTrip(Trip trip) async {
    try {
      // TODO: delete trip

      DocumentReference tripHistoryDoc =
          FirebaseFirestore.instance.collection('tripHistory').doc(userId);

      await tripHistoryDoc.update({
        "tripIds": FieldValue.arrayRemove([trip.id])
      });
    } catch (e) {
      rethrow;
    }
  }
}
