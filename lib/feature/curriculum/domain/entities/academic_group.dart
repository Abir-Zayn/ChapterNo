// Defines SSC academic group options for student curriculum filtering.
// Maps domain enum values to database codes and bilingual display titles.

enum AcademicGroup {
  science('science', 'Science', 'বিজ্ঞান'),
  businessStudies('business_studies', 'Business Studies', 'ব্যবসায় শিক্ষা'),
  humanities('humanities', 'Humanities', 'মানবিক');

  const AcademicGroup(this.dbValue, this.titleEn, this.titleBn);

  final String dbValue;
  final String titleEn;
  final String titleBn;

  String get code => dbValue;
  String get labelEn => titleEn;
  String get labelBn => titleBn;

  String localizedTitle({bool isBangla = false}) =>
      isBangla ? titleBn : titleEn;

  static AcademicGroup? tryParse(String? raw) {
    if (raw == null) return null;
    final normalized = raw.trim().toLowerCase();
    for (final group in AcademicGroup.values) {
      if (group.dbValue == normalized ||
          group.name.toLowerCase() == normalized) {
        return group;
      }
    }
    return null;
  }
}
