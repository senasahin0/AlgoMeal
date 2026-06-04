import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/recipe.dart';

class RecipeCommentService {
  final CollectionReference<Map<String, dynamic>> _comments = FirebaseFirestore
      .instance
      .collection('COMMENTS');

  Future<void> addComment({
    required User user,
    required Recipe recipe,
    required String text,
  }) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      return;
    }

    await _comments.add({
      'recipeId': recipe.stableRecipeId,
      'recipeTitle': recipe.title,
      'userId': user.uid,
      'userName': _displayName(user),
      'userEmail': user.email ?? '',
      'text': trimmedText,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> watchComments(Recipe recipe) {
    return _comments
        .where('recipeId', isEqualTo: recipe.stableRecipeId)
        .snapshots()
        .map((snapshot) {
          final comments = snapshot.docs.map((doc) {
            return {...doc.data(), 'commentId': doc.id};
          }).toList();

          comments.sort((first, second) {
            return _commentTime(second).compareTo(_commentTime(first));
          });

          return comments;
        });
  }

  Stream<int> watchUserCommentCount(String userId) {
    return _comments.where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.length;
    });
  }

  String _displayName(User user) {
    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final email = user.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'Kullanıcı';
  }

  int _commentTime(Map<String, dynamic> comment) {
    final value = comment['createdAt'];
    if (value is Timestamp) {
      return value.millisecondsSinceEpoch;
    }

    if (value is String) {
      return DateTime.tryParse(value)?.millisecondsSinceEpoch ?? 0;
    }

    return 0;
  }
}
