// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Project imports:
import 'trip.dart';

class Profile with ChangeNotifier {
  String userId = '';
  String firstName = '';
  String lastName = '';
  String email = '';
  String phone = '';
  String? profileImageUrl = '';
  int totalAbsenceDays = 0;
  int maxRollingAbsenceDays = 0;
  int totalAbsenceDaysIn1Year = 0;
  int totalAbsenceDaysIn5Years = 0;
  List<Trip> trips;

  Profile({
    this.userId = '',
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.profileImageUrl = '',
    this.trips = const [],
    this.totalAbsenceDays = 0,
    this.maxRollingAbsenceDays = 0,
    this.totalAbsenceDaysIn1Year = 0,
    this.totalAbsenceDaysIn5Years = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'totalAbsenceDays': totalAbsenceDays,
      'maxRollingAbsenceDays': maxRollingAbsenceDays,
      'totalAbsenceDaysIn1Year': totalAbsenceDaysIn1Year,
      'totalAbsenceDaysIn5Years': totalAbsenceDaysIn5Years,
      'profileImageUrl': profileImageUrl,
      'tripIds': trips.map((t) {
        return t.id;
      }),
    };
  }

  Set<DateTime> absenceDates() {
    // Create a set to store unique absence dates
    Set<DateTime> allAbsenceDates = {};

    // Iterate through each trip in the profile
    for (var trip in trips) {
      // Get the absence dates for this trip and add them to the set
      allAbsenceDates.addAll(trip.absenceDates);
    }

    return allAbsenceDates; // Return the set of all unique absence dates
  }

  Future<void> updateTrip(Trip updatedTrip) async {
    int tripIndex = trips.indexWhere((t) => t.id == updatedTrip.id);
    if (tripIndex == -1) {
      throw Exception('Trip not found in profile');
    }

    if (!checkTripPeriodAvailability(updatedTrip)) {
      throw "Trip collides with another trip";
    }

    await updatedTrip.upload();

    trips[tripIndex] = updatedTrip;

    maxRollingAbsenceDays = calculateMaxRollingAbsenceDays();
    totalAbsenceDays = calculateTotalAbsenceDays();
    totalAbsenceDaysIn1Year = calculateAbsenceDaysOverPeriod(1);
    totalAbsenceDaysIn5Years = calculateAbsenceDaysOverPeriod(5);

    DocumentReference docRef =
        FirebaseFirestore.instance.collection('profiles').doc(userId);
    await docRef.update(toMap());

    notifyListeners();
  }

  Future<void> removeTrip(Trip tripToRemove) async {
    await FirebaseFirestore.instance
        .collection('trips')
        .doc(tripToRemove.id)
        .delete();

    trips.removeWhere((t) => t.id == tripToRemove.id);

    maxRollingAbsenceDays = calculateMaxRollingAbsenceDays();
    totalAbsenceDays = calculateTotalAbsenceDays();
    totalAbsenceDaysIn1Year = calculateAbsenceDaysOverPeriod(1);
    totalAbsenceDaysIn5Years = calculateAbsenceDaysOverPeriod(5);

    DocumentReference docRef =
        FirebaseFirestore.instance.collection('profiles').doc(userId);
    await docRef.update(toMap());

    notifyListeners();
  }

  int calculateTotalAbsenceDays() {
    if (trips.isEmpty) {
      return 0;
    }
    return trips.map((t) => t.totalAbsenceDays).fold(0, (a, b) => a + b);
  }

  List<int> calculateRollingAbsenceDays() {
    if (trips.isEmpty) {
      return [0];
    }

    // Sort trips by departure date
    trips.sort((a, b) => a.departureDate.compareTo(b.departureDate));

    DateTime previousArrivalDate = trips.first.departureDate;
    int threshold = 365;
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
    return maxAbsences;
  }

  int calculateMaxRollingAbsenceDays() {
    return calculateRollingAbsenceDays().reduce(max);
  }

  int calculateAbsenceDaysOverPeriod(int years) {
    final DateTime today = DateTime.now();
    final DateTime startDate =
        DateTime(today.year - years, today.month, today.day);
    final DateTime endDate = DateTime(today.year, today.month, today.day);

    sortTripsByDate();

    int totalAbsenceDays = 0;
    for (Trip trip in trips) {
      if (!trip.arrivalDate.isAfter(startDate)) {
        continue;
      }

      int deduction = 0;
      if (trip.departureDate
          .isBefore(startDate.subtract(const Duration(days: 1)))) {
        deduction += startDate.difference(trip.departureDate).inDays - 1;
      }
      if (trip.arrivalDate.isAfter(endDate.add(const Duration(days: 1)))) {
        deduction += trip.arrivalDate.difference(endDate).inDays - 1;
      }

      totalAbsenceDays += trip.totalAbsenceDays - deduction;
    }

    return totalAbsenceDays;
  }

