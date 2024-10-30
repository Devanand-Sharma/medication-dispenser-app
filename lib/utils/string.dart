import 'package:flutter/material.dart';

String toSentenceCase(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

int stringToNumber(String str) {
  switch (str.toLowerCase()) {
    case 'zero':
      return 0;
    case 'one':
      return 1;
    case 'two':
      return 2;
    case 'three':
      return 3;
    case 'four':
      return 4;
    case 'five':
      return 5;
    case 'six':
      return 6;
    case 'seven':
      return 7;
    case 'eight':
      return 8;
    case 'nine':
      return 9;
    default:
      throw FormatException('Invalid number string: $str');
  }
}

TimeOfDay stringToTimeOfDay(String timeOfDayString) {
  int? hour = int.tryParse(timeOfDayString.split(":")[0]);
  int? minute;
  if (timeOfDayString.split(":").length > 1) {
    minute = int.tryParse(timeOfDayString.split(":")[1]);
  } else {
    minute = 0;
  }
  if (hour == null || minute == null) {
    return TimeOfDay.now();
  }
  if (timeOfDayString.contains('pm')) {
    hour += 12;
  }
  return TimeOfDay(hour: hour, minute: 0);
}
