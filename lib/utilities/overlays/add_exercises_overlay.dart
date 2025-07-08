import 'package:flutter/material.dart';
import 'package:po_pal/services/cloud/cloud_exercise.dart';
import 'package:po_pal/services/cloud/firebase_cloud_storage.dart';

Future<List<String>?> showAddExercisesOverlay(
  BuildContext context, {
  required String userId,
  required List<String> existingExerciseIds,
  required FirebaseCloudStorage storage,
}) async {
  List<String> selectedExerciseIds = [];

  return await showDialog<List<String>?>(
    context: context,
    builder: (context) {
      List<CloudExercise> exercises = [];
      bool isLoading = true;

      return StatefulBuilder(
        builder: (context, setState) {
          if (isLoading) {
            storage
                .allExercises(uid: userId)
                .first
                .then((loadedExercises) {
                  if (context.mounted) {
                    setState(() {
                      exercises =
                          loadedExercises
                              .where(
                                (e) =>
                                    !existingExerciseIds.contains(e.documentId),
                              )
                              .toList();
                      isLoading = false;
                    });
                  }
                })
                .catchError((_) {
                  if (context.mounted) {
                    setState(() => isLoading = false);
                  }
                });
          }

          return AlertDialog(
            title: const Text('Add Exercises'),
            content: SizedBox(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * 0.45,
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : exercises.isEmpty
                      ? const Center(child: Text('No new exercises to add.'))
                      : Scrollbar(
                        child: ListView.builder(
                          itemCount: exercises.length,
                          itemBuilder: (context, index) {
                            final exercise = exercises[index];
                            return CheckboxListTile(
                              title: Text(exercise.name),
                              value: selectedExerciseIds.contains(
                                exercise.documentId,
                              ),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    selectedExerciseIds.add(
                                      exercise.documentId,
                                    );
                                  } else {
                                    selectedExerciseIds.remove(
                                      exercise.documentId,
                                    );
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          },
                        ),
                      ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(selectedExerciseIds),
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    },
  );
}
