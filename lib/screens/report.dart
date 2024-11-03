import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:medication_app/models/calendar.dart';

import 'package:medication_app/widgets/report_list.dart';
import 'package:medication_app/widgets/report_summary.dart';
import 'package:medication_app/widgets/segmented_calendar_button.dart';

class ReportScreen extends StatefulWidget {
  static const String routeName = '/reports';
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  static const double gap = 10;
  Calendar _parentCalendarView = Calendar.week;

  void _updateCalendarView(Calendar newView) {
    setState(() {
      _parentCalendarView = newView;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: gap),
            alignment: Alignment.center,
            child: SegmentedCalendarButton(
              onCalendarViewChanged: _updateCalendarView,
            ),
          ),
          const Gap(gap),
          ReportSummary(
            calendarView: _parentCalendarView,
          ),
          const Gap(gap),
          const Divider(
            color: Colors.grey,
            height: 1,
            thickness: 1,
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: gap / 2),
              child: ReportList(),
            ),
          ),
          const Divider(
            color: Colors.grey,
            height: 1,
            thickness: 1,
          ),
          const Gap(gap / 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: gap),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Export'),
            ),
          ),
          Gap(MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
