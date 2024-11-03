import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:medication_app/widgets/home_medication_card.dart';

class HomeScreen extends StatelessWidget {
  final User user;
  const HomeScreen({super.key, required this.user});
  static const appBarHeight = 115.0;
  static const appBarSpacing = 5.0;

  // Medical Summary Under App Bar
  Widget _buildSummaryReport(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 2.0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: Theme.of(context).colorScheme.primary,
        height: appBarHeight,
        child: Column(
          children: [
            Text(
              DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.now()),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
            const Gap(appBarSpacing),
            Text(
              '4 Medications',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
            const Gap(appBarSpacing),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
              child: const Text('Log All As Taken'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<int> numbers = List.generate(20, (index) => index);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer()),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {},
          )
        ],
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              child: Icon(
                Icons.person,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Gap(appBarSpacing),
            Text(
              user.displayName ?? 'User',
            )
          ],
        ),
      ),
      // backgroundColor: ThemeData.dark().colorScheme.background,
      body: Column(children: [
        _buildSummaryReport(context),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(5),
            shrinkWrap: true,
            itemCount: numbers.length,
            itemBuilder: (context, index) {
              return const HomeMedicationCard();
            },
          ),
        )
      ]),
    );
  }
}
