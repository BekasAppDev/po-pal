import 'package:flutter/material.dart';
import 'package:po_pal/services/cloud/cloud_exercise.dart';
import 'package:po_pal/services/cloud/firebase_cloud_storage.dart';
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
  @override
  Widget build(BuildContext context) {
    final storage = FirebaseCloudStorage();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.exercise.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'delete':
                  final shouldDelete = await showDeleteExerciseDialog(context);
                  if (shouldDelete == true) {
                    await storage.deleteWorkout(
                      uid: widget.userId,
                      documentId: widget.exercise.documentId,
                    );
                    if (context.mounted) Navigator.pop(context);
                  }
                  break;
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
      body: Center(child: Text('Details for ${widget.exercise.name}')),
    );
  }
}
