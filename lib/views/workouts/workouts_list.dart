import 'package:flutter/material.dart';
import 'package:po_pal/services/cloud/cloud_workout.dart';
import 'package:po_pal/services/cloud/firebase_cloud_storage.dart';
import 'package:po_pal/views/workouts/workout_details.dart';

class WorkoutList extends StatelessWidget {
  final String userId;
  const WorkoutList({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final storage = FirebaseCloudStorage();

    return StreamBuilder<Iterable<CloudWorkout>>(
      stream: storage.allWorkouts(uid: userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Image.asset(
              'assets/po_pal_icon.png',
              width: 150,
              height: 150,
              color: Color.fromARGB(255, 234, 232, 232),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final workouts = snapshot.data?.toList() ?? [];
        if (workouts.isEmpty) {
          return Center(
            child: Image.asset(
              'assets/po_pal_icon.png',
              width: 150,
              height: 150,
              color: const Color.fromARGB(255, 234, 232, 232),
            ),
          );
        }

        workouts.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );

        return Stack(
          children: [
            Center(
              child: Image.asset(
                'assets/po_pal_icon.png',
                width: 150,
                height: 150,
                color: const Color.fromARGB(255, 234, 232, 232),
              ),
            ),
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final workout = workouts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => WorkoutDetails(
                              workout: workout,
                              userId: userId,
                            ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            workout.title,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
