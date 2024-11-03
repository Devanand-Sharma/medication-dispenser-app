import 'package:flutter/material.dart';

class HomeMedicationCard extends StatelessWidget {
  const HomeMedicationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
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
              'Medication',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Illness',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface),
                ),
                Text(
                  'Frequency',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
            trailing: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
            ),
            contentPadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton(
                    onPressed: () {
                      // Add your button 1 logic here
                    },
                    child: const Text('Skipped'),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Add your button 2 logic here
                    },
                    child: const Text('Taken'),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
