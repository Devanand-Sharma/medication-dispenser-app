import 'package:flutter/material.dart';

class DoctorsScreen extends StatelessWidget {
  static const String routeName = '/doctors';
  const DoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctors'),
      ),
    );
  }
}
