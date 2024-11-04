import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medication_app/database_manager/models/user.dart' as HiveUser;
import 'package:medication_app/screens/appointments.dart';
import 'package:medication_app/screens/cap_prescription.dart';
import 'package:medication_app/screens/doctors.dart';
import 'package:medication_app/screens/refills.dart';
import 'package:medication_app/screens/report.dart';
import 'package:medication_app/screens/settings.dart';
import 'package:medication_app/screens/tabs.dart';
import 'package:medication_app/screens/login.dart';
import 'package:medication_app/screens/signup.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  try {
    Firebase.app();
  } catch (e) {
    await Firebase.initializeApp(
      name: 'medication-dispenser-firebase',
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  final cameras = await availableCameras();
  CameraDescription? camera;
  if (cameras.isNotEmpty) {
    camera = cameras.first;
  }

  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);

  // Register Hive Adapters
  Hive.registerAdapter(HiveUser.UserAdapter());

  // Open Hive boxes
  await Hive.openBox<HiveUser.User>('users');

  runApp(ProviderScope(child: MyApp(camera: camera)));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.camera});

  final CameraDescription? camera;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medication Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Colors.deepPurple).copyWith(
          secondary: Colors.amberAccent,
          onSurface: Colors.black87,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          titleLarge: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          headlineSmall:
              TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          headlineMedium:
              TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(
            fontSize: 20,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasData) {
            return TabsScreen(user: snapshot.data!);
          } else {
            return const LoginScreen();
          }
        },
      ),
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        SignUpScreen.routeName: (context) => const SignUpScreen(),
        AppointmentsScreen.routeName: (context) => const AppointmentsScreen(),
        DoctorsScreen.routeName: (context) => const DoctorsScreen(),
        CapturePrescriptionScreen.routeName: (context) =>
            CapturePrescriptionScreen(camera: camera),
        RefillsScreen.routeName: (context) => const RefillsScreen(),
        ReportScreen.routeName: (context) => const ReportScreen(),
        SettingsScreen.routeName: (context) => const SettingsScreen(),
        TabsScreen.routeName: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as User;
          return TabsScreen(user: args);
        },
      },
    );
  }
}
