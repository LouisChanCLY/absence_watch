import 'package:absence_watch/common/theme.dart';
import 'package:absence_watch/common/util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AbsenceDayesCard extends StatelessWidget {
  final int tripTotalAbsenceDays;
  final DateTime tripArrivalDate;
  final int absenceDays1Y;
  final int absenceDays5Y;

  const AbsenceDayesCard({
    super.key,
    required this.tripTotalAbsenceDays,
    required this.tripArrivalDate,
    required this.absenceDays1Y,
    required this.absenceDays5Y,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFutureTrip = tripArrivalDate.isAfter(DateTime.now());
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
      decoration: BoxDecoration(
          color: primaryElementBackgroundColor,
          border: Border.symmetric(
            horizontal: primaryElementBorderSide,
          )),
      child: Column(
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            const Expanded(
              child: Text(
                'Total Absence Days',
                style: TextStyle(
                  // color: primaryTextColor,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${tripTotalAbsenceDays}',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ]),
          const SizedBox(
            height: 8.0,
          ),
          if (tripTotalAbsenceDays > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    getRAGIcon(
                        absenceDays1Y,
                        (isFutureTrip) ? absenceBudget1Y : absenceBudget12M,
                        absenceBudget12M),
                    const SizedBox(
                      width: 8.0,
                    ),
                    Text(
                        "Rolling 12-Month ($absenceDays1Y / $absenceBudget12M)"),
                  ],
                ),
                if ((absenceDays1Y >= absenceBudget1Y) &&
                    (absenceDays1Y < absenceBudget12M) &&
                    (isFutureTrip))
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 8.0,
                    ),
                    child: Text(
                      "You will be exceeding the 1 year threshold if you are planning to apply for citizenship after the trip.",
                      style: subtitleStyle,
                    ),
                  ),
                const SizedBox(
                  height: 8.0,
                ),
                Row(
                  children: [
                    getRAGIcon(absenceDays5Y, absenceBudget5Y, absenceBudget5Y),
                    const SizedBox(
                      width: 8.0,
                    ),
                    Text("Rolling 5-Year ($absenceDays5Y / $absenceBudget5Y)"),
                  ],
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Text(
                  'Calculation based on your travel history, future trip(s) and the current trip ending on ${DateFormat.yMMMd("en_GB").format(tripArrivalDate)}',
                  style: subtitleStyle,
                ),
              ],
            )
          else
            Text(
              'This trip does not have any full days (Absence Days) outside the UK.',
              style: subtitleStyle,
            ),
        ],
      ),
    );
  }
}
