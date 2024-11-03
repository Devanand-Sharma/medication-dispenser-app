// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';

import 'package:medication_app/models/scheduled_time.dart';
import 'package:medication_app/models/medication.dart';
import 'package:medication_app/models/medication_route.dart';
import 'package:medication_app/models/medication_frequency.dart';
import 'package:medication_app/providers/medication_provider.dart';
import 'package:medication_app/utils/string.dart';

class MedicationFormScreen extends ConsumerStatefulWidget {
  final Medication? medication;
  final bool isEditing;
  const MedicationFormScreen(
      {super.key, this.medication, this.isEditing = false});

  @override
  MedicationFormScreenState createState() => MedicationFormScreenState();
}

class MedicationFormScreenState extends ConsumerState<MedicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool? isDarkMode;
  TextStyle? _textStyle;
  TextStyle? _labelStyle;

  String? _name;
  String? _condition;
  MedicationRoute? _medicationRoute;
  int? _dose;

  final TextEditingController _totalQuantityController =
      TextEditingController();
  final TextEditingController _remainingQuantityController =
      TextEditingController();
  int _thresholdQuantity = 10;
  bool _remainingQuantityTouched = false;
  bool _isUpdatingTotalQuantity = false;

  MedicationFrequency? _medicationFrequency;
  int? _medicationFrequencyCount;
  int _minMedicationFrequencyCount = 1;
  int _maxMedicationFrequencyCount = 1;

  final List<TextEditingController> _scheduledTimesControllers =
      List.generate(6, (_) => TextEditingController());
  final List<TimeOfDay?> _scheduledTimes =
      List<TimeOfDay?>.generate(6, (_) => null);
  DateTime? _startDate;
  final TextEditingController _startDateController = TextEditingController();
  DateTime? _endDate;
  final TextEditingController _endDateController = TextEditingController();
  String? _instructions;

  @override
  void initState() {
    super.initState();

    _totalQuantityController.addListener(_updateRemainingQuantity);
    _remainingQuantityController.addListener(() {
      if (!_isUpdatingTotalQuantity) {
        _remainingQuantityTouched = true;
      }
    });

    if (widget.medication != null) {
      _name = widget.medication!.name;
      _condition = widget.medication!.condition;
      _medicationRoute = widget.medication!.route;
      _dose = widget.medication!.dose;
      _thresholdQuantity = widget.medication!.thresholdQuantity;
      _medicationFrequency = widget.medication!.frequency;
      _medicationFrequencyCount =
          setMedicationFrequencyCount(_medicationFrequency);
      _minMedicationFrequencyCount =
          setMinMedicationFrequencyCount(_medicationFrequency);
      _maxMedicationFrequencyCount =
          setMaxMedicationFrequencyCount(_medicationFrequency);
      _medicationFrequencyCount = widget.medication!.frequencyCount;
      for (int i = 0; i < widget.medication!.scheduledTimes.length; i++) {
        _scheduledTimes[i] = widget.medication!.scheduledTimes[i].time;
      }
      _startDate = widget.medication!.startDate;
      _endDate = widget.medication!.endDate;
      _instructions = widget.medication!.instructions;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    isDarkMode = Theme.of(context).brightness == Brightness.dark;

    _textStyle = TextStyle(
      color: isDarkMode! ? Colors.white : Colors.black,
    );

    _labelStyle = TextStyle(
      color: isDarkMode! ? Colors.white70 : Colors.black54,
    );

    if (widget.medication != null) {
      _totalQuantityController.text =
          widget.medication!.totalQuantity.toString();
      _remainingQuantityController.text =
          widget.medication!.remainingQuantity.toString();
      for (int i = 0; i < widget.medication!.scheduledTimes.length; i++) {
        _scheduledTimesControllers[i].text =
            widget.medication!.scheduledTimes[i].time.format(context);
      }
      _startDateController.text =
          DateFormat('dd-MMM-yyyy').format(widget.medication!.startDate);
      if (widget.medication!.endDate != null) {
        _endDateController.text =
            DateFormat('dd-MMM-yyyy').format(widget.medication!.endDate!);
      }
    }
  }

  @override
  void dispose() {
    _totalQuantityController.dispose();
    _remainingQuantityController.dispose();
    for (final controller in _scheduledTimesControllers) {
      controller.dispose();
    }
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _updateRemainingQuantity() {
    if (!_remainingQuantityTouched) {
      _isUpdatingTotalQuantity = true;
      _remainingQuantityController.text = _totalQuantityController.text;
      _isUpdatingTotalQuantity = false;
    }
  }

  void submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Medication upsertedMedcation;

      // Create temporary list of ScheduledTime objects
      final List<ScheduledTime> scheduledTimes = [];
      if (_medicationFrequencyCount != null) {
        for (int i = 0; i < _medicationFrequencyCount!; i++) {
          if (_scheduledTimes[i] == null) {
            continue;
          }
          scheduledTimes.add(
            ScheduledTime(
              id: widget.medication?.scheduledTimes[i].id ?? 0,
              time: _scheduledTimes[i]!,
              medicationId: widget.medication?.id ?? 0,
            ),
          );
        }
      } else {
        scheduledTimes.add(
          ScheduledTime(
            id: widget.medication?.scheduledTimes[0].id ?? 0,
            time: _scheduledTimes[0]!,
            medicationId: widget.medication?.id ?? 0,
          ),
        );
      }

      // Create temporary Medication object with the form data, this will be converted to json
      final newMedication = Medication(
        id: widget.medication?.id ?? 0,
        name: _name!,
        condition: _condition!,
        route: _medicationRoute!,
        dose: _dose!,
        totalQuantity: int.parse(_totalQuantityController.text),
        remainingQuantity: int.parse(_remainingQuantityController.text),
        thresholdQuantity: _thresholdQuantity,
        frequency: _medicationFrequency!,
        frequencyCount: _medicationFrequencyCount,
        startDate: _startDate!,
        endDate: _endDate,
        instructions: _instructions,
        scheduledTimes: scheduledTimes,
        administeredTimes: [],
        refillDates: [],
      );

      if (!widget.isEditing) {
        // Add Medication
        try {
          await ref
              .read(medicationProvider.notifier)
              .addMedication(newMedication);
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Failed to add medication. Please try again later.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        if (!context.mounted) return;
        Navigator.of(context).popUntil(ModalRoute.withName('/'));
      } else {
        // Update Medication
        try {
          upsertedMedcation = await ref
              .read(medicationProvider.notifier)
              .updateMedication(newMedication);
          if (!context.mounted) return;
          Navigator.of(context).pop(upsertedMedcation);
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Failed to update medication. Please try again later.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          if (!context.mounted) return;
          Navigator.of(context).pop();
        }
      }
    }
  }

  Future<void> _selectTime(BuildContext context, int index) async {
    final intialTime = _scheduledTimes[index] ?? TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: intialTime,
    );
    if (picked != null) {
      setState(() {
        _scheduledTimes[index] = picked;
        _scheduledTimesControllers[index].text = picked.format(context);
      });
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: isDarkMode!
              ? ThemeData.dark().copyWith(
                  colorScheme: ColorScheme.dark(
                    primary: Theme.of(context).colorScheme.inversePrimary,
                    onPrimary: Colors.white,
                    surface: Colors.grey[800]!,
                    onSurface: Colors.white,
                  ),
                  dialogBackgroundColor: Colors.grey[900],
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                )
              : ThemeData.light(),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _startDateController.text = DateFormat('dd-MMM-yyyy').format(picked);
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: isDarkMode!
              ? ThemeData.dark().copyWith(
                  colorScheme: ColorScheme.dark(
                    primary: Theme.of(context).colorScheme.inversePrimary,
                    onPrimary: Colors.white,
                    surface: Colors.grey[800]!,
                    onSurface: Colors.white,
                  ),
                  dialogBackgroundColor: Colors.grey[900],
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                )
              : ThemeData.light(),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _endDateController.text = DateFormat('dd-MMM-yyyy').format(picked);
      });
    }
  }

  Widget _buildDoseWithUnits(BuildContext context, Widget textFormField) {
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Expanded(child: textFormField),
      Padding(
        padding: const EdgeInsets.only(left: 5),
        child: Text(
          medicationRouteToUnit(_medicationRoute),
        ),
      ),
    ]);
  }

  InputDecoration _buildTextFormFieldLabel(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: _labelStyle,
      border: const OutlineInputBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Update Medication' : 'Add Medication'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextFormField(
                decoration: _buildTextFormFieldLabel('Medication Name'),
                initialValue: _name,
                onChanged: (value) => setState(() => _name = value),
                onSaved: (value) => _name = value,
                style: _textStyle,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a medication name';
                  }
                  return null;
                },
              ),
              const Gap(16),
              TextFormField(
                initialValue: _condition,
                onChanged: (value) => setState(() => _name = value),
                onSaved: (value) => _condition = value,
                decoration: _buildTextFormFieldLabel('Condition'),
                style: _textStyle,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a medication condition';
                  }
                  return null;
                },
              ),
              const Gap(16),
              DropdownButtonFormField<MedicationRoute>(
                value: _medicationRoute,
                onChanged: (value) => setState(() => _medicationRoute = value),
                onSaved: (value) => _medicationRoute = value,
                decoration: _buildTextFormFieldLabel('Medication Form'),
                style: _textStyle,
                items: MedicationRoute.values
                    .map((form) => DropdownMenuItem<MedicationRoute>(
                          value: form,
                          child: Text(toSentenceCase(form.name)),
                        ))
                    .toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select an administration route';
                  }
                  return null;
                },
              ),
              const Gap(16),
              _buildDoseWithUnits(
                context,
                TextFormField(
                  keyboardType: TextInputType.number,
                  initialValue: _dose?.toString(),
                  onChanged: (value) =>
                      setState(() => _dose = int.parse(value)),
                  onSaved: (value) => _dose = int.tryParse(value!),
                  decoration: _buildTextFormFieldLabel('Dose'),
                  style: _textStyle,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a dose';
                    }
                    return null;
                  },
                ),
              ),
              const Gap(16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _buildDoseWithUnits(
                        context,
                        TextFormField(
                          keyboardType: TextInputType.number,
                          controller: _totalQuantityController,
                          decoration: _buildTextFormFieldLabel('Total'),
                          style: _textStyle,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the total quantity';
                            }
                            return null;
                          },
                        )),
                  ),
                  const Gap(16),
                  Expanded(
                    child: _buildDoseWithUnits(
                      context,
                      TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _remainingQuantityController,
                        decoration: _buildTextFormFieldLabel('Remaining'),
                        style: _textStyle,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the remaining quantity';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(16),
              _buildDoseWithUnits(
                context,
                TextFormField(
                  keyboardType: TextInputType.number,
                  initialValue: _thresholdQuantity.toString(),
                  onChanged: (value) =>
                      setState(() => _thresholdQuantity = int.parse(value)),
                  onSaved: (value) => _thresholdQuantity = int.parse(value!),
                  decoration: _buildTextFormFieldLabel('Threshold Quantity'),
                  style: _textStyle,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a threshold quantity';
                    }
                    return null;
                  },
                ),
              ),
              const Gap(16),
              DropdownButtonFormField<MedicationFrequency>(
                value: _medicationFrequency,
                onChanged: (value) {
                  setState(() {
                    if (value != _medicationFrequency) {
                      _medicationFrequencyCount =
                          setMedicationFrequencyCount(value);
                      _minMedicationFrequencyCount =
                          setMinMedicationFrequencyCount(value);
                      _maxMedicationFrequencyCount =
                          setMaxMedicationFrequencyCount(value);
                    }
                    _medicationFrequency = value;
                  });
                },
                decoration: _buildTextFormFieldLabel('Frequency'),
                style: _textStyle,
                items: MedicationFrequency.values
                    .map((form) => DropdownMenuItem<MedicationFrequency>(
                          value: form,
                          child: Text(toSentenceCase(form.name)),
                        ))
                    .toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a medication frequency';
                  }
                  return null;
                },
              ),
              const Gap(16),
              if (isFrequencyCount(_medicationFrequency))
                Column(
                  children: [
                    _medicationFrequency == MedicationFrequency.everyXHours
                        ? DropdownButtonFormField<int>(
                            value: _medicationFrequencyCount,
                            onChanged: (value) => setState(
                                () => _medicationFrequencyCount = value),
                            onSaved: (value) =>
                                _medicationFrequencyCount = value,
                            decoration:
                                _buildTextFormFieldLabel('Every X Hours'),
                            style: _textStyle,
                            items: [2, 3, 4, 6, 8, 12]
                                .map((val) => DropdownMenuItem<int>(
                                      value: val,
                                      child: Text(val.toString()),
                                    ))
                                .toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a medication frequency';
                              }
                              return null;
                            },
                          )
                        : Center(
                            child: NumberPicker(
                              axis: Axis.horizontal,
                              value: _medicationFrequencyCount!,
                              minValue: _minMedicationFrequencyCount,
                              maxValue: _maxMedicationFrequencyCount,
                              onChanged: (value) => setState(
                                  () => _medicationFrequencyCount = value),
                            ),
                          ),
                    const Gap(16),
                  ],
                ),
              if (_medicationFrequency == MedicationFrequency.onceADay)
                Column(
                  children: [
                    TextFormField(
                      controller: _scheduledTimesControllers[0],
                      readOnly: true,
                      onTap: () => _selectTime(context, 0),
                      decoration: _buildTextFormFieldLabel('Time'),
                      style: _textStyle,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a time';
                        }
                        return null;
                      },
                    ),
                    const Gap(16),
                  ],
                ),
              if (_medicationFrequency == MedicationFrequency.xTimesADay)
                for (int i = 0; i < _medicationFrequencyCount!; i++)
                  Column(
                    children: [
                      TextFormField(
                        controller: _scheduledTimesControllers[i],
                        readOnly: true,
                        onTap: () => _selectTime(context, i),
                        decoration: _buildTextFormFieldLabel('Time ${i + 1}'),
                        style: _textStyle,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a time';
                          }
                          return null;
                        },
                      ),
                      const Gap(16),
                    ],
                  ),
              if (isEveryX(_medicationFrequency))
                Column(
                  children: [
                    TextFormField(
                      controller: _scheduledTimesControllers[0],
                      readOnly: true,
                      onTap: () => _selectTime(context, 0),
                      decoration: _buildTextFormFieldLabel('Enter First Time'),
                      style: _textStyle,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the time of your first dose';
                        }
                        return null;
                      },
                    ),
                    const Gap(16),
                  ],
                ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startDateController,
                      readOnly: true,
                      onTap: () => _selectStartDate(context),
                      decoration: _buildTextFormFieldLabel('Start Date'),
                      style: _textStyle,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a start date';
                        }
                        return null;
                      },
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: TextFormField(
                      controller: _endDateController,
                      readOnly: true,
                      onTap: () => _selectEndDate(context),
                      decoration: InputDecoration(
                        labelText: 'End Date (Optional)',
                        labelStyle: _labelStyle,
                        suffixIcon: _endDate != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => setState(() {
                                  _endDateController.clear();
                                  _endDate = null;
                                }),
                              )
                            : null,
                        border: const OutlineInputBorder(),
                      ),
                      style: _textStyle,
                    ),
                  ),
                ],
              ),
              const Gap(16),
              TextFormField(
                initialValue: _instructions,
                onChanged: (value) => setState(() => _instructions = value),
                onSaved: (value) => _instructions = value,
                decoration: _buildTextFormFieldLabel('Instructions (Optional)'),
                style: _textStyle,
              ),
              const Gap(24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: submitForm,
                  child: Text(widget.isEditing
                      ? 'Update Medication'
                      : 'Add Medication'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
