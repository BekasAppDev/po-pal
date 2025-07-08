import 'package:flutter/material.dart';

Future<String?> showDeleteUserOverlay(BuildContext context) async {
  final TextEditingController passwordController = TextEditingController();

  return await showDialog<String?>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Confirm Deletion'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your password to delete your account:'),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final password = passwordController.text.trim();
              if (password.isNotEmpty) {
                Navigator.of(context).pop(password);
              }
            },
            child: const Text(
              'Confirm',
              style: TextStyle(color: Color.fromARGB(255, 212, 24, 24)),
            ),
          ),
        ],
      );
    },
  );
}
