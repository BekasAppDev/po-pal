import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:po_pal/services/auth/bloc/auth_bloc.dart';
import 'package:po_pal/services/auth/bloc/auth_events.dart';
import 'package:po_pal/services/preferences/bloc/pref_bloc.dart';
import 'package:po_pal/services/preferences/bloc/pref_events.dart';
import 'package:po_pal/services/preferences/bloc/pref_states.dart';
import 'package:po_pal/utilities/dialogs/logout_dialog.dart';
import 'package:po_pal/utilities/enums/sort_option.dart';
import 'package:po_pal/utilities/overlays/delete_user_overlay.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

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
      body: BlocBuilder<PrefBloc, PrefState>(
        builder: (context, state) {
          if (state is PrefStateLoaded) {
            final isKg = state.isKg;
            final exerciseSortOption = state.exerciseSortOption;
            final workoutSortOption = state.workoutSortOption;

            return ListView(
              children: [
                ListTile(
                  title: Text('Weight Unit: ${isKg ? 'Kg' : 'Lbs'}'),
                  trailing: Switch(
                    value: isKg,
                    onChanged: (value) {
                      context.read<PrefBloc>().add(
                        PrefEventSetWeightPref(value),
                      );
                    },
                    activeTrackColor: Colors.white,
                    activeColor: Colors.black,
                    inactiveTrackColor: Colors.white,
                    inactiveThumbColor: Colors.black,
                    trackOutlineColor: WidgetStateProperty.all<Color>(
                      Colors.black,
                    ),
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: Colors.black),
                ListTile(
                  title: Text(
                    'Workout Sorting: ${workoutSortOption == SortOption.alphabetical ? 'Alphabetical' : 'Most Relevant'}',
                  ),
                  trailing: Switch(
                    value: workoutSortOption == SortOption.alphabetical,
                    onChanged: (value) {
                      final newOption =
                          value
                              ? SortOption.alphabetical
                              : SortOption.mostRelevant;
                      context.read<PrefBloc>().add(
                        PrefEventSetWorkoutSortPref(newOption),
                      );
                    },
                    activeTrackColor: Colors.white,
                    activeColor: Colors.black,
                    inactiveTrackColor: Colors.white,
                    inactiveThumbColor: Colors.black,
                    trackOutlineColor: WidgetStateProperty.all<Color>(
                      Colors.black,
                    ),
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: Colors.black),
                ListTile(
                  title: Text(
                    'Exercise Sorting: ${exerciseSortOption == SortOption.alphabetical ? 'Alphabetical' : 'Most Relevant'}',
                  ),
                  trailing: Switch(
                    value: exerciseSortOption == SortOption.alphabetical,
                    onChanged: (value) {
                      final newOption =
                          value
                              ? SortOption.alphabetical
                              : SortOption.mostRelevant;
                      context.read<PrefBloc>().add(
                        PrefEventSetExerciseSortPref(newOption),
                      );
                    },
                    activeTrackColor: Colors.white,
                    activeColor: Colors.black,
                    inactiveTrackColor: Colors.white,
                    inactiveThumbColor: Colors.black,
                    trackOutlineColor: WidgetStateProperty.all<Color>(
                      Colors.black,
                    ),
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: Colors.black),
                ListTile(
                  title: const Text('Log Out'),
                  onTap: () async {
                    final shouldLogout = await showLogOutDialog(context);
                    if (shouldLogout && context.mounted) {
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
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
