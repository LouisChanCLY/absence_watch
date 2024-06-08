// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';

class Itinerary {
  String? id;
  final String userId;
  Country departureCountry;
  DateTime departureDate;
  Country arrivalCountry;
  DateTime arrivalDate;
  String? purpose;

  Itinerary({
    this.id,
    required this.userId,
    required this.departureCountry,
    required this.departureDate,
    required this.arrivalCountry,
    required this.arrivalDate,
    this.purpose,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'departureCountryCode': departureCountry.isoCode,
      'departureDate': departureDate.toIso8601String(),
      'arrivalCountryCode': arrivalCountry.isoCode,
      'arrivalDate': arrivalDate.toIso8601String(),
      'purpose': purpose,
    };
  }

  // Factory method to create an Itinerary from a map
  factory Itinerary.fromMap(Map<String, dynamic> map) {
    return Itinerary(
      id: map['id'], // Ensure 'id' is passed in the map
      userId: map['userId'],
      departureCountry:
          CountryPickerUtils.getCountryByIsoCode(map['departureCountryCode']),
      departureDate: DateTime.parse(map['departureDate']),
      arrivalCountry:
          CountryPickerUtils.getCountryByIsoCode(map['arrivalCountryCode']),
      arrivalDate: DateTime.parse(map['arrivalDate']),
      purpose: map['purpose'],
    );
  }

  // Static method to create a Trip from Firestore
  static Future<Itinerary> fromFirestore(DocumentSnapshot doc) async {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Itinerary.fromMap(data);
  }

  static Future<Itinerary> getItineraryById(String id) async {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('itineraries').doc(id);
    DocumentSnapshot docSnap = await docRef.get();
    if (!docSnap.exists) {
      throw Exception('Itinerary id $id not found');
    }
    return await Itinerary.fromFirestore(docSnap);
  }

  Future<String> upload() async {
    print("Uploading itinerary");
    CollectionReference itineraryCollection =
        FirebaseFirestore.instance.collection('itineraries');

    try {
      // Convert the Itinerary to a Map
      Map<String, dynamic> itineraryData = toMap();

      // Add the Itinerary to Firestore
      DocumentReference docRef = await itineraryCollection.add(itineraryData);
      print('Itinerary added successfully with ID: ${docRef.id}');
      id = docRef.id;

      return docRef.id; // Return the ID of the newly added Itinerary
    } catch (e) {
      print('Error adding itinerary: $e');
      rethrow; // Re-throw the error for further handling if necessary
    }
  }
}
