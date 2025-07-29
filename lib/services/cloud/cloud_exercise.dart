import 'package:cloud_firestore/cloud_firestore.dart';

class CloudExercise {
  final String documentId;
  final String name;
  final double weight;
  final int reps;
  final int relevancy;

  const CloudExercise({
    required this.documentId,
    required this.name,
    required this.weight,
    required this.reps,
    required this.relevancy,
  });

  CloudExercise.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
    : documentId = snapshot.id,
      name = snapshot.data()?['name'],
      weight = snapshot.data()?['weight'],
      reps = snapshot.data()?['reps'],
      relevancy = snapshot.data()?['relevancy'] ?? 1;
}
