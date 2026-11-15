// Curriculum subjects used to categorize community content.
// Values are plain labels so the list can grow with real curriculum data.

abstract final class CommunitySubjects {
  /// Sentinel meaning "every subject" in feed filters.
  static const String all = 'All';

  static const String physics = 'Physics';
  static const String chemistry = 'Chemistry';
  static const String biology = 'Biology';
  static const String math = 'Math';
  static const String higherMath = 'Higher Math';
  static const String english = 'English';
  static const String bangla = 'Bangla';

  /// Subjects a student can pick when creating a post.
  static const List<String> selectable = [
    physics,
    chemistry,
    biology,
    math,
    higherMath,
    english,
    bangla,
  ];
}
