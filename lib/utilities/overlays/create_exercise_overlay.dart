import 'package:flutter/material.dart';

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
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(color: Colors.black),
                      floatingLabelStyle: TextStyle(color: Colors.black),
                      errorText:
                          nameErrorText.isNotEmpty ? nameErrorText : null,
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
                      labelStyle: TextStyle(color: Colors.black),
                      floatingLabelStyle: TextStyle(color: Colors.black),
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
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: repsController,
                    decoration: InputDecoration(
                      labelText: 'Starting Reps',
                      labelStyle: TextStyle(color: Colors.black),
                      floatingLabelStyle: TextStyle(color: Colors.black),
                      errorText:
                          repsErrorText.isNotEmpty ? repsErrorText : null,
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
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
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
                    } else if (double.tryParse(weight) == null) {
                      weightErrorText = 'Weight must be a number';
                    }
                    if (reps.isEmpty) {
                      repsErrorText = 'Please fill in the reps';
                    } else if (int.tryParse(reps) == null) {
                      repsErrorText = 'Reps must be an integer';
                    }

                    if (nameErrorText.isEmpty &&
                        weightErrorText.isEmpty &&
                        repsErrorText.isEmpty) {
                      Navigator.of(context).pop({
                        'name': name,
                        'weight': double.parse(weight),
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
