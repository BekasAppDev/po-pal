import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:po_pal/services/cloud/cloud_exercise.dart';
import 'package:po_pal/services/cloud/cloud_exercise_history.dart';
import 'package:po_pal/services/cloud/firebase_cloud_storage.dart';
import 'package:po_pal/utilities/charts/exercise_chart.dart';
import 'package:po_pal/utilities/dialogs/delete_exercise_dialog.dart';

class ExerciseDetails extends StatefulWidget {
  final CloudExercise exercise;
  final String userId;

  const ExerciseDetails({
    super.key,
    required this.exercise,
    required this.userId,
  });

  @override
  State<ExerciseDetails> createState() => _ExerciseDetailsState();
}

class _ExerciseDetailsState extends State<ExerciseDetails> {
  late final TextEditingController _weightController;
  late final TextEditingController _repsController;
  late final FirebaseCloudStorage _storage;
  String weightErrorText = '';
  String repsErrorText = '';

  @override
  void initState() {
    _storage = FirebaseCloudStorage();
    _weightController = TextEditingController(
      text:
          widget.exercise.weight % 1 == 0
              ? widget.exercise.weight.toInt().toString()
              : widget.exercise.weight.toString(),
    );
    _repsController = TextEditingController(
      text: widget.exercise.reps.toString(),
    );
    super.initState();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.exercise.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'delete') {
                final shouldDelete = await showDeleteExerciseDialog(context);
                if (shouldDelete == true) {
                  await _storage.deleteExercise(
                    uid: widget.userId,
                    documentId: widget.exercise.documentId,
                  );
                  if (context.mounted) Navigator.pop(context);
                }
              }
            },
            itemBuilder:
                (context) => const [
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete Exercise'),
                  ),
                ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(
                height: 300,
                child: ExerciseChart(
                  userId: widget.userId,
                  exerciseId: widget.exercise.documentId,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Weight',
                        labelStyle: const TextStyle(color: Colors.black),
                        floatingLabelStyle: const TextStyle(
                          color: Colors.black,
                        ),
                        errorText: weightErrorText,
                        errorStyle: TextStyle(
                          color:
                              weightErrorText.isEmpty
                                  ? Colors.black
                                  : const Color.fromARGB(255, 212, 24, 24),
                          fontSize: 12.0,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _repsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Reps',
                        labelStyle: const TextStyle(color: Colors.black),
                        floatingLabelStyle: const TextStyle(
                          color: Colors.black,
                        ),
                        errorText: repsErrorText,
                        errorStyle: TextStyle(
                          color:
                              repsErrorText.isEmpty
                                  ? Colors.black
                                  : const Color.fromARGB(255, 212, 24, 24),
                          fontSize: 12.0,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  final weight = _weightController.text.trim();
                  final reps = _repsController.text.trim();

                  String newWeightError = '';
                  String newRepsError = '';

                  if (weight.isEmpty) {
                    newWeightError = 'Please fill in the weight';
                  } else if (double.tryParse(weight) == null) {
                    newWeightError = 'Weight must be a number';
                  }

                  if (reps.isEmpty) {
                    newRepsError = 'Please fill in the reps';
                  } else if (int.tryParse(reps) == null) {
                    newRepsError = 'Reps must be an integer';
                  }

                  setState(() {
                    weightErrorText = newWeightError;
                    repsErrorText = newRepsError;
                  });

                  if (newWeightError.isEmpty && newRepsError.isEmpty) {
                    await _storage.updateExercise(
                      uid: widget.userId,
                      documentId: widget.exercise.documentId,
                      weight: double.parse(weight),
                      reps: int.parse(reps),
                    );
                  }
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Update Exercise'),
              ),
              const SizedBox(height: 40),
              Divider(
                height: 1,
                thickness: 2,
                color: Colors.black,
                radius: BorderRadius.circular(1),
              ),
              Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: const Text(
                    'History',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  children: [
                    StreamBuilder<Iterable<CloudExerciseHistory>>(
                      stream: _storage.getExerciseHistory(
                        uid: widget.userId,
                        exerciseId: widget.exercise.documentId,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text('Could not load history'),
                          );
                        }

                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final historyEntries = snapshot.data ?? [];
                            return Column(
                              children:
                                  historyEntries
                                      .map(
                                        (entry) => ListTile(
                                          title: Text(
                                            '${entry.weight % 1 == 0 ? entry.weight.toInt() : entry.weight} × ${entry.reps}',
                                          ),
                                          trailing: Text(
                                            DateFormat(
                                              'dd/MM/yy',
                                            ).format(entry.timestamp),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                            );
                          default:
                            return const SizedBox();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
