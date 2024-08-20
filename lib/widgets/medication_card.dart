import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:medication_app/database_manager/models/medication.dart';
import 'package:medication_app/providers/medication_provider.dart';
import 'package:medication_app/screens/medication_form.dart';

enum MoreOptions { edit, delete }

class MedicationCard extends ConsumerStatefulWidget {
  final Medication medication;

  const MedicationCard(this.medication, {super.key});

  @override
  ConsumerState<MedicationCard> createState() => _MedicationCardState();
}

class _MedicationCardState extends ConsumerState<MedicationCard> {
  MoreOptions? selectedItem;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(
              Icons.medication_rounded,
              size: 40,
            ),
            title: Text(widget.medication.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.medication.condition,
                    style: Theme.of(context).textTheme.bodySmall),
                widget.medication.count != null
                    ? Text('x${widget.medication.count.toString()}',
                        style: Theme.of(context).textTheme.bodySmall)
                    : const SizedBox(),
              ],
            ),
            trailing: PopupMenuButton<MoreOptions>(
              initialValue: selectedItem,
              onSelected: (MoreOptions item) {
                setState(() {
                  selectedItem = item;
                });
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<MoreOptions>>[
                PopupMenuItem<MoreOptions>(
                  value: MoreOptions.delete,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MedicationFormScreen(
                        medication: widget.medication,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const Gap(10),
                      Text('Edit',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary)),
                    ],
                  ),
                ),
                PopupMenuItem<MoreOptions>(
                  value: MoreOptions.delete,
                  onTap: () {
                    ref
                        .read(medicationProvider.notifier)
                        .removeMedication(widget.medication);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const Gap(10),
                      Text('Delete',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary)),
                    ],
                  ),
                ),
              ],
            ),
            contentPadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
          ),
        ],
      ),
    );
  }
}