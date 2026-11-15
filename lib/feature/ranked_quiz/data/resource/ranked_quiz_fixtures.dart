// Demo content for the ranked quiz UI preview while the backend is pending.
// Values are static placeholders; nothing here is real ranking data.

typedef RankedQuestion = ({String prompt, String note, List<String> options});

abstract final class RankedQuizFixtures {
  static const int dailyLimit = 5;
  static const int attemptsUsed = 3;
  static const int questionCount = 10;
  static const int timeLimitSeconds = 600;

  static const String subject = 'Physics';
  static const String challengeTitle = 'Mechanics & Dynamics Mixed MCQ';
  static const String challengeSummary =
      'Newtonian mechanics, friction vectors, and kinetic energy '
      'application problems.';

  static const RankedQuestion sampleQuestion = (
    prompt:
        'A force of 20 N acts on an object of mass 4 kg initially at rest. '
        'What is the velocity of the object after 5 seconds of continuous '
        'application of the force?',
    note: 'Assume negligible friction (g = 9.8 m/s²)',
    options: ['15 m/s', '25 m/s', '50 m/s', '100 m/s'],
  );

  /// Every preview question reuses the sample until real content arrives.
  static List<RankedQuestion> get questions =>
      List.filled(questionCount, sampleQuestion);
}
