import 'package:cloud_firestore/cloud_firestore.dart';

class CloudWorkout {
  final String documentId;
  final String title;
  final List<String> exerciseIds;

  CloudWorkout({
    required this.documentId,
    required this.title,
    required this.exerciseIds,
  });

  CloudWorkout.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
    : documentId = snapshot.id,
      title = snapshot.data()?['title'] ?? '',
      exerciseIds = List<String>.from(snapshot.data()?['exerciseIds'] ?? []);
}
