import 'package:absence_watch/common/util.dart';
import 'package:absence_watch/pages/trip_details.dart';
import 'package:absence_watch/widgets/avatar_icon.dart';
import 'package:absence_watch/widgets/bottom_navigator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:absence_watch/common/theme.dart';
import 'package:absence_watch/models/profile.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final int _currentPageIndex = 0; // State for the current page
  DateTime selectedMonth = DateTime.now();
  @override
  Widget build(BuildContext context) {
    initializeDateFormatting();
    final profile = Provider.of<Profile>(context, listen: true);
    return Scaffold(
      backgroundColor: pageBackgroundColor,
      appBar: AppBar(
        backgroundColor: pageBackgroundColor,
        leading: ProfileAvatar(
          profileImageUrl: profile.profileImageUrl,
        ),
        title: Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) {
                return;
              }
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const LoginPage()));
            },
          )
        ],
      ),
      body: Consumer<Profile>(builder: (context, profile, child) {
        return SingleChildScrollView(
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
                    )
                  ]
                : [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                            color: Colors.blueGrey.shade100, width: 1.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Number of absence days in the past year',
                            style: subtitleStyle,
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              getRAGIcon(
                                  profile.totalAbsenceDaysIn1Year, 90, 180),
                              const SizedBox(
                                width: 16.0,
                              ),
                              Text(
                                '${profile.totalAbsenceDaysIn1Year} days',
                                style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                            color: Colors.blueGrey.shade100, width: 1.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Number of absence days in the past 5 years',
                            style: subtitleStyle,
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              getRAGIcon(
                                  profile.totalAbsenceDaysIn5Years, 360, 450),
                              const SizedBox(
                                width: 16.0,
                              ),
                              Text(
                                '${profile.totalAbsenceDaysIn1Year} days',
                                style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                            color: Colors.blueGrey.shade100, width: 1.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Maximum absence days over any rolling 12 months',
                            style: subtitleStyle,
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              getRAGIcon(
                                  profile.totalAbsenceDaysIn5Years, 360, 450),
                              const SizedBox(
                                width: 16.0,
                              ),
                              Text(
                                '${profile.totalAbsenceDaysIn1Year} days',
                                style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
          ),
        );
      }),
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
      bottomNavigationBar: CustomBottomNavigator(
        currentIndex: _currentPageIndex,
      ),
    );
  }

  Future<void> _selectMonth(BuildContext context, DateTime initialDate) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SfDateRangePicker(
            view: DateRangePickerView.year,
            selectionMode: DateRangePickerSelectionMode.single,
            initialSelectedDate: initialDate,
            showActionButtons: false,
            allowViewNavigation: false,
            onSelectionChanged: (DateRangePickerSelectionChangedArgs value) {
              if (value.value is DateTime) {
                setState(() {
                  selectedMonth = DateTime(value.value.year, value.value.month);
                });
                Navigator.pop(context);
              }
            },
          ),
        );
      },
    );
  }

  // LineChartData getMonthlyChart(
  //     Set<DateTime> allAbsentDates, DateTime endDate) {
  //   DateTime monthStart = DateTime(endDate.year, endDate.month, 1);
  //   DateTime nextMonthStart = DateUtils.dateOnly(
  //       Jiffy.parseFromDateTime(monthStart).add(months: 1).dateTime);

  //   List<FlSpot> rollingAbsence1Year = [];
  //   List<FlSpot> rollingAbsence5Year = [];

  //   int rollingSum1Year = 0;
  //   int rollingSum5Year = 0;
  //   DateTime currentDate = monthStart;

  //   // Iterate through each day of the month
  //   while (currentDate.isBefore(nextMonthStart)) {
  //     // Check if the current date is an absence date
  //     bool isAbsenceDay = allAbsentDates.contains(currentDate);

  //     // Update rolling sums
  //     if (isAbsenceDay) {
  //       rollingSum1Year++;
  //       rollingSum5Year++;
  //     }

  //     // Handle 1-year rolling sum
  //     if (currentDate.difference(monthStart).inDays >= 365) {
  //       DateTime oneYearAgo = currentDate.subtract(const Duration(days: 365));
  //       bool wasAbsenceOneYearAgo = allAbsentDates.contains(oneYearAgo);
  //       if (wasAbsenceOneYearAgo) {
  //         rollingSum1Year--;
  //       }
  //     }

  //     // Handle 5-year rolling sum
  //     if (currentDate.difference(monthStart).inDays >= 1825) {
  //       DateTime fiveYearsAgo =
  //           currentDate.subtract(const Duration(days: 1825));
  //       bool wasAbsenceFiveYearsAgo = allAbsentDates.contains(fiveYearsAgo);
  //       if (wasAbsenceFiveYearsAgo) {
  //         rollingSum5Year--;
  //       }
  //     }

  //     // Add data points to the lists
  //     rollingAbsence1Year.add(FlSpot(
  //         currentDate.difference(monthStart).inDays.toDouble(),
  //         rollingSum1Year.toDouble()));
  //     rollingAbsence5Year.add(FlSpot(
  //         currentDate.difference(monthStart).inDays.toDouble(),
  //         rollingSum5Year.toDouble()));

  //     // Move to the next day
  //     currentDate = currentDate.add(const Duration(days: 1));
  //   }

  //   // Create and return the LineChartData object
  //   return LineChartData(
  //     lineBarsData: [
  //       LineChartBarData(
  //         spots: rollingAbsence1Year,
  //         isCurved: true,
  //         preventCurveOverShooting: true,
  //         isStrokeCapRound: true,
  //         color: primaryColor,
  //         barWidth: 2,
  //         dotData: FlDotData(show: false),
  //         belowBarData: BarAreaData(
  //           show: false,
  //           color: Colors.blue.withOpacity(0.2),
  //         ),
  //       ),
  //       LineChartBarData(
  //         spots: rollingAbsence5Year,
  //         isCurved: true,
  //         preventCurveOverShooting: true,
  //         isStrokeCapRound: true,
  //         color: primaryColor,
  //         barWidth: 2,
  //         dotData: FlDotData(show: false),
  //         belowBarData: BarAreaData(
  //           show: false,
  //           color: Colors.orange.withOpacity(0.2),
  //         ),
  //       ),
  //     ],
  //     gridData: FlGridData(
  //       show: true,
  //       drawVerticalLine: true,
  //       horizontalInterval: 1,
  //       verticalInterval: 7,
  //       getDrawingHorizontalLine: (value) {
  //         return FlLine(
  //           strokeWidth: 1,
  //           color: Colors.blueGrey.shade100,
  //         );
  //       },
  //       getDrawingVerticalLine: (value) {
  //         return FlLine(
  //           strokeWidth: 1,
  //           color: Colors.blueGrey.shade100,
  //         );
  //       },
  //     ),
  //     borderData: FlBorderData(show: false),
  //     titlesData: FlTitlesData(
  //       show: true,
  //       rightTitles: const AxisTitles(
  //         sideTitles: SideTitles(showTitles: false),
  //       ),
  //       topTitles: const AxisTitles(
  //         sideTitles: SideTitles(showTitles: false),
  //       ),
  //       bottomTitles: AxisTitles(
  //         sideTitles: SideTitles(
  //           showTitles: true,
  //           reservedSize: 30,
  //           interval: 7,
  //           getTitlesWidget: (value, meta) {
  //             final DateTime date =
  //                 monthStart.add(Duration(days: value.toInt()));
  //             return Padding(
  //               padding: const EdgeInsets.only(top: 8.0),
  //               child: Text(
  //                 DateFormat('dd').format(date),
  //                 style: const TextStyle(fontSize: 12),
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //       leftTitles: const AxisTitles(
  //         sideTitles: SideTitles(
  //           showTitles: true,
  //           interval: 1,
  //           reservedSize: 42,
  //         ),
  //       ),
  //     ),
  //     minX: 0,
  //     maxX: nextMonthStart.difference(monthStart).inDays.toDouble() - 1,
  //   );
  // }
}
