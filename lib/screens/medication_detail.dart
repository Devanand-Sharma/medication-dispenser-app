import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:medication_app/models/medication.dart';
import 'package:medication_app/providers/medication_provider.dart';
import 'package:medication_app/screens/medication_form.dart';

class MedicationDetailScreen extends ConsumerStatefulWidget {
  final Medication medication;

  const MedicationDetailScreen(
    this.medication, {
    super.key,
  });

  @override
  ConsumerState<MedicationDetailScreen> createState() =>
      _MedicationDetailScreenState();
}

class _MedicationDetailScreenState
    extends ConsumerState<MedicationDetailScreen> {
  late Medication medication;

  @override
  void initState() {
    super.initState();
    setState(() {
      medication = widget.medication;
    });
  }

  // Medication Detail Header
  Widget _buildMedicationHeader(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medication,
                  size: 48,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const Gap(5),
                Text(
                  medication.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                medication.condition,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Confirm Deletion',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: const Text('Are you sure you want to delete this medication?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), // Close the dialog
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop(); // Close the dialog
              await ref
                  .read(medicationProvider.notifier)
                  .removeMedication(widget.medication);
              if (!context.mounted) return;
              Navigator.of(context).pop(); // Return to Medication Card
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              final Medication? updatedMedication =
                  await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MedicationFormScreen(
                    medication: medication,
                    isEditing: true,
                  ),
                ),
              );

              if (updatedMedication != null) {
                setState(() {
                  medication = updatedMedication;
                });
              }
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () => _showDeleteConfirmationDialog(context, ref),
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMedicationHeader(context),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              'Reminders',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              'Medication Count',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              'Form',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              'Instructions',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
          // Text(medication.dose.toString()),
          // Text(medication.doseSchedule.dosageInterval.toString()),
          // Text(medication.doseSchedule.doseCount.toString()),
          // Text(medication.doseSchedule.doseTimes.toString()),
        ],
      ),
    );
  }
}
