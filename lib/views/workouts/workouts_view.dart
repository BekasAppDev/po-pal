import 'package:flutter/material.dart';
import 'package:po_pal/services/cloud/firebase_cloud_storage.dart';
import 'package:po_pal/utilities/overlays/create_workout_overlay.dart';
import 'package:po_pal/views/workouts/workouts_list.dart';

class WorkoutsView extends StatelessWidget {
  final String userId;
  const WorkoutsView({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final FirebaseCloudStorage storage = FirebaseCloudStorage();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: WorkoutList(userId: userId),
      ),
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: () async {
            final result = await showCreateWorkoutOverlay(
              context,
              userId: userId,
              storage: storage,
            );
            if (result != null) {
              await storage.createWorkout(
                uid: userId,
                title: result['title'],
                exerciseIds: result['exerciseIds'],
              );
            }
          },
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          shape: const CircleBorder(),
          elevation: 0,
          highlightElevation: 0,
          child: const Icon(Icons.add_rounded, size: 42),
        ),
      ),
    );
  }
}
