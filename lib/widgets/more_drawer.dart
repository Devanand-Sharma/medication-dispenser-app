import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final List<Map<String, dynamic>> drawerList = [
  {
    'icon': Icons.event_rounded,
    'title': 'Appointments',
    'route': '/appointments',
  },
  {
    'icon': Icons.medical_services_rounded,
    'title': 'Doctors',
    'route': '/doctors',
  },
  {
    'icon': Icons.autorenew_rounded,
    'title': 'Refills',
    'route': '/refills',
  },
  {
    'icon': Icons.assessment_rounded,
    'title': 'Reports',
    'route': '/reports',
  },
  {
    'icon': Icons.settings_rounded,
    'title': 'Settings',
    'route': '/settings',
  },
];

class MoreDrawer extends StatelessWidget {
  final User user;

  const MoreDrawer({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withAlpha(180),
                ],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      user.displayName ?? 'User',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ...drawerList.map(
                  (item) => ListTile(
                    leading: Icon(item['icon'] as IconData),
                    title: Text(item['title'] as String),
                    onTap: () {
                      Scaffold.of(context).closeDrawer();
                      Navigator.of(context).pushNamed(item['route']);
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
