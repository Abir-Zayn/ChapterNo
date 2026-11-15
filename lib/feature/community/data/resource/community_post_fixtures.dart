// Sample posts for the community feed and the profile dashboard.
// Demo fixtures only — every name, score, and timestamp is invented and
// must be replaced by real backend data before any production release.
import 'community_post_fixtures_dependencies.dart';

abstract final class CommunityPostFixtures {
  /// Posts from other students that seed the Community feed.
  static List<CommunityPost> feedPosts(DateTime now) => [
    CommunityPost(
      id: 'p1',
      author: CommunityFixtures.peers[0],
      kind: CommunityPostKind.question,
      subject: CommunitySubjects.physics,
      topic: 'Motion',
      title: "Can you solve this motion problem from today's test?",
      question: CommunityFixtures.sampleQuestion,
      postedAt: now.subtract(const Duration(minutes: 25)),
      score: 42,
      commentCount: 12,
    ),
    CommunityPost(
      id: 'p2',
      author: CommunityFixtures.peers[1],
      kind: CommunityPostKind.notes,
      subject: CommunitySubjects.biology,
      topic: 'Cell Division',
      title: 'Chapter 3 — Complete Cell Division Handwritten Revision Notes 🧬',
      body:
          'Organized summary of Mitosis vs Meiosis stages with diagrams for '
          'upcoming SSC prep. Hope this helps everyone!',
      document: CommunityFixtures.sampleDocument,
      postedAt: now.subtract(const Duration(hours: 2)),
      score: 128,
      commentCount: 5,
    ),
    CommunityPost(
      id: 'p3',
      author: CommunityFixtures.peers[2],
      kind: CommunityPostKind.discussion,
      subject: CommunitySubjects.higherMath,
      topic: 'Trigonometry',
      title:
          "What's the easiest visual way to remember trigonometric quotient "
          '& Pythagorean identities?',
      body:
          'I keep getting confused between sin²θ + cos²θ = 1 and sec²θ - '
          'tan²θ = 1 during timed exams. Anyone have a clean memory trick or '
          'unit circle diagram?',
      topAnswerAuthor: 'Mentor Fahim',
      topAnswerText:
          'Use the "Super Hexagon" mnemonic! Place opposite trig ratios '
          'opposite each other, and consecutive triangles give direct squares.',
      postedAt: now.subtract(const Duration(hours: 4)),
      score: 67,
      commentCount: 8,
    ),
    CommunityPost(
      id: 'p4',
      author: CommunityFixtures.peers[3],
      kind: CommunityPostKind.question,
      subject: CommunitySubjects.chemistry,
      topic: 'Chemical Reactions',
      title: 'Need help breaking down this CQ stimulus on reaction rates',
      question: const PostQuestion(
        subject: CommunitySubjects.chemistry,
        topic: 'Chemical Reactions',
        badgeLabel: 'Creative Question (CQ)',
        sourceLabel: "Dhaka Board '23",
        stem:
            'Substance A reacts with Substance B in an exothermic reaction. '
            'The temperature is increased by 10°C, and the concentration of '
            'reactant A is doubled...',
        parts: [
          'ক / A: Activation energy definition',
          'খ / B: Exothermic reaction profile',
          'গ / C: Rate calculation based on collision theory',
        ],
      ),
      postedAt: now.subtract(const Duration(hours: 6)),
      score: 53,
      commentCount: 9,
    ),
  ];

  /// The signed-in student's own posts shown on the profile dashboard.
  static List<CommunityPost> profilePosts(DateTime now) => [
    CommunityPost(
      id: 'p5',
      author: CommunityFixtures.me,
      kind: CommunityPostKind.discussion,
      subject: CommunitySubjects.physics,
      topic: 'Speed & Velocity',
      title: 'Can someone explain the difference between speed and velocity?',
      body:
          "I'm confused about how displacement affects average velocity "
          'during circular motion. Anyone have a clear mental model or '
          'real-life example to remember this for the SSC exam?',
      postedAt: now.subtract(const Duration(days: 2)),
      score: 24,
      commentCount: 8,
    ),
    CommunityPost(
      id: 'p6',
      author: CommunityFixtures.me,
      kind: CommunityPostKind.notes,
      subject: CommunitySubjects.biology,
      topic: 'Cell Division',
      title: 'Cell Division — Quick Revision Notes 🧬',
      body:
          'Handwritten summary covering Mitosis phases, Meiosis significance, '
          'and key diagram prompts frequently asked in SSC board questions.',
      document: const PostDocument(
        fileName: 'Cell_Division_Summary.pdf',
        pageCount: 6,
        sizeLabel: '2.4 MB',
      ),
      postedAt: now.subtract(const Duration(days: 4)),
      score: 42,
      commentCount: 12,
    ),
    CommunityPost(
      id: 'p7',
      author: CommunityFixtures.me,
      kind: CommunityPostKind.question,
      subject: CommunitySubjects.chemistry,
      topic: 'Chemical Reactions',
      title: 'Need help understanding this chemical reaction question',
      question: const PostQuestion(
        subject: CommunitySubjects.chemistry,
        topic: 'Chemical Reactions',
        badgeLabel: 'Creative Question (CQ)',
        sourceLabel: "Dhaka Board '23",
        stem:
            'Reaction rate vs temperature graph for exothermic combination of '
            'gas A & B under catalyst conditions. Identify the activation '
            'energy shift.',
      ),
      postedAt: now.subtract(const Duration(days: 7)),
      score: 18,
      commentCount: 6,
    ),
  ];
}
