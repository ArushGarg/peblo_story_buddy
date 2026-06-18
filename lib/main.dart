import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'models/quiz_question.dart';
import 'providers/story_buddy_provider.dart';
import 'screens/story_buddy_screen.dart';
import 'theme/app_theme.dart';

const _storyText =
    'Once upon a time, a clever little robot named Pip lost his shiny blue gear in the Whispering Woods...';

// This is exactly the shape Peblo's backend would send. Swap this for
// a 3- or 5-option payload to verify QuizCard needs no code changes —
// see README "Data-driven quiz rendering."
final _sampleQuiz = QuizQuestion.fromJson(const {
  'question': "What colour was Pip the Robot's lost gear?",
  'options': ['Red', 'Green', 'Blue', 'Yellow'],
  'answer': 'Blue',
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const PebloStoryBuddyApp());
}

class PebloStoryBuddyApp extends StatelessWidget {
  const PebloStoryBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoryBuddyProvider(storyText: _storyText, quiz: _sampleQuiz),
      child: MaterialApp(
        title: 'Peblo Story Buddy',
        debugShowCheckedModeBanner: false,
        theme: buildPebloTheme(),
        home: const StoryBuddyScreen(),
      ),
    );
  }
}
