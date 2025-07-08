import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:po_pal/services/cloud/cloud_exercise.dart';
import 'package:po_pal/services/cloud/cloud_exercise_history.dart';
import 'package:po_pal/services/cloud/firebase_cloud_storage.dart';
import 'package:po_pal/utilities/charts/exercise_chart.dart';
import 'package:po_pal/utilities/dialogs/delete_exercise_dialog.dart';
import 'package:string_validator/string_validator.dart';

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
      text: widget.exercise.weight.toString(),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(
                      height: 250,
                      child: ExerciseChart(
                        userId: widget.userId,
                        exerciseId: widget.exercise.documentId,
                        mode: false,
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
                              errorText:
                                  weightErrorText.isEmpty
                                      ? null
                                      : weightErrorText,
                              errorStyle: TextStyle(
                                color:
                                    weightErrorText.isEmpty
                                        ? Colors.black
                                        : const Color.fromARGB(
                                          255,
                                          212,
                                          24,
                                          24,
                                        ),
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
                              errorText:
                                  repsErrorText.isEmpty ? null : repsErrorText,
                              errorStyle: TextStyle(
                                color:
                                    repsErrorText.isEmpty
                                        ? Colors.black
                                        : const Color.fromARGB(
                                          255,
                                          212,
                                          24,
                                          24,
                                        ),
                                fontSize: 12.0,
                              ),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () async {
                        final weight = _weightController.text.trim();
                        final reps = _repsController.text.trim();

                        String newWeightError = '';
                        String newRepsError = '';

                        if (weight.isEmpty) {
                          newWeightError = 'Please fill in the weight';
                        } else if (!isNumeric(weight)) {
                          newWeightError = 'Weight must be a number';
                        }

                        if (reps.isEmpty) {
                          newRepsError = 'Please fill in the reps';
                        } else if (!isNumeric(reps)) {
                          newRepsError = 'Reps must be a number';
                        }

                        setState(() {
                          weightErrorText = newWeightError;
                          repsErrorText = newRepsError;
                        });

                        if (newWeightError.isEmpty && newRepsError.isEmpty) {
                          await _storage.updateExercise(
                            uid: widget.userId,
                            documentId: widget.exercise.documentId,
                            weight: int.parse(weight),
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
                    const SizedBox(height: 20),
                    const Text(
                      'History',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: StreamBuilder<Iterable<CloudExerciseHistory>>(
                        stream: _storage.getExerciseHistory(
                          uid: widget.userId,
                          exerciseId: widget.exercise.documentId,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text('Error loading history'),
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
                              return ListView.builder(
                                itemCount: historyEntries.length,
                                itemBuilder: (context, index) {
                                  final entry = historyEntries.elementAt(index);
                                  return ListTile(
                                    title: Text(
                                      '${entry.weight} × ${entry.reps}',
                                    ),
                                    trailing: Text(
                                      DateFormat(
                                        'dd/MM/yy',
                                      ).format(entry.timestamp),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                              );
                            default:
                              return const SizedBox();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
