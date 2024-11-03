enum ReminderWhen {
  atTimeOf,
  fiveMinutesBefore,
  fifteenMinutesBefore,
  thirtyMinutesBefore,
}

extension ReminderWhenExtension on ReminderWhen {
  String get name {
    switch (this) {
      case ReminderWhen.atTimeOf:
        return 'At Time Of';
      case ReminderWhen.fiveMinutesBefore:
        return '5 Minutes Before';
      case ReminderWhen.fifteenMinutesBefore:
        return '15 Minutes Before';
      case ReminderWhen.thirtyMinutesBefore:
        return '30 Minutes Before';
    }
  }
}
