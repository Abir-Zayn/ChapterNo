// Post content shared in the Community feed, including the kinds of
// attachments a post can carry: a practice question or a PDF document.
import 'community_post_dependencies.dart';

/// The kinds of content a student can share with the Community.
enum CommunityPostKind { discussion, question, notes }

/// A student's vote on a post; only one direction can be active at a time.
enum VoteValue { none, up, down }

/// How the feed orders posts.
enum CommunityFeedSort { forYou, latest, top }

/// One answer option of a shared multiple-choice question.
class PostOption extends Equatable {
  const PostOption({required this.label, required this.text});

  /// Option letter, for example 'A'.
  final String label;
  final String text;

  @override
  List<Object?> get props => [label, text];
}

/// A practice question attached to a post: a topic MCQ or a board CQ.
class PostQuestion extends Equatable {
  const PostQuestion({
    required this.subject,
    required this.topic,
    required this.badgeLabel,
    required this.sourceLabel,
    required this.stem,
    this.options = const [],
    this.parts = const [],
  });

  /// Curriculum subject the question belongs to.
  final String subject;

  /// Short topic label within the subject.
  final String topic;

  /// For example 'Board MCQ Prep' or 'Creative Question (CQ)'.
  final String badgeLabel;

  /// For example 'Topic MCQ #14' or "Dhaka Board '23".
  final String sourceLabel;
  final String stem;

  /// Non-empty for multiple-choice questions.
  final List<PostOption> options;

  /// CQ part summaries, for example 'ক / A: Activation energy definition'.
  final List<String> parts;

  bool get isCreative => parts.isNotEmpty;

  @override
  List<Object?> get props => [
    subject,
    topic,
    badgeLabel,
    sourceLabel,
    stem,
    options,
    parts,
  ];
}

/// A PDF document attached to a notes post.
class PostDocument extends Equatable {
  const PostDocument({
    required this.fileName,
    required this.pageCount,
    required this.sizeLabel,
  });

  final String fileName;
  final int pageCount;
  final String sizeLabel;

  String get metaLabel =>
      'PDF · $pageCount ${pageCount == 1 ? 'Page' : 'Pages'} · $sizeLabel';

  @override
  List<Object?> get props => [fileName, pageCount, sizeLabel];
}

/// One post in the Community feed.
class CommunityPost extends Equatable {
  const CommunityPost({
    required this.id,
    required this.author,
    required this.kind,
    required this.subject,
    required this.topic,
    required this.title,
    required this.postedAt,
    required this.score,
    required this.commentCount,
    this.body,
    this.question,
    this.document,
    this.topAnswerAuthor,
    this.topAnswerText,
    this.myVote = VoteValue.none,
    this.saved = false,
  });

  final String id;
  final CommunityAuthor author;
  final CommunityPostKind kind;

  /// Curriculum subject, one of [CommunitySubjects.selectable].
  final String subject;

  /// Short topic label shown next to the subject.
  final String topic;
  final String title;
  final String? body;
  final PostQuestion? question;
  final PostDocument? document;
  final String? topAnswerAuthor;
  final String? topAnswerText;
  final DateTime postedAt;

  /// Net upvotes; downvotes subtract.
  final int score;
  final int commentCount;
  final VoteValue myVote;
  final bool saved;

  /// Short label for the kind, used in tags on the profile dashboard.
  String get kindLabel => switch (kind) {
    CommunityPostKind.discussion => 'Discussion',
    CommunityPostKind.question =>
      (question?.isCreative ?? false) ? 'Shared CQ' : 'Practice Question',
    CommunityPostKind.notes => 'PDF Notes',
  };

  CommunityPost copyWith({int? score, VoteValue? myVote, bool? saved}) =>
      CommunityPost(
        id: id,
        author: author,
        kind: kind,
        subject: subject,
        topic: topic,
        title: title,
        postedAt: postedAt,
        score: score ?? this.score,
        commentCount: commentCount,
        body: body,
        question: question,
        document: document,
        topAnswerAuthor: topAnswerAuthor,
        topAnswerText: topAnswerText,
        myVote: myVote ?? this.myVote,
        saved: saved ?? this.saved,
      );

  @override
  List<Object?> get props => [
    id,
    author,
    kind,
    subject,
    topic,
    title,
    body,
    question,
    document,
    topAnswerAuthor,
    topAnswerText,
    postedAt,
    score,
    commentCount,
    myVote,
    saved,
  ];
}
