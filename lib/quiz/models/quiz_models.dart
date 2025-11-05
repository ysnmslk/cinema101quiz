
import 'package:cloud_firestore/cloud_firestore.dart';

class Quiz {
  final String id;
  final String title;
  final String description;
  final String topic;
  final String imageUrl;
  final int durationMinutes;
  final Timestamp createdAt;
  List<Question>? questions; // Sonradan yüklenebilir

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.topic,
    required this.imageUrl,
    required this.durationMinutes,
    required this.createdAt,
    this.questions,
  });

  // Firestore'dan Quiz nesnesi oluşturma
  factory Quiz.fromFirestore(String id, Map<String, dynamic> data) {
    return Quiz(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      topic: data['topic'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      durationMinutes: data['durationMinutes'] ?? 0,
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  // Firestore'a yazmak için Quiz nesnesini Map'e dönüştürme
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'topic': topic,
      'imageUrl': imageUrl,
      'durationMinutes': durationMinutes,
      'createdAt': createdAt,
    };
  }
}

class Question {
  final String id;
  final String text;
  final List<Option> options;

  Question({required this.id, required this.text, required this.options});

  factory Question.fromFirestore(String id, Map<String, dynamic> data) {
    try {
      final rawOptions = (data['options'] as List<dynamic>? ?? []);
      
      // Firestore şeması: correctAnswerIndex veya correctIndex desteklenir
      // String, int, num gibi farklı formatları destekle
      int parseCorrectIndex(dynamic value) {
        if (value is int) return value;
        if (value is num) return value.toInt();
        if (value is String) {
          final parsed = int.tryParse(value);
          return parsed ?? -1;
        }
        return -1;
      }
      
      final int correctIndex = data.containsKey('correctAnswerIndex')
          ? parseCorrectIndex(data['correctAnswerIndex'])
          : (data.containsKey('correctIndex')
              ? parseCorrectIndex(data['correctIndex'])
              : -1);

      // Esnek şema desteği: options elemanları Map veya String olabilir.
      final parsedOptions = <Option>[];
      for (var i = 0; i < rawOptions.length; i++) {
        final item = rawOptions[i];
        if (item is Map<String, dynamic>) {
          final hasExplicitFlag = item.containsKey('isCorrect') || item.containsKey('correct') || item.containsKey('is_correct');
          final String text = item['text']?.toString() ?? '';
          if (hasExplicitFlag) {
            // Map içinde doğru/yanlış bayrağı varsa normal parse
            final parsed = Option.fromMap(item);
            parsedOptions.add(Option(text: text, isCorrect: parsed.isCorrect));
          } else {
            // Yalnızca text varsa, doğru seçeneği indeks üzerinden belirle
            parsedOptions.add(Option(
              text: text,
              isCorrect: i == correctIndex,
            ));
          }
        } else if (item is String) {
          parsedOptions.add(Option(
            text: item,
            isCorrect: i == correctIndex,
          ));
        } else {
          // Tanınmayan format için güvenli geriye dönüş
          parsedOptions.add(Option(text: item?.toString() ?? '', isCorrect: false));
        }
      }

      return Question(
        id: id,
        text: data['text']?.toString() ?? '',
        options: parsedOptions,
      );
    } catch (e) {
      // Hata durumunda boş options ile soru oluştur (loglama için)
      // ignore: avoid_print
      print('Question.fromFirestore hata: $e, data: $data');
      return Question(
        id: id,
        text: data['text']?.toString() ?? 'Soru yüklenemedi',
        options: [],
      );
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'options': options.map((opt) => opt.toMap()).toList(),
    };
  }
}

class Option {
  final String text;
  final bool isCorrect;

  Option({required this.text, this.isCorrect = false});

  factory Option.fromMap(Map<String, dynamic> map) {
    // Esnek şema ve tip dönüştürme: 'isCorrect'|'correct'|'is_correct' ve bool/string/num destekle
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final v = value.trim().toLowerCase();
        return v == 'true' || v == '1' || v == 'yes';
      }
      return false;
    }

    final dynamicRaw = map.containsKey('isCorrect')
        ? map['isCorrect']
        : (map.containsKey('correct')
            ? map['correct']
            : (map.containsKey('is_correct') ? map['is_correct'] : false));

    return Option(
      text: map['text'] ?? '',
      isCorrect: parseBool(dynamicRaw),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'isCorrect': isCorrect,
    };
  }
}

// Düzeltme: Kullanıcının bir quiz'e verdiği cevabı temsil eden model
class UserQuizResult {
  final String quizId;
  final int score;
  final int totalQuestions;
  final Timestamp completedAt;

  UserQuizResult({
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
  });

  factory UserQuizResult.fromFirestore(Map<String, dynamic> data) {
    return UserQuizResult(
      quizId: data['quizId'] ?? '',
      score: data['score'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      completedAt: data['completedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }
}

// Düzeltme: Profil ve sertifika ekranları için birleştirilmiş model
class QuizResultDetails {
  final UserQuizResult result;
  final Quiz quiz;

  QuizResultDetails({required this.result, required this.quiz});
}