  static Future<Profile> fromFirestore(DocumentSnapshot doc) async {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    var tripsRefs = data['tripIds'] as List<dynamic>;

    List<Trip> trips = await Future.wait(tripsRefs.map((tripId) async {
      return Trip.getTripById(tripId);
    }));
    return Profile(
      userId: doc.id,
      firstName: data['firstName'],
      lastName: data['lastName'],
      email: data['email'],
      phone: data['phone'],
      totalAbsenceDays: data['totalAbsenceDays'],
      maxRollingAbsenceDays: data['maxRollingAbsenceDays'],
      totalAbsenceDaysIn1Year: data['totalAbsenceDaysIn1Year'],
      totalAbsenceDaysIn5Years: data['totalAbsenceDaysIn5Years'],
      profileImageUrl: data['profileImageUrl'],
      trips: trips,
    );
  }

  Future<void> toFirestore() async {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('profiles').doc(userId);
    DocumentSnapshot docSnap = await docRef.get();
    if (!docSnap.exists) {
      await docRef.set(toMap());
      return;
    }
    print("Profile $userId exists already!");
    return;
  }

  // Method to update the profile from Firestore
  Future<void> fetchAndUpdateProfile(String userId) async {
    Profile profile = await getProfileById(userId);
    this.userId = profile.userId;
    firstName = profile.firstName;
    lastName = profile.lastName;
    email = profile.email;
    phone = profile.phone;
    totalAbsenceDays = profile.totalAbsenceDays;
    maxRollingAbsenceDays = profile.maxRollingAbsenceDays;
    totalAbsenceDaysIn5Years = profile.totalAbsenceDaysIn5Years;
    trips = profile.trips;
    profileImageUrl = profile.profileImageUrl;
    notifyListeners();
  }

  static Future<Profile> getProfileById(String userId) async {
    print("Getting profile for $userId");
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('profiles').doc(userId);
    DocumentSnapshot docSnap = await docRef.get();

    if (!docSnap.exists) {
      print("Creating profile for $userId");
      Profile profile = Profile(
          userId: userId,
          totalAbsenceDays: 0,
          maxRollingAbsenceDays: 0,
          totalAbsenceDaysIn1Year: 0,
          totalAbsenceDaysIn5Years: 0,
          trips: []);
      await docRef.set(profile.toMap());
      return profile;
    }

    return await Profile.fromFirestore(docSnap);
  }

  void sortTripsByDate() {
    if (trips.isEmpty) {
      return;
    }
    // Sort trips by departure date
    trips.sort((a, b) => a.departureDate.compareTo(b.departureDate));
  }

  bool checkTripPeriodAvailability(Trip trip) {
    if (trips.isEmpty) {
      return true;
    }

    sortTripsByDate();
    for (Trip t in trips) {
      if (t.id == trip.id) {
        continue;
      }
      if (!t.arrivalDate.isAfter(trip.departureDate)) {
        continue;
      }
      if (t.departureDate.isBefore(trip.arrivalDate)) {
        return false;
      }
      return true;
    }
    return true;
  }

  Future<void> addTrip(Trip trip) async {
    if (!checkTripPeriodAvailability(trip)) {
      throw "Trip collides with another trip";
    }
    await trip.upload();
    List<Trip> modifiableTrips = List.from(trips);
    modifiableTrips.add(trip);
    trips = modifiableTrips;
    maxRollingAbsenceDays = calculateMaxRollingAbsenceDays();
    totalAbsenceDays = calculateTotalAbsenceDays();
    totalAbsenceDaysIn1Year = calculateAbsenceDaysOverPeriod(1);
    totalAbsenceDaysIn5Years = calculateAbsenceDaysOverPeriod(5);

    DocumentReference docRef =
        FirebaseFirestore.instance.collection('profiles').doc(userId);
    await docRef.update(toMap());
    notifyListeners();
  }

  static int countDatesInRange(
      Set<DateTime> dates, DateTime startDate, DateTime endDate) {
    return dates.where((date) {
      return !date.isBefore(startDate) && !date.isAfter(endDate);
    }).length;
  }
}
