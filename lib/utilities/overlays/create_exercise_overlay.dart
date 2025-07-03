import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';

Future<Map<String, dynamic>?> showCreateExerciseOverlay(
  BuildContext context,
) async {
  final nameController = TextEditingController();
  final weightController = TextEditingController();
  final repsController = TextEditingController();

  return await showDialog<Map<String, dynamic>?>(
    context: context,
    builder: (context) {
      String nameErrorText = '';
      String weightErrorText = '';
      String repsErrorText = '';

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('New Exercise'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Exercise Name',
                    labelStyle: TextStyle(color: Colors.black), // Add this line
                    floatingLabelStyle: TextStyle(
                      color: Colors.black,
                    ), // Add this line
                    errorText: nameErrorText.isNotEmpty ? nameErrorText : null,
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
                TextField(
                  controller: weightController,
                  decoration: InputDecoration(
                    labelText: 'Starting Weight',
                    labelStyle: TextStyle(color: Colors.black), // Add this line
                    floatingLabelStyle: TextStyle(
                      color: Colors.black,
                    ), // Add this line
                    errorText:
                        weightErrorText.isNotEmpty ? weightErrorText : null,
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
                TextField(
                  controller: repsController,
                  decoration: InputDecoration(
                    labelText: 'Starting Reps',
                    labelStyle: TextStyle(color: Colors.black), // Add this line
                    floatingLabelStyle: TextStyle(
                      color: Colors.black,
                    ), // Add this line
                    errorText: repsErrorText.isNotEmpty ? repsErrorText : null,
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
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final weight = weightController.text.trim();
                  final reps = repsController.text.trim();

                  setState(() {
                    nameErrorText = '';
                    weightErrorText = '';
                    repsErrorText = '';

                    if (name.isEmpty) {
                      nameErrorText = 'Please enter an exercise name';
                    }
                    if (weight.isEmpty) {
                      weightErrorText = 'Please fill in the weight';
                    } else if (!isNumeric(weight)) {
                      weightErrorText = 'Weight must be a number';
                    }
                    if (reps.isEmpty) {
                      repsErrorText = 'Please fill in the reps';
                    } else if (!isNumeric(reps)) {
                      repsErrorText = 'Reps must be a number';
                    }

                    if (nameErrorText.isEmpty &&
                        weightErrorText.isEmpty &&
                        repsErrorText.isEmpty) {
                      Navigator.of(context).pop({
                        'name': name,
                        'weight': int.parse(weight),
                        'reps': int.parse(reps),
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
