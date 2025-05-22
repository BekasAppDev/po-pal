import 'package:flutter/material.dart';
import 'package:po_pal/services/cloud/firebase_cloud_storage.dart';
import 'package:po_pal/services/cloud/cloud_exercise.dart';

class TestingBody extends StatefulWidget {
  final String currentUserId;

  const TestingBody({super.key, required this.currentUserId});

  @override
  State<TestingBody> createState() => _TestingBodyState();
}

class _TestingBodyState extends State<TestingBody> {
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();

  final FirebaseCloudStorage _storage = FirebaseCloudStorage();

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    try {
      await _storage.createUserDocument(uid: widget.currentUserId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('User document created')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create user: $e')));
    }
  }

  Future<void> _createExercise() async {
    final name = _nameController.text.trim();
    final weight = int.tryParse(_weightController.text.trim());
    final reps = int.tryParse(_repsController.text.trim());

    if (name.isEmpty || weight == null || reps == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly')),
      );
      return;
    }

    try {
      await _storage.createExercise(
        uid: widget.currentUserId,
        name: name,
        weight: weight,
        reps: reps,
      );

      _nameController.clear();
      _weightController.clear();
      _repsController.clear();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Exercise added')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add exercise: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: _createUser,
            child: const Text('Create User Document'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Exercise Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Weight (kg)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _repsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Reps',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _createExercise,
            child: const Text('Add Exercise'),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: StreamBuilder<Iterable<CloudExercise>>(
              stream: _storage.allExercises(uid: widget.currentUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final exercises = snapshot.data?.toList() ?? [];
                if (exercises.isEmpty) {
                  return const Center(child: Text('No exercises found.'));
                }
                return ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return ListTile(
                      title: Text(exercise.name),
                      subtitle: Text(
                        'Weight: ${exercise.weight} kg, Reps: ${exercise.reps}',
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
