import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:medication_app/models/medication.dart';

final dio = Dio();

class MedicationNotifier extends AsyncNotifier<List<Medication>> {
  Timer? _timer;

  @override
  Future<List<Medication>> build() async {
    // Initial Fetch from Backend
    _startPeriodicFetch();
    return fetchMedications();
  }

  void _startPeriodicFetch() {
    // Cancel any existing timer
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      state = AsyncData(await fetchMedications());
    });
  }

  Future<List<Medication>> fetchMedications() async {
    try {
      final response = await dio.get('http://localhost:8080/api/v1/medications');

      if (response.statusCode == 200) {
        final medications = (response.data as List)
            .map((med) => Medication.fromJson(med))
            .toList();
        state = AsyncData(medications);
        return medications;
      } else {
        throw Exception('Failed to fetch medications');
      }
    } catch (e) {
      throw Exception('Failed to fetch medications: $e');
    }
  }

  Future<Medication> addMedication(Medication medicationData) async {
    // Convert the Medication instance to a JSON-compatible map
    Map<String, dynamic> medicationJson = medicationData.toJson();

    try {
      final response = await dio.post(
        'http://localhost:8080/api/v1/medications',
        data: medicationJson,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 201) {
        final medication = Medication.fromJson(response.data);
        state = AsyncData([...state.value!, medication]);
        return medication;
      } else {
        throw Exception('Failed to add medication');
      }
    } catch (e) {
      throw Exception('Failed to add medication: $e');
    }
  }

  Future<Medication> updateMedication(Medication medicationData) async {
    // Convert the Medication instance to a JSON-compatible map
    Map<String, dynamic> medicationJson = medicationData.toJson();

    try {
      final response = await dio.patch(
        'http://localhost:8080/api/v1/medications/${medicationData.id}',
        data: medicationJson,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final medication = Medication.fromJson(response.data);
        // Update the state with the updated medication
        state = AsyncData([
          for (final med in state.value!)
            if (med.id == medication.id) medication else med
        ]);
        return medication;
      } else {
        throw Exception('Failed to add medication');
      }
    } catch (e) {
      throw Exception('Failed to add medication: $e');
    }
  }

  Future<void> removeMedication(Medication medication) async {
    try {
      final response = await dio.delete(
        'http://localhost:8080/api/v1/medications/${medication.id}',
      );

      if (response.statusCode == 200) {
        final medicationId = response.data;
        // Remove the medication from the state
        state = AsyncData([
          for (final med in state.value!)
            if (med.id != medicationId) med
        ]);
      } else {
        throw Exception('Failed to remove medication');
      }
    } catch (e) {
      throw Exception('Failed to remove medication: $e');
    }
  }
}
