import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklyPlanService {
  final CollectionReference<Map<String, dynamic>> _plans = FirebaseFirestore
      .instance
      .collection('WEEKLY_PLANS');

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchWeeklyPlan(
    String userId,
  ) {
    return _plans.doc(userId).snapshots();
  }

  Future<void> saveDayEntries({
    required String userId,
    required int dayIndex,
    required List<Map<String, String>> entries,
  }) async {
    await _plans.doc(userId).set({
      'userId': userId,
      'days': {dayIndex.toString(): entries},
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
