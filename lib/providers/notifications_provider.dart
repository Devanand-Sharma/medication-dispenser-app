import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:medication_app/notifiers/notifications_notifier.dart';

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>(
  (ref) {
    return NotificationsNotifier();
  },
);
