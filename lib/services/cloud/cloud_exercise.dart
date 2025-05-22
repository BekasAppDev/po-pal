import 'package:cloud_firestore/cloud_firestore.dart';

class CloudExercise {
  final String documentId;
  final String name;
  final int weight;
  final int reps;

  const CloudExercise({
    required this.documentId,
    required this.name,
    required this.weight,
    required this.reps,
  });

  CloudExercise.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
    : documentId = snapshot.id,
      name = snapshot.data()?['name'],
      weight = snapshot.data()?['weight'],
      reps = snapshot.data()?['reps'];
}
