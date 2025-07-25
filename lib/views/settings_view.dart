import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:po_pal/services/auth/bloc/auth_bloc.dart';
import 'package:po_pal/services/auth/bloc/auth_events.dart';
import 'package:po_pal/services/preferences/preferences_service.dart';
import 'package:po_pal/utilities/dialogs/logout_dialog.dart';
import 'package:po_pal/utilities/overlays/delete_user_overlay.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late bool _isKg;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeightPreference();
  }

  Future<void> _loadWeightPreference() async {
    try {
      final isKg = await PreferencesService.getWeightPreference();
      setState(() {
        _isKg = isKg;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isKg = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                children: [
                  ListTile(
                    title: Text('Weight Unit: ${_isKg ? 'kg' : 'lbs'}'),
                    trailing: Switch(
                      value: _isKg,
                      onChanged: (value) async {
                        try {
                          await PreferencesService.setWeightPreference(value);
                          if (mounted) setState(() => _isKg = value);
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to save preference'),
                            ),
                          );
                        }
                      },
                      activeTrackColor: Colors.white,
                      activeColor: Colors.black,
                      inactiveTrackColor: Colors.white,
                      inactiveThumbColor: Colors.black,
                      trackOutlineColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) => Colors.black,
                      ),
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, color: Colors.black),
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
                  const Divider(height: 1, thickness: 1, color: Colors.black),
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
                  const Divider(height: 1, thickness: 1, color: Colors.black),
                ],
              ),
    );
  }
}
