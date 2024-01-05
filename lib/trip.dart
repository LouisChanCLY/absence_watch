import 'package:absence_watch/itinerary.dart';

class Trip {
  DateTime departureDate;
  DateTime arrivalDate;
  List<Itinerary> itineraries;

  Trip({
    required this.departureDate,
    required this.arrivalDate,
    required this.itineraries,
  });
}
