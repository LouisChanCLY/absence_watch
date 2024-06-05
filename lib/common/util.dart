import 'package:flutter/material.dart';

import '../models/itinerary.dart';
import 'package:intl/intl.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';

final Country ukCountry = CountryPickerUtils.getCountryByIsoCode('GB');

const int absenceBudget12M = 180;
const int absenceBudget5Y = 450;
const int absenceBudget1Y = 1;

String formatDate(DateTime? date) {
  if (date == null) return 'N/A';
  return DateFormat('yyyy-MM-dd').format(date);
}

int calculateTotalAbsenceDays(
    Itinerary firstItinerary, Itinerary lastItinerary) {
  // Utility function for calculating the number of whole day of absence between two itineraries
  DateTime firstAbsenceDate =
      firstItinerary.departureDate.add(const Duration(days: 1));
  DateTime lastAbsenceDate = lastItinerary.arrivalCountry.isoCode == 'GB'
      ? lastItinerary.arrivalDate
      : lastItinerary.arrivalDate.add(const Duration(days: 1));

  return lastAbsenceDate.difference(firstAbsenceDate).inDays;
}

List<Map<String, dynamic>> calculateCumulativeAbsence(
    List<Map<String, dynamic>> dailyStatus) {
  List<Map<String, dynamic>> cumulativeData = [];
  int cumulativeAbsenceDays = 0;

  for (var status in dailyStatus) {
    if (status['absence']) {
      cumulativeAbsenceDays++;
    }
    cumulativeData.add({
      'date': status['date'],
      'cumulativeAbsenceDays': cumulativeAbsenceDays
    });
  }

  return cumulativeData;
}

int calculateDatesInRange(
    Set<DateTime> dates, DateTime startDate, DateTime endDate) {
  return dates.where((date) {
    return !date.isBefore(startDate) && !date.isAfter(endDate);
  }).length;
}

Icon getRAGIcon(int? value, int amberThreshold, int redThreshold) {
  if (value == null) {
    return const Icon(
      Icons.hourglass_empty,
      color: Colors.grey,
      size: 24.0,
    );
  } else if (value < amberThreshold) {
    return const Icon(
      Icons.check_circle_rounded,
      color: Colors.green,
      size: 24.0,
    );
  } else if (value < redThreshold) {
    return const Icon(
      Icons.warning_amber_rounded,
      color: Colors.orange,
      size: 24.0,
    );
  } else {
    return const Icon(
      Icons.error_rounded,
      color: Colors.red,
      size: 24.0,
    );
  }
}

// int calculateMaxRollingTotalAbsenceDays(List<Trip> trips) {
//   if (trips.isEmpty) return 0;

//   // Sort trips by departure date
//   trips.sort((a, b) => a.departureDate.compareTo(b.departureDate));

//   DateTime previousArrivalDate = trips.first.departureDate;
//   int threshold = 360;
//   int absenceCounter = 0;
//   int dayCounter = 0;
//   List<int> maxAbsences = [];

//   for (Trip trip in trips) {
//     int allDays = trip.arrivalDate.difference(trip.departureDate).inDays +
//         1 +
//         trip.departureDate.difference(previousArrivalDate).inDays;
//     previousArrivalDate = trip.arrivalDate;
//     dayCounter += allDays;

//     if (dayCounter < threshold) {
//       absenceCounter += trip.totalAbsenceDays;
//       maxAbsences.add(absenceCounter);
//       continue;
//     }

//     int gap = dayCounter - threshold;
//     dayCounter = threshold;
//     if (gap > threshold) {
//       absenceCounter = trip.totalAbsenceDays;
//       maxAbsences.add(absenceCounter);
//       continue;
//     }

//     absenceCounter = max(0, (absenceCounter - gap)) + trip.totalAbsenceDays;
//     maxAbsences.add(absenceCounter);
//   }
//   print(maxAbsences);
//   return maxAbsences.reduce(max);
// }
