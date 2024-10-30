import 'package:flutter/material.dart';

import 'package:medication_app/models/medication.dart';

import 'package:medication_app/screens/medication_detail.dart';

enum MoreOptions { edit, delete }

class MedicationCard extends StatelessWidget {
  final Medication medication;

  const MedicationCard(this.medication, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MedicationDetailScreen(
            medication,
          ),
        ),
      ),
      child: Card(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(
                Icons.medication_rounded,
                size: 40,
              ),
              title: Text(medication.name!),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(medication.condition!,
                      style: Theme.of(context).textTheme.bodySmall),
                  Text(
                      'x${medication.prescription!.remainingQuantity.toString()}',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              contentPadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
            ),
          ],
        ),
      ),
    );
  }
}
