import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:po_pal/services/cloud/cloud_exercise.dart';
import 'package:po_pal/services/cloud/firebase_cloud_storage.dart';
import 'package:po_pal/services/preferences/bloc/pref_bloc.dart';
import 'package:po_pal/services/preferences/bloc/pref_states.dart';
import 'package:po_pal/utilities/enums/sort_option.dart';
import 'package:po_pal/views/exercises/exercise_details.dart';

class ExerciseList extends StatelessWidget {
  final String userId;
  const ExerciseList({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final FirebaseCloudStorage storage = FirebaseCloudStorage();

    return BlocBuilder<PrefBloc, PrefState>(
      builder: (context, state) {
        final sortOption =
            state is PrefStateLoaded
                ? state.exerciseSortOption
                : SortOption.alphabetical;

        return StreamBuilder<Iterable<CloudExercise>>(
          stream: storage.allExercises(uid: userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            }
            if (snapshot.hasError) {
              return Center(child: Text('Could not load exercises'));
            }

            final exercises = snapshot.data?.toList() ?? [];
            if (exercises.isEmpty) {
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
                        'No exercises yet.\nGet started by creating an exercise!',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }

            exercises.sort((a, b) {
              switch (sortOption) {
                case SortOption.alphabetical:
                  return a.name.toLowerCase().compareTo(b.name.toLowerCase());
                case SortOption.mostRelevant:
                  return b.relevancy.compareTo(a.relevancy);
              }
            });

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ExerciseDetails(
                              exercise: exercise,
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
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            exercise.name,
                            style: const TextStyle(fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: BlocBuilder<PrefBloc, PrefState>(
                            builder: (context, state) {
                              final isKg =
                                  state is PrefStateLoaded ? state.isKg : true;
                              final unitLabel = isKg ? 'Kg' : 'Lbs';
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    unitLabel,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    '${exercise.weight % 1 == 0 ? exercise.weight.toInt() : exercise.weight}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              );
                            },
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
    );
  }
}
