import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:medication_app/providers/medication_provider.dart';

import 'package:medication_app/widgets/medication_card.dart';
import 'package:medication_app/widgets/new_medication_modal.dart';

class MedicationScreen extends ConsumerWidget {
  const MedicationScreen({super.key});

  void _createNewMedication(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: false,
      isDismissible: true,
      enableDrag: true,
      showDragHandle: true,
      backgroundColor: Theme.of(ctx).colorScheme.surface,
      builder: (bCtx) => const SingleChildScrollView(
        child: NewMedicationModal(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationAsyncValue = ref.watch(medicationProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer()),
        title: const Text('Medications'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          )
        ],
      ),
      body: medicationAsyncValue.when(
        data: (medications) => RefreshIndicator(
          onRefresh: () =>
              ref.refresh(medicationProvider.notifier).fetchMedications(),
          child: medications.isEmpty
              ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: MediaQuery.of(context).size.height -
                        kBottomNavigationBarHeight -
                        MediaQuery.of(context).padding.bottom -
                        kToolbarHeight,
                    alignment: Alignment.center,
                    child: const Text('No Medications'),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(5),
                  itemCount: medications.length,
                  itemBuilder: (context, index) =>
                      MedicationCard(medications[index]),
                ),
        ),
        loading: () => Center(
          child: Platform.isIOS
              ? const CupertinoActivityIndicator()
              : const CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => RefreshIndicator(
          onRefresh: () =>
              ref.refresh(medicationProvider.notifier).fetchMedications(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height: MediaQuery.of(context).size.height -
                  kBottomNavigationBarHeight -
                  MediaQuery.of(context).padding.bottom -
                  kToolbarHeight,
              alignment: Alignment.center,
              child: const Text(
                  'Unable to load medications. Please try again later.'),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewMedication(context),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
