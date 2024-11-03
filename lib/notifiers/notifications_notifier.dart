import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:medication_app/models/reminder_when.dart';

class NotificationsState {
  final bool isNotifications;
  final ReminderWhen? remindAt;
  final bool isRefillReminder;

  NotificationsState({
    required this.isNotifications,
    required this.remindAt,
    required this.isRefillReminder,
  });

  NotificationsState copyWith({
    bool? isNotifications,
    ReminderWhen? remindAt,
    bool? isRefillReminder,
  }) {
    return NotificationsState(
      isNotifications: isNotifications ?? this.isNotifications,
      remindAt: remindAt ?? this.remindAt,
      isRefillReminder: isRefillReminder ?? this.isRefillReminder,
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier()
      : super(NotificationsState(
          isNotifications: true,
          remindAt: ReminderWhen.atTimeOf,
          isRefillReminder: true,
        )) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isNotifications = prefs.getBool('isNotifications') ?? true;
    final isRefillReminder = prefs.getBool('isRefillReminder') ?? true;
    final remindAtIndex = prefs.getInt('remindAt') ?? 0;
    final remindAt = ReminderWhen.values[remindAtIndex];

    state = state.copyWith(
      isNotifications: isNotifications,
      remindAt: remindAt,
      isRefillReminder: isRefillReminder,
    );
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNotifications', state.isNotifications);
    await prefs.setBool('isRefillReminder', state.isRefillReminder);
    await prefs.setInt('remindAt', state.remindAt!.index);
  }

  void setNotifications(bool value) {
    state = state.copyWith(isNotifications: value);
    _saveToPrefs();
  }

  void setRemindAt(ReminderWhen? value) {
    if (value == null) return;
    state = state.copyWith(remindAt: value);
    _saveToPrefs();
  }

  void setRefillReminder(bool value) {
    state = state.copyWith(isRefillReminder: value);
    _saveToPrefs();
  }
}
