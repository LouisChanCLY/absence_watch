// import 'package:country_pickers/country.dart';

// import '../common/util.dart';
// import 'package:flutter/material.dart';

// class CountryInfoCard extends StatelessWidget {
//   final Country country;
//   final DateTime date;
//   final bool isDeparture; // Indicates whether it's departure or arrival

//   const CountryInfoCard({
//     super.key,
//     required this.country,
//     required this.date,
//     this.isDeparture = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     String formattedDate = formatDate(date);
//     IconData leadingIcon =
//         isDeparture ? Icons.flight_takeoff : Icons.flight_land;

//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Row(
//           children: [
//             Icon(leadingIcon),
//             // Text(country.flagEmoji, style: const TextStyle(fontSize: 24)),
//             const SizedBox(width: 8),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   '${country.flagEmoji} ${country.name}',
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 Text(formattedDate),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
