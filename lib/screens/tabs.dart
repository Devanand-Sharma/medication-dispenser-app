import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:medication_app/screens/history.dart';
import 'package:medication_app/screens/home.dart';
import 'package:medication_app/screens/medication.dart';
import 'package:medication_app/widgets/more_drawer.dart';

final List<Map<String, dynamic>> pages = [
  {
    'page': HomeScreen(user: FirebaseAuth.instance.currentUser!),
    'title': 'Home',
  },
  {
    'page': const MedicationScreen(),
    'title': 'Medication',
  },
  {
    'page': const HistoryScreen(),
    'title': 'History',
  },
];

class TabsScreen extends StatefulWidget {
  static const String routeName = '/tabs';
  final User user;

  const TabsScreen({super.key, required this.user});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  late List<Map<String, dynamic>> _pages;
  int _selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pages = [
      {
        'page': HomeScreen(user: widget.user),
        'title': 'Home',
      },
      {
        'page': const MedicationScreen(),
        'title': 'Medication',
      },
      {
        'page': const HistoryScreen(),
        'title': 'History',
      },
    ];
  }

  // ? Might not need this, since parent widget is stateless
  @override
  void didUpdateWidget(TabsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _pages = pages;
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MoreDrawer(user: widget.user),
      body: _pages[_selectedPageIndex]['page'] as Widget,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        unselectedItemColor: Theme.of(context).colorScheme.onPrimary,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        currentIndex: _selectedPageIndex,
        backgroundColor: Theme.of(context).colorScheme.primary,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).colorScheme.primary,
            icon: const Icon(Icons.home),
            label: _pages[0]['title'] as String,
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).colorScheme.primary,
            icon: const Icon(Icons.medication_rounded),
            label: _pages[1]['title'] as String,
          ),
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).colorScheme.primary,
            icon: const Icon(Icons.calendar_month_rounded),
            label: _pages[2]['title'] as String,
          ),
        ],
      ),
    );
  }
}
