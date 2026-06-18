import 'package:flutter_test/flutter_test.dart';
import 'package:peblo_story_buddy/models/quiz_question.dart';

void main() {
  test('parses a JSON quiz with four options', () {
    final quiz = QuizQuestion.fromJson(const {
      'question': "What colour was Pip the Robot's lost gear?",
      'options': ['Red', 'Green', 'Blue', 'Yellow'],
      'answer': 'Blue',
    });

    expect(quiz.options, hasLength(4));
    expect(quiz.options, contains(quiz.answer));
  });

  test('parses a JSON quiz with three options just as well', () {
    final quiz = QuizQuestion.fromJson(const {
      'question': 'Where does Pip live?',
      'options': ['A city', 'The Whispering Woods', 'The moon'],
      'answer': 'The Whispering Woods',
    });

    expect(quiz.options, hasLength(3));
  });
}
