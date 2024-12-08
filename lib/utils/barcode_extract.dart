import 'package:medication_app/models/medication_frequency.dart';
import 'package:medication_app/models/medication_route.dart';
import 'package:medication_app/utils/string.dart';

const String textNumbers = r'one|two|three|four|five|six|seven|eight|nine';

MedicationRoute determineMedicineRoute(String text) {
  text = text.toLowerCase();
  MedicationRoute extractedRoute = MedicationRoute.other;
  if (RegExp(r'((\binject(ion)?\b)|(\bshots?\b))').hasMatch(text)) {
    extractedRoute = MedicationRoute.injection;
  } else if (RegExp(r'((\bpuffs?\b)|\binhaler\b)').hasMatch(text)) {
    extractedRoute = MedicationRoute.inhaler;
  } else if (RegExp(r'capsules?').hasMatch(text)) {
    extractedRoute = MedicationRoute.capsule;
  } else if (RegExp(r'tabs?(lets?)?').hasMatch(text)) {
    extractedRoute = MedicationRoute.tablet;
  } else if (RegExp(r'drops?').hasMatch(text)) {
    extractedRoute = MedicationRoute.drops;
  } else if (RegExp(r'powder').hasMatch(text)) {
    extractedRoute = MedicationRoute.powder;
  } else if (RegExp(r'tablespoons?').hasMatch(text)) {
    extractedRoute = MedicationRoute.solutionTbsp;
  } else if (RegExp(r'teaspoons?').hasMatch(text)) {
    extractedRoute = MedicationRoute.solutionTsp;
  }
  return extractedRoute;
}

int? determineMedicineDose(String text) {
  text = text.toLowerCase();
  RegExp exp = RegExp(
      r'(\d+|''$textNumbers'r')(?=\W((shots?)|(capsules?)|(puffs?)|(tabs?(lets?)?)|(drops?)|(tablespoons?)|(teaspoons?)))');

  String? match = exp.stringMatch(text);
  try {
    return stringToNumber(match!);
  } on FormatException {
    return int.tryParse(match!);
  } catch (e) {
    return null;
  }
}

MedicationFrequency? determineMedicineFrequency(String text) {
  text = text.toLowerCase();
  MedicationFrequency? frequency;
  // TODO: replace the \d to make it capable of matching string numbers - one, two, etc...

  if (RegExp(r'((once\s)?(a|(every))|one\stime\sa)\sday').hasMatch(text)) {
    frequency = MedicationFrequency.onceADay;
  } else if (RegExp(r'(once\s)?(every\s\d+)\sdays').hasMatch(text)) {
    frequency = MedicationFrequency.everyXDays;
  } else if (RegExp(r'(once\s)?(a|every\s?(\d*?|''$textNumbers'r'))\shours?').hasMatch(text)) {
    frequency = MedicationFrequency.everyXHours;
  } else if (RegExp(r'(once\s)?(a|every\s?(\d*?|''$textNumbers'r'))\sweeks?').hasMatch(text)) {
    frequency = MedicationFrequency.everyXWeeks;
  } else if (RegExp(r'(once\s)?(a|every\s?(\d*?|''$textNumbers'r'))\smonths?').hasMatch(text)) {
    frequency = MedicationFrequency.everyXMonths;
  } else if (RegExp(r'(twice\sa\sday|(\d+|''$textNumbers'r')\stimes\sa\day)')
      .hasMatch(text)) {
    frequency = MedicationFrequency.xTimesADay;
  } else if (RegExp(r'take\s(only\s)?as\sneeded').hasMatch(text)) {
    frequency = MedicationFrequency.onlyAsNeeded;
  }
  return frequency;
}

int? determineMedicineFrequencyCount(String text) {
  text = text.toLowerCase();
  if (RegExp(r'twice\sa\sday').hasMatch(text)) {
    return 2;
  }
  RegExp exp = RegExp(r'((?<=every\s?)(\d+|''$textNumbers'r')(?=\s(days|hours|weeks|months))|(d+|''$textNumbers'r')(?=(\stimes\sa\day|\w+\stimes\sa\sday)))');
  String? match = exp.stringMatch(text);
  try {
    return stringToNumber(match!);
  } on FormatException {
    return int.tryParse(match!);
  } catch (e) {
    return null;
  }
}

int? determineTotalQuantity(String text) {
  text = text.toLowerCase();
  RegExp exp = RegExp(r'(?<=(q(uanti)?ty|total):?\s?)(\d+|''$textNumbers'r')(?=\b)');
  String? match = exp.stringMatch(text);
  try {
    return stringToNumber(match!);
  } on FormatException {
    return int.tryParse(match!);
  } catch (e) {
    return null;
  }
}