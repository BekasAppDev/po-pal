import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:po_pal/services/auth/bloc/auth_bloc.dart';
import 'package:po_pal/services/auth/bloc/auth_events.dart';
import 'package:po_pal/utilities/dialogs/logout_dialog.dart';
import 'package:po_pal/utilities/overlays/delete_user_overlay.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Log Out'),
            onTap: () async {
              final shouldLogout = await showLogOutDialog(context);
              if (shouldLogout) {
                if (!context.mounted) return;
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(const AuthEventLogOut());
              }
            },
          ),
          Divider(height: 1, thickness: 1, color: Colors.black),
          ListTile(
            title: const Text(
              'Delete account',
              style: TextStyle(color: Color.fromARGB(255, 212, 24, 24)),
            ),
            onTap: () async {
              final password = await showDeleteUserOverlay(context);
              if (password != null && context.mounted) {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(
                  AuthEventDeleteUser(password: password),
                );
              }
            },
          ),
          Divider(height: 1, thickness: 1, color: Colors.black),
        ],
      ),
    );
  }
}
