// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:country_flags/country_flags.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:absence_watch/models/itinerary.dart';

class ItineraryCard extends StatelessWidget {
  final int itineraryOrder;
  final Itinerary itinerary;
  final bool isEditable;
  final Function(Itinerary itinerary)? onEdit;

  const ItineraryCard({
    super.key,
    required this.itineraryOrder,
    required this.itinerary,
    this.isEditable = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            decoration: const BoxDecoration(
                color: Colors.white,
                border: Border.symmetric(
                    horizontal:
                        BorderSide(color: Color(0xFFE7E8EC), width: 1.0))),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Itinerary $itineraryOrder",
                    style: const TextStyle(
                        fontSize: 20.0, fontWeight: FontWeight.w600),
                  ),
                ),
                if (isEditable)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      if (onEdit != null) {
                        onEdit!(itinerary); // Call the onEdit function
                      }
                    },
                  ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            decoration: const BoxDecoration(
                color: Colors.white,
                border: Border.symmetric(
                    horizontal:
                        BorderSide(color: Color(0xFFE7E8EC), width: 1.0))),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 100.0,
                      child: Text(DateFormat.yMMMd("en_GB")
                          .format(itinerary.departureDate)),
                    ),
                    const SizedBox(
                      width: 16.0,
                    ),
                    CountryFlag.fromCountryCode(
                      itinerary.departureCountry.isoCode,
                      height: 24,
                      width: 20,
                    ),
                    const SizedBox(
                      width: 16.0,
                    ),
                    Text(itinerary.departureCountry.name)
                  ],
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 100.0,
                      child: itinerary.arrivalDate != itinerary.departureDate
                          ? Text(DateFormat.yMMMd("en_GB")
                              .format(itinerary.arrivalDate))
                          : null,
                    ),
                    const SizedBox(
                      width: 16.0,
                    ),
                    CountryFlag.fromCountryCode(
                      itinerary.arrivalCountry.isoCode,
                      height: 24,
                      width: 20,
                    ),
                    const SizedBox(
                      width: 16.0,
                    ),
                    Text(itinerary.arrivalCountry.name)
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
