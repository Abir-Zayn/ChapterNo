// Sample community data for the in-memory repository: authors, profile,
// activity history, and attachment previews. Demo fixtures only — replace
// with real backend data when Community is connected; never shown as live.
import 'community_fixtures_dependencies.dart';

abstract final class CommunityFixtures {
  static const CommunityAuthor me = CommunityAuthor(
    id: 'me',
    displayName: 'Alex R.',
    initials: 'AR',
    location: 'Chattogram',
  );

  static const List<CommunityAuthor> peers = [
    CommunityAuthor(
      id: 'tanvir',
      displayName: 'Tanvir R.',
      initials: 'TR',
      location: 'Dhaka',
    ),
    CommunityAuthor(
      id: 'sadia',
      displayName: 'Sadia M.',
      initials: 'SM',
      location: 'Rajshahi',
    ),
    CommunityAuthor(
      id: 'abrar',
      displayName: 'Abrar K.',
      initials: 'AK',
      location: 'Chattogram',
    ),
    CommunityAuthor(
      id: 'nusrat',
      displayName: 'Nusrat J.',
      initials: 'NJ',
      location: 'Sylhet',
    ),
  ];

  static const CommunityProfile profile = CommunityProfile(
    displayName: 'Alex R.',
    handle: '@alex_studies',
    initials: 'AR',
    batchLabel: "SSC Batch '26 · Science",
    bio: 'SSC Science student | Learning every day 🔬',
    stats: CommunityProfileStats(
      posts: 24,
      questions: 5,
      notes: 8,
      upvotes: 156,
    ),
    verified: true,
    active: true,
  );

  /// The question shown on the create-post practice-question screen.
  static const PostQuestion sampleQuestion = PostQuestion(
    subject: CommunitySubjects.physics,
    topic: 'Motion',
    badgeLabel: 'Board MCQ Prep',
    sourceLabel: 'Topic MCQ #14',
    stem:
        'A car accelerates uniformly from rest. Which quantity changes at a '
        'constant rate with respect to time?',
    options: [
      PostOption(label: 'A', text: 'Velocity'),
      PostOption(label: 'B', text: 'Acceleration'),
      PostOption(label: 'C', text: 'Displacement'),
      PostOption(label: 'D', text: 'Momentum'),
    ],
  );

  /// The document shown on the create-post notes screen.
  static const PostDocument sampleDocument = PostDocument(
    fileName: 'Cell_Division_Summary_Notes.pdf',
    pageCount: 6,
    sizeLabel: '2.4 MB',
  );

  /// Chapter choices per subject for the notes form; sample curriculum data.
  static const Map<String, List<String>> chapters = {
    CommunitySubjects.physics: ['Ch 2: Motion', 'Ch 3: Force & Newton\'s Laws'],
    CommunitySubjects.chemistry: ['Ch 4: Chemical Reactions'],
    CommunitySubjects.biology: ['Ch 3: Cell Division', 'Ch 5: Life Processes'],
    CommunitySubjects.math: ['Ch 6: Simple Simultaneous Equations'],
    CommunitySubjects.higherMath: ['Ch 2: Trigonometric Ratios'],
    CommunitySubjects.english: ['Ch 1: Parts of Speech'],
    CommunitySubjects.bangla: ['Ch 3: Gyanmulok Prose'],
  };

  /// Chronological activity history, newest first, relative to [now].
  static List<ActivityEntry> activity(DateTime now) => [
    ActivityEntry(
      id: 'a1',
      kind: ActivityKind.postPublished,
      title: 'Post Published',
      summary:
          "Can someone explain Newton's Second Law in simple terms with board "
          'questions?',
      subject: CommunitySubjects.physics,
      detail: 'Topic Q&A · 4 replies',
      at: now.subtract(const Duration(hours: 2)),
    ),
    ActivityEntry(
      id: 'a2',
      kind: ActivityKind.commented,
      title: 'Commented on a Post',
      summary:
          'Understanding chemical bonding, coordinate covalent bonds & '
          'valence electrons',
      subject: CommunitySubjects.chemistry,
      detail: 'Commented: "The lone pair forms the dative bond..."',
      at: now.subtract(const Duration(hours: 5)),
    ),
    ActivityEntry(
      id: 'a3',
      kind: ActivityKind.upvoted,
      title: 'Post Upvoted',
      summary:
          "Top 5 Mnemonics to memorize the Periodic Table trends for SSC '25",
      subject: CommunitySubjects.chemistry,
      detail: 'Posted by Rafsan Ahmed · 142 upvotes',
      at: now.subtract(const Duration(hours: 6)),
    ),
    ActivityEntry(
      id: 'a4',
      kind: ActivityKind.questionShared,
      title: 'Question Shared',
      summary:
          "Motion — Dhaka Board '23 CQ Stem #4: Kinematics graph velocity "
          'transition',
      subject: CommunitySubjects.physics,
      detail: 'Solved by 2 peer mentors',
      at: now.subtract(const Duration(days: 1, hours: 4)),
    ),
    ActivityEntry(
      id: 'a5',
      kind: ActivityKind.notesShared,
      title: 'Notes Shared',
      summary:
          'Cell Division & Mitosis Phases — Complete Hand-Drawn Notes.pdf '
          '(6 pages)',
      subject: CommunitySubjects.biology,
      detail: '67 downloads · 28 saves',
      at: now.subtract(const Duration(days: 1, hours: 8)),
    ),
    ActivityEntry(
      id: 'a6',
      kind: ActivityKind.upvoted,
      title: 'Post Upvoted',
      summary:
          'Short trick to factorize complex cubic polynomials in Higher '
          'Mathematics',
      subject: CommunitySubjects.higherMath,
      detail: '215 upvotes',
      at: now.subtract(const Duration(days: 3)),
    ),
    ActivityEntry(
      id: 'a7',
      kind: ActivityKind.commented,
      title: 'Commented on a Post',
      summary:
          'Is it required to memorize the standard electrode potentials list '
          'completely?',
      subject: CommunitySubjects.chemistry,
      detail: 'Commented: "Only memorizing the active metal series..."',
      at: now.subtract(const Duration(days: 4)),
    ),
    ActivityEntry(
      id: 'a8',
      kind: ActivityKind.notesShared,
      title: 'Notes Shared',
      summary:
          'Bangla 1st Paper: Shubhobartar Kobita & Important Gyanmulok QnA',
      subject: CommunitySubjects.bangla,
      detail: '114 downloads',
      at: now.subtract(const Duration(days: 5)),
    ),
  ];
}
