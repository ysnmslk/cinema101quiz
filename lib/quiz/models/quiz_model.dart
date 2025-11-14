import 'package:cloud_firestore/cloud_firestore.dart';

class Quiz {
  final String id;
  final String title;
  final String description;
  final String topic;
  final int durationMinutes;
  final String imageUrl;
  final List<Question> questions;
  final Timestamp? createdAt;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.topic,
    required this.durationMinutes,
    required this.imageUrl,
    required this.questions,
    this.createdAt, // required kaldırıldı ve nullable yapıldı
  });

  factory Quiz.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    
    // Safely parse string fields
    String safeString(dynamic value, String defaultValue) {
      if (value == null) return defaultValue;
      if (value is String) return value;
      return value.toString();
    }
    
    // Safely parse int field
    int safeInt(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        return int.tryParse(value) ?? defaultValue;
      }
      return defaultValue;
    }
    
    // Safely parse questions
    List<Question> questionsList = [];
    if (data['questions'] != null && data['questions'] is List) {
      try {
        questionsList = (data['questions'] as List).map((q) {
          if (q is Map<String, dynamic>) {
            return Question.fromMap(q);
          } else {
            // If question is not a Map, try to convert it
            return Question.fromMap({'id': '', 'text': q.toString(), 'options': []});
          }
        }).toList();
      } catch (e) {
        // If parsing fails, use empty list
        questionsList = [];
      }
    }
    
    return Quiz(
      id: doc.id,
      title: safeString(data['title'], ''),
      description: safeString(data['description'], ''),
      topic: safeString(data['topic'], ''),
      durationMinutes: safeInt(data['durationMinutes'], 0),
      imageUrl: safeString(data['imageUrl'], ''),
      questions: questionsList,
      createdAt: data['createdAt'] is Timestamp ? data['createdAt'] as Timestamp : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'topic': topic,
      'durationMinutes': durationMinutes,
      'imageUrl': imageUrl,
      'questions': questions.map((q) => q.toMap()).toList(),
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}

class Question {
  final String id;
  final String text;
  final List<dynamic> options;
  final int? correctAnswerIndex; // nullable yapıldı

  Question({
    required this.id,
    required this.text,
    required this.options,
    this.correctAnswerIndex, // required kaldırıldı
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    // Safely parse id - could be String or Map
    String questionId = '';
    if (map['id'] != null) {
      if (map['id'] is String) {
        questionId = map['id'] as String;
      } else {
        questionId = map['id'].toString();
      }
    }
    
    // Safely parse text
    String questionText = '';
    if (map['text'] != null) {
      if (map['text'] is String) {
        questionText = map['text'] as String;
      } else {
        questionText = map['text'].toString();
      }
    }
    
    // Safely parse options - could be List<String> or List<Map>
    List<dynamic> questionOptions = [];
    if (map['options'] != null) {
      if (map['options'] is List) {
        questionOptions = (map['options'] as List).map((opt) {
          if (opt is String) {
            return opt;
          } else if (opt is Map) {
            // If option is a Map, extract text field
            return opt['text']?.toString() ?? opt.toString();
          } else {
            return opt.toString();
          }
        }).toList();
      }
    }
    
    // Safely parse correctAnswerIndex
    int? correctIndex;
    if (map['correctAnswerIndex'] != null) {
      if (map['correctAnswerIndex'] is int) {
        correctIndex = map['correctAnswerIndex'] as int;
      } else if (map['correctAnswerIndex'] is num) {
        correctIndex = (map['correctAnswerIndex'] as num).toInt();
      } else if (map['correctAnswerIndex'] is String) {
        correctIndex = int.tryParse(map['correctAnswerIndex'] as String);
      }
    }
    
    return Question(
      id: questionId,
      text: questionText,
      options: questionOptions,
      correctAnswerIndex: correctIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'options': options,
      if (correctAnswerIndex != null) 'correctAnswerIndex': correctAnswerIndex,
    };
  }
}