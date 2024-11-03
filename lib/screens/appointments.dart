import 'package:flutter/material.dart';

class AppointmentsScreen extends StatelessWidget {
  static const String routeName = '/appointments';
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
      ),
    );
  }
}
