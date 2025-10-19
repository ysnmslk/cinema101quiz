
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final int totalScore;
  final String levelTitle;
  final int questionsSuggested;
  final int questionsApproved;
  final DateTime joinDate;

  UserModel({
    required this.uid,
    required this.username,
    required this.totalScore,
    required this.levelTitle,
    required this.questionsSuggested,
    required this.questionsApproved,
    required this.joinDate,
  });

  /// Firestore'dan gelen Map verisini UserModel nesnesine dönüştürür.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      username: map['username'] as String,
      totalScore: map['total_score'] as int,
      levelTitle: map['level_title'] as String,
      questionsSuggested: map['questions_suggested'] as int,
      questionsApproved: map['questions_approved'] as int,
      joinDate: (map['join_date'] as Timestamp).toDate(),
    );
  }

  /// UserModel nesnesini Firestore'a yazılacak bir Map'e dönüştürür.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'total_score': totalScore,
      'level_title': levelTitle,
      'questions_suggested': questionsSuggested,
      'questions_approved': questionsApproved,
      'join_date': Timestamp.fromDate(joinDate),
    };
  }
}
