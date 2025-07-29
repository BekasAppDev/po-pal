import 'package:flutter/material.dart';
import 'package:po_pal/services/cloud/firebase_cloud_storage.dart';
import 'package:po_pal/utilities/overlays/create_exercise_overlay.dart';
import 'package:po_pal/views/exercises/exercises_list.dart';

class ExercisesView extends StatelessWidget {
  final String userId;
  const ExercisesView({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final FirebaseCloudStorage storage = FirebaseCloudStorage();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ExerciseList(userId: userId),
      ),
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: () async {
            final result = await showCreateExerciseOverlay(context);
            if (result != null) {
              final name = result['name'];
              final weight = result['weight'];
              final reps = result['reps'];

              await storage.createExercise(
                uid: userId,
                name: name,
                weight: weight,
                reps: reps,
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
