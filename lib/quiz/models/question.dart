
import 'option.dart';

class Question {
  final String id;
  final String text;
  final List<Option> options;

  Question({required this.id, required this.text, required this.options});

  // fromMap ve toMap metotlarını da ekleyebilirsiniz, ancak şimdilik bu yeterli.
}
