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
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                Icons.medication_rounded,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                medication.name,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medication.condition,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                  Text(
                    'x${medication.remainingQuantity.toString()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
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
