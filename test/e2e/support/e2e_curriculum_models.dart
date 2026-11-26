// Contract models and NCTB SSC seed fixtures used by FakeCurriculumCatalogue.
// Represents Step 1 Doc 04 curriculum types until M1.5 lands in Wave 4.

enum E2eAcademicGroup { science, businessStudies, humanities }

enum E2eCurriculumFailure { offline, timeout, corruptCache }

class E2eBoard {
  const E2eBoard({
    required this.id,
    required this.nameEn,
    required this.nameBn,
    required this.sortOrder,
    this.isActive = true,
  });

  final String id;
  final String nameEn;
  final String nameBn;
  final int sortOrder;
  final bool isActive;
}

class E2eSubject {
  const E2eSubject({
    required this.id,
    required this.titleEn,
    required this.titleBn,
    required this.groupTag,
    required this.sortOrder,
    this.isActive = true,
    this.rightsStatus = 'cleared',
  });

  final int id;
  final String titleEn;
  final String titleBn;
  final String groupTag;
  final int sortOrder;
  final bool isActive;
  final String rightsStatus;
}

class E2eChapter {
  const E2eChapter({
    required this.id,
    required this.subjectId,
    required this.titleEn,
    required this.titleBn,
    required this.sortOrder,
  });

  final int id;
  final int subjectId;
  final String titleEn;
  final String titleBn;
  final int sortOrder;
}

class E2eTopic {
  const E2eTopic({
    required this.id,
    required this.titleEn,
    required this.titleBn,
    required this.provenanceSource,
    required this.rightsStatus,
    required this.sortOrder,
  });

  final int id;
  final String titleEn;
  final String titleBn;
  final String provenanceSource;
  final String rightsStatus;
  final int sortOrder;
}

class E2eCacheEntry<T> {
  const E2eCacheEntry({required this.items, required this.fetchedAt});
  final List<T> items;
  final DateTime fetchedAt;
}

abstract final class E2eCurriculumSeeds {
  static const List<E2eBoard> boards = [
    E2eBoard(id: 'dhaka', nameEn: 'Dhaka', nameBn: 'ঢাকা বোর্ড', sortOrder: 1),
    E2eBoard(
      id: 'chittagong',
      nameEn: 'Chittagong',
      nameBn: 'চট্টগ্রাম বোর্ড',
      sortOrder: 2,
    ),
    E2eBoard(
      id: 'rajshahi',
      nameEn: 'Rajshahi',
      nameBn: 'রাজশাহী বোর্ড',
      sortOrder: 3,
    ),
    E2eBoard(
      id: 'cumilla',
      nameEn: 'Cumilla',
      nameBn: 'কুমিল্লা বোর্ড',
      sortOrder: 4,
    ),
  ];

  static const List<E2eSubject> subjects = [
    E2eSubject(
      id: 1,
      titleEn: 'Bangla',
      titleBn: 'বাংলা',
      groupTag: 'common',
      sortOrder: 1,
    ),
    E2eSubject(
      id: 2,
      titleEn: 'English',
      titleBn: 'ইংরেজি',
      groupTag: 'common',
      sortOrder: 2,
    ),
    E2eSubject(
      id: 3,
      titleEn: 'Mathematics',
      titleBn: 'গণিত',
      groupTag: 'common',
      sortOrder: 3,
    ),
    E2eSubject(
      id: 4,
      titleEn: 'ICT',
      titleBn: 'তথ্য ও যোগাযোগ প্রযুক্তি',
      groupTag: 'common',
      sortOrder: 4,
    ),
    E2eSubject(
      id: 10,
      titleEn: 'Physics',
      titleBn: 'পদার্থবিজ্ঞান',
      groupTag: 'science',
      sortOrder: 5,
    ),
    E2eSubject(
      id: 11,
      titleEn: 'Chemistry',
      titleBn: 'রসায়ন',
      groupTag: 'science',
      sortOrder: 6,
    ),
    E2eSubject(
      id: 12,
      titleEn: 'Biology',
      titleBn: 'জীববিজ্ঞান',
      groupTag: 'science',
      sortOrder: 7,
    ),
    E2eSubject(
      id: 20,
      titleEn: 'Accounting',
      titleBn: 'হিসাববিজ্ঞান',
      groupTag: 'business_studies',
      sortOrder: 5,
    ),
    E2eSubject(
      id: 30,
      titleEn: 'History of Bangladesh',
      titleBn: 'বাংলাদেশের ইতিহাস',
      groupTag: 'humanities',
      sortOrder: 5,
    ),
    E2eSubject(
      id: 98,
      titleEn: 'Draft Science Subject',
      titleBn: 'খসড়া বিষয়',
      groupTag: 'science',
      sortOrder: 98,
      rightsStatus: 'internal_draft',
    ),
    E2eSubject(
      id: 99,
      titleEn: 'Inactive Subject',
      titleBn: 'নিষ্ক্রিয় বিষয়',
      groupTag: 'science',
      sortOrder: 99,
      isActive: false,
    ),
  ];
}
