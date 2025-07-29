import 'package:cloud_firestore/cloud_firestore.dart';

class CloudExerciseHistory {
  final String documentId;
  final double weight;
  final int reps;
  final DateTime timestamp;

  CloudExerciseHistory({
    required this.documentId,
    required this.weight,
    required this.reps,
    required this.timestamp,
  });

  factory CloudExerciseHistory.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return CloudExerciseHistory(
      documentId: snapshot.id,
      weight: data['weight'] as double,
      reps: data['reps'] as int,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
