import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medication_app/screens/tabs.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _apiUrl = dotenv.env['API_URL'] ?? 'http://localhost:8080';

  Future<void> _handleGoogleSignIn() async {
    try {
      print('Starting Google Sign In process');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Sign in aborted by user');
        return;
      }
      print('Google Sign In successful, getting auth details');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('Got Google auth details');

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print('Created AuthCredential');

      print('Attempting to sign in with Firebase');
      final UserCredential authResult = await _auth.signInWithCredential(credential);
      final User? user = authResult.user;
      print('Firebase sign in complete');

      if (user != null) {
        print('Signed in successfully as ${user.displayName}');
        print('User UUID: ${user.uid}');
        await _syncUserWithBackend(user);
        _showSnackBar('Signed in successfully as ${user.displayName}');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => TabsScreen(user: user),
          ),
        );
      } else {
        print('Sign in failed: User is null');
        _showSnackBar('Sign in failed', isError: true);
      }
    } catch (error) {
      print('Error during Google sign in: $error');
      _showSnackBar('Failed to sign in with Google: $error', isError: true);
    }
  }

  Future<void> _syncUserWithBackend(User firebaseUser) async {
    try {
      final dio = Dio();
      await dio.post(
        '$_apiUrl/api/users/sync',
        data: {
          'id': firebaseUser.uid,
          'name': firebaseUser.displayName,
          'email': firebaseUser.email,
        },
      );
    } catch (error) {
      print('Error syncing user with backend: $error');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(8),
                Text(
                  'Sign in to continue',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(48),
                ElevatedButton.icon(
                  onPressed: _handleGoogleSignIn,
                  label: const Text('Sign in with Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const Gap(16),
                Text(
                  'By signing in, you agree to our Terms of Service and Privacy Policy',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
