import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:medication_app/models/reminder_when.dart';
import 'package:medication_app/providers/notifications_provider.dart';
import 'package:medication_app/providers/theme_provider.dart';

class SettingsForm extends ConsumerStatefulWidget {
  const SettingsForm({super.key});

  @override
  ConsumerState<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends ConsumerState<SettingsForm> {
  @override
  Widget build(BuildContext context) {
    // Theme
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.watch(themeProvider.notifier);

    // Notifications
    final notificationsState = ref.watch(notificationsProvider);
    final notificationsNotifier = ref.watch(notificationsProvider.notifier);

    void openDarkModeDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) => SafeArea(
          child: Container(
            padding: const EdgeInsets.all(0),
            child: AlertDialog(
              title: const Text('Select Theme Mode'),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<ThemeMode>(
                    title: const Text('Follow System'),
                    value: ThemeMode.system,
                    groupValue: themeMode,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (newValue) => {
                      setState(() {
                        if (newValue != null) {
                          themeNotifier.setTheme(newValue);
                        }
                      }),
                      Navigator.of(context).pop(),
                    },
                    toggleable: true,
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Light'),
                    value: ThemeMode.light,
                    groupValue: themeMode,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (newValue) => {
                      setState(() {
                        if (newValue != null) {
                          themeNotifier.setTheme(newValue);
                        }
                      }),
                      Navigator.of(context).pop(),
                    },
                    toggleable: true,
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Dark'),
                    value: ThemeMode.dark,
                    groupValue: themeMode,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (newValue) => {
                      setState(() {
                        if (newValue != null) {
                          themeNotifier.setTheme(newValue);
                        }
                      }),
                      Navigator.of(context).pop(),
                    },
                    toggleable: true,
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        ListTile(
          title: const Text('Dark Mode'),
          subtitle: Text(
            'Set dark or light application mode',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          onTap: () => openDarkModeDialog(),
        ),
        ListTile(
          title: const Text('Notifications'),
          trailing: Switch(
            value: notificationsState.isNotifications,
            onChanged: (bool value) =>
                setState(() => notificationsNotifier.setNotifications(value)),
          ),
        ),
        if (notificationsState.isNotifications)
          ListTile(
            title: const Text("Remind At"),
            trailing: SizedBox(
              width: 200,
              child: DropdownButtonFormField<ReminderWhen>(
                value: notificationsState.remindAt,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface),
                items: ReminderWhen.values
                    .map((form) => DropdownMenuItem<ReminderWhen>(
                          value: form,
                          child: Text(form.name),
                        ))
                    .toList(),
                onChanged: (value) => setState(
                  () => notificationsNotifier.setRemindAt(value),
                ),
              ),
            ),
          ),
        ListTile(
          title: const Text('Refill Reminder'),
          trailing: Switch(
            value: notificationsState.isRefillReminder,
            onChanged: (bool value) =>
                setState(() => notificationsNotifier.setRefillReminder(value)),
          ),
        ),
      ],
    );
  }
}
