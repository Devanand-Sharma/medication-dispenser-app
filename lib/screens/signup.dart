import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive/hive.dart';
import 'package:medication_app/database_manager/models/user.dart';

class SignUpScreen extends StatefulWidget {
  static const String routeName = '/signup';
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String? _selectedGender;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _checkExistingUsers();
  }

  Future<void> _checkExistingUsers() async {
    try {
      final userBox = await Hive.openBox<User>('users');
      final users = userBox.values.toList();
      print('Existing users: ${users.map((u) => '${u.email}: ${u.firstName} ${u.lastName}').join(', ')}');
      await userBox.close();
    } catch (e) {
      print('Error checking existing users: $e');
    }
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    print('Attempting to sign up - Email: $email, Password: $password, First Name: $firstName, Last Name: $lastName');

    if (email.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    final newUser = User(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      birthday: _selectedDate,
      gender: _selectedGender,
    );

    try {
      final userBox = await Hive.openBox<User>('users');
      print('Hive box opened successfully. Current box length: ${userBox.length}');

      await userBox.add(newUser);

      print('New user added. Updated box length: ${userBox.length}');
      print('All users: ${userBox.values.map((u) => '${u.email}: ${u.firstName} ${u.lastName}').join(', ')}');

      await userBox.close();

      if (!mounted) return;

      _showSnackBar('Registration successful');
      Navigator.of(context).pop();
    } catch (e) {
      print('Error during sign up: $e');
      if (mounted) _showSnackBar('An error occurred during sign up: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }  Future<void> _clearUsers() async {
    try {
      final userBox = await Hive.openBox<User>('users');
      await userBox.clear();
      print('All users cleared. Current box length: ${userBox.length}');
      await userBox.close();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All users cleared')),
      );
    } catch (e) {
      print('Error clearing users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error clearing users: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Email',
                  fillColor: Theme.of(context).colorScheme.surface,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const Gap(16),
              TextField(
                controller: _passwordController,
                style: const TextStyle(color: Colors.black),
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  fillColor: Theme.of(context).colorScheme.surface,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const Gap(16),
              TextField(
                controller: _firstNameController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'First Name',
                  fillColor: Theme.of(context).colorScheme.surface,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const Gap(16),
              TextField(
                controller: _lastNameController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  fillColor: Theme.of(context).colorScheme.surface,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const Gap(16),
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && picked != _selectedDate) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Birthday',
                    fillColor: Theme.of(context).colorScheme.surface,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? 'Select Date'
                            : '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}',
                        style: const TextStyle(color: Colors.black),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const Gap(16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
                items: <String>['Male', 'Female']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Gender',
                  fillColor: Theme.of(context).colorScheme.surface,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const Gap(24),
              ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Sign Up'),
              ),
              const Gap(16),
              ElevatedButton(
                onPressed: _clearUsers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Clear All Users'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}