import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:po_pal/services/cloud/cloud_exercise.dart';
import 'package:po_pal/services/cloud/cloud_workout.dart';
import 'package:po_pal/services/cloud/firebase_cloud_storage.dart';
import 'package:po_pal/services/preferences/bloc/pref_bloc.dart';
import 'package:po_pal/services/preferences/bloc/pref_states.dart';
import 'package:po_pal/utilities/dialogs/delete_workout_dialog.dart';
import 'package:po_pal/utilities/dialogs/remove_exercise_dialog.dart';
import 'package:po_pal/utilities/enums/sort_option.dart';
import 'package:po_pal/utilities/overlays/add_exercises_overlay.dart';
import 'package:po_pal/views/exercises/exercise_details.dart';

class WorkoutDetails extends StatefulWidget {
  final CloudWorkout workout;
  final String userId;

  const WorkoutDetails({
    super.key,
    required this.workout,
    required this.userId,
  });

  @override
  State<WorkoutDetails> createState() => _WorkoutDetailsState();
}

class _WorkoutDetailsState extends State<WorkoutDetails> {
  late List<String> exerciseIds;
  late final FirebaseCloudStorage _storage;

  @override
  void initState() {
    _storage = FirebaseCloudStorage();
    exerciseIds = List<String>.from(widget.workout.exerciseIds);
    super.initState();
  }

  void updateWorkout(List<String> updatedIds) async {
    await _storage.updateWorkout(
      uid: widget.userId,
      documentId: widget.workout.documentId,
      title: widget.workout.title,
      exerciseIds: updatedIds,
    );
    setState(() {
      exerciseIds = updatedIds;
    });
  }

  void removeExercise(String exerciseId) {
    final updated = List<String>.from(exerciseIds)..remove(exerciseId);
    updateWorkout(updated);
  }

  void addExercises(List<String> newIds) {
    final updated = List<String>.from(exerciseIds)..addAll(newIds);
    updateWorkout(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.workout.title),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'add':
                  final newExerciseIds = await showAddExercisesOverlay(
                    context,
                    userId: widget.userId,
                    existingExerciseIds: exerciseIds,
                    storage: _storage,
                  );

                  if (newExerciseIds != null && newExerciseIds.isNotEmpty) {
                    addExercises(newExerciseIds);
                  }
                  break;

                case 'delete':
                  final shouldDelete = await showDeleteWorkoutDialog(context);
                  if (shouldDelete == true) {
                    await _storage.deleteWorkout(
                      uid: widget.userId,
                      documentId: widget.workout.documentId,
                    );
                    if (context.mounted) Navigator.pop(context);
                  }
                  break;
              }
            },
            itemBuilder:
                (context) => const [
                  PopupMenuItem(value: 'add', child: Text('Add Exercises')),
                  PopupMenuItem(value: 'delete', child: Text('Delete Workout')),
                ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<PrefBloc, PrefState>(
          builder: (context, state) {
            final SortOption sortOption =
                state is PrefStateLoaded
                    ? state.exerciseSortOption
                    : SortOption.alphabetical;

            return StreamBuilder<Iterable<CloudExercise>>(
              stream: _storage.allExercises(uid: widget.userId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allExercises = snapshot.data!.toList();
                final filtered =
                    allExercises
                        .where((e) => exerciseIds.contains(e.documentId))
                        .toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No exercises in this workout.'),
                  );
                }
                filtered.sort((a, b) {
                  switch (sortOption) {
                    case SortOption.alphabetical:
                      return a.name.toLowerCase().compareTo(
                        b.name.toLowerCase(),
                      );
                    case SortOption.mostRelevant:
                      return b.relevancy.compareTo(a.relevancy);
                  }
                });

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final exercise = filtered[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ExerciseDetails(
                                  exercise: exercise,
                                  userId: widget.userId,
                                ),
                          ),
                        );
                      },
                      onLongPress: () async {
                        final shouldDelete = await showRemoveExerciseDialog(
                          context,
                        );
                        if (shouldDelete) {
                          removeExercise(exercise.documentId);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.black),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                exercise.name,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Kg',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    '${exercise.weight}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Reps',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    '${exercise.reps}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
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
          },
        ),
      ),
    );
  }
}
