// Immutable domain entity representing the student's profile dashboard.
// Holds academic metadata, summary metrics, and community counts.
import 'entities_imports.dart';

class StudentProfile extends Equatable {
  const StudentProfile({
    required this.id,
    required this.fullName,
    required this.initials,
    required this.email,
    required this.targetExam,
    required this.academicGroup,
    required this.learningPace,
    required this.membershipTier,
    required this.mcqsSolved,
    required this.mcqsTodayDelta,
    required this.accuracyPercent,
    required this.accuracyDeltaPercent,
    required this.cqsPracticed,
    required this.streakDays,
    required this.communityPostsCount,
    required this.communityNotesCount,
    required this.leaderboardRank,
    required this.plannedStudyCount,
  });

  final String id;
  final String fullName;
  final String initials;
  final String email;
  final String targetExam;
  final String academicGroup;
  final String learningPace;
  final String membershipTier;
  final int mcqsSolved;
  final int mcqsTodayDelta;
  final int accuracyPercent;
  final int accuracyDeltaPercent;
  final int cqsPracticed;
  final int streakDays;
  final int communityPostsCount;
  final int communityNotesCount;
  final int leaderboardRank;
  final int plannedStudyCount;

  StudentProfile copyWith({String? learningPace}) {
    return StudentProfile(
      id: id,
      fullName: fullName,
      initials: initials,
      email: email,
      targetExam: targetExam,
      academicGroup: academicGroup,
      learningPace: learningPace ?? this.learningPace,
      membershipTier: membershipTier,
      mcqsSolved: mcqsSolved,
      mcqsTodayDelta: mcqsTodayDelta,
      accuracyPercent: accuracyPercent,
      accuracyDeltaPercent: accuracyDeltaPercent,
      cqsPracticed: cqsPracticed,
      streakDays: streakDays,
      communityPostsCount: communityPostsCount,
      communityNotesCount: communityNotesCount,
      leaderboardRank: leaderboardRank,
      plannedStudyCount: plannedStudyCount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    initials,
    email,
    targetExam,
    academicGroup,
    learningPace,
    membershipTier,
    mcqsSolved,
    mcqsTodayDelta,
    accuracyPercent,
    accuracyDeltaPercent,
    cqsPracticed,
    streakDays,
    communityPostsCount,
    communityNotesCount,
    leaderboardRank,
    plannedStudyCount,
  ];
}
