import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_pickers/country.dart';

import '../common/util.dart';
import 'itinerary.dart';

class Trip {
  String? id;
  final String userId;
  List<Itinerary> itineraries;

  Trip({
    this.id,
    required this.userId,
    required List<Itinerary> itineraries,
  }) : itineraries = itineraries
          ..sort((a, b) => a.departureDate.compareTo(b.departureDate));

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'departureDate': departureDate.toIso8601String(),
      'arrivalDate': arrivalDate.toIso8601String(),
      'daysOfAbsence': totalAbsenceDays,
      'isValid': isValid,
      'itineraryIds': itineraries.map((i) {
        return i.id!;
      })
    };
  }

  // Static method to create a Trip from Firestore
  static Future<Trip> fromFirestore(DocumentSnapshot doc) async {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    var itineraryRefs = data['itineraryIds'] as List<dynamic>;

    List<Itinerary> itineraries =
        await Future.wait(itineraryRefs.map((itineraryId) async {
      return Itinerary.getItineraryById(itineraryId);
    }));

    return Trip(
      id: doc.id,
      userId: data['userId'],
      itineraries: itineraries,
    );
  }

  Set<Country> get uniqueCountries {
    return itineraries
        .map((itinerary) => itinerary.arrivalCountry)
        .where((country) => country != ukCountry)
        .toSet();
  }

  Set<DateTime> get absenceDates {
    if (itineraries.isEmpty) {
      return {};
    }

    DateTime firstAbsenceDate =
        itineraries.first.departureDate.add(const Duration(days: 1));
    DateTime lastAbsenceDate = itineraries.last.arrivalCountry == ukCountry
        ? itineraries.last.arrivalDate
        : itineraries.last.arrivalDate.add(const Duration(days: 1));

    final absenceDates = <DateTime>{};
    for (var date = firstAbsenceDate;
        date.isBefore(lastAbsenceDate);
        date = date.add(const Duration(days: 1))) {
      absenceDates.add(date);
    }
    return absenceDates;
  }

  bool get isValid {
    if (itineraries.isEmpty) {
      return false;
    }
    if (itineraries.first.departureCountry != ukCountry) {
      return false;
    }
    if (itineraries.last.arrivalCountry != ukCountry) {
      return false;
    }
    // Check if each itinerary's arrival country matches the next itinerary's departure country
    for (int i = 0; i < itineraries.length - 1; i++) {
      if (itineraries[i].arrivalCountry !=
          itineraries[i + 1].departureCountry) {
        return false;
      }
    }
    return true;
  }

  DateTime get departureDate {
    return itineraries.first.departureDate;
  }

  DateTime get arrivalDate {
    return itineraries.last.arrivalDate;
  }

  int get totalAbsenceDays {
    // Utility function for calculating the number of whole day of absence between two itineraries
    if (itineraries.isEmpty) {
      return 0;
    }

    DateTime firstAbsenceDate =
        itineraries.first.departureDate.add(const Duration(days: 1));
    DateTime lastAbsenceDate = itineraries.last.arrivalCountry == ukCountry
        ? itineraries.last.arrivalDate
        : itineraries.last.arrivalDate.add(const Duration(days: 1));

    return max(0, lastAbsenceDate.difference(firstAbsenceDate).inDays);
  }

  void sortItinerariesByDate() {
    itineraries.sort((a, b) => a.departureDate.compareTo(b.departureDate));
  }

  Future<String> upload() async {
    print("Uploading trip");
    CollectionReference trips = FirebaseFirestore.instance.collection('trips');

    // Add all itineraries first and collect their IDs
    List<String> itineraryIds = [];
    for (Itinerary itinerary in itineraries) {
      String itineraryId = await itinerary.upload();
      itineraryIds.add(itineraryId);
    }

    Map<String, dynamic> tripData = toMap();

    try {
      // Add the Trip to Firestore
      DocumentReference docRef = await trips.add(tripData);
      print('Trip added successfully with ID: ${docRef.id}');
      id = docRef.id;
      return docRef.id;
    } catch (e) {
      print('Error adding trip: $e');
      rethrow;
    }
  }

  static Future<bool> tripExists(String id) async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection('trips').doc(id).get();
    return doc.exists;
  }

  static Future<Trip> getTripById(String id) async {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('trips').doc(id);
    DocumentSnapshot docSnap = await docRef.get();
    if (!docSnap.exists) {
      throw Exception('Trip id $id not found');
    }
    return await Trip.fromFirestore(docSnap);
  }

  static Future<List<String>> getTripIdsByUserId(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('trips')
        .where('userId', isEqualTo: userId)
        .get();

    return querySnapshot.docs
        .map((doc) => doc.id) // Extract the document ID
        .toList();
  }

  static Future<List<Trip>> getTripsByUserId(String userId) async {
    List<String> tripIds = await getTripIdsByUserId(userId);
    if (tripIds.isEmpty) {
      return [];
    }
    return await Future.wait(
        tripIds.map((docId) => getTripById(docId)).toList());
  }
}
