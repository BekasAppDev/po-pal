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
          return Container();
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final workouts = snapshot.data?.toList() ?? [];
        if (workouts.isEmpty) {
          return Center(
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  'assets/po_pal_icon.png',
                  width: 150,
                  height: 150,
                  color: Color.fromARGB(255, 234, 232, 232),
                ),
                Positioned(
                  bottom: 150 + 10,
                  child: Text(
                    'No workouts yet.\nGet started by creating a workout!',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }

        workouts.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );

        return ListView.builder(
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
                        (context) =>
                            WorkoutDetails(workout: workout, userId: userId),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
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
        );
      },
    );
  }
}
