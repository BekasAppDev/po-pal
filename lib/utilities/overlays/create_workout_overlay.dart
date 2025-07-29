import 'package:flutter/material.dart';
import 'package:po_pal/services/cloud/cloud_exercise.dart';
import 'package:po_pal/services/cloud/firebase_cloud_storage.dart';

Future<Map<String, dynamic>?> showCreateWorkoutOverlay(
  BuildContext context, {
  required String userId,
  required FirebaseCloudStorage storage,
}) async {
  final nameController = TextEditingController();
  List<String> selectedExerciseIds = [];
  String? titleErrorText;

  return await showDialog<Map<String, dynamic>?>(
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
                      exercises = loadedExercises.toList();
                      isLoading = false;
                    });
                  }
                })
                .catchError((error) {
                  if (context.mounted) {
                    setState(() {
                      isLoading = false;
                    });
                  }
                });
          }

          return AlertDialog(
            title: const Text('New Workout'),
            contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
            content: SingleChildScrollView(
              child: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: const TextStyle(color: Colors.black),
                        floatingLabelStyle: const TextStyle(
                          color: Colors.black,
                        ),
                        errorText: titleErrorText,
                        errorStyle: TextStyle(
                          color: Color.fromARGB(255, 212, 24, 24),
                          fontSize: 12.0,
                        ),
                        border: const OutlineInputBorder(),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 212, 24, 24),
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Select Exercises',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.22,
                      child:
                          isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : exercises.isEmpty
                              ? const Center(
                                child: Text(
                                  'No exercises found. Create some first!',
                                ),
                              )
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
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                    );
                                  },
                                ),
                              ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final title = nameController.text.trim();

                  setState(() {
                    titleErrorText = null;

                    if (title.isEmpty) {
                      titleErrorText = 'Please enter a workout title';
                    } else {
                      Navigator.of(context).pop({
                        'title': title,
                        'exerciseIds': selectedExerciseIds,
                      });
                    }
                  });
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      );
    },
  );
}
