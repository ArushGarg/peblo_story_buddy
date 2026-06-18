/// A single quiz question exactly as it would arrive from Peblo's
/// backend.
///
/// Deliberately holds nothing but plain data — [options] can be any
/// length, so anything that renders this (see QuizCard) never assumes
/// a fixed count of answers.
class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
  });

  final String question;
  final List<String> options;
  final String answer;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final options = List<String>.from(json['options'] as List);
    final answer = json['answer'] as String;

    assert(
    options.contains(answer),
    'The answer "$answer" must be one of the provided options.',
    );

    return QuizQuestion(
      question: json['question'] as String,
      options: options,
      answer: answer,
    );
  }

  Map<String, dynamic> toJson() => {
    'question': question,
    'options': options,
    'answer': answer,
  };
}
