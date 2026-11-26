// In-memory CurriculumRepository backed by deterministic Bangladesh SSC fixtures.
// Supports optional data, failure, and delay overrides for isolated tests.
import 'repo_imports.dart';

class InMemoryCurriculumRepository implements CurriculumRepository {
  InMemoryCurriculumRepository({
    List<EducationBoard>? boards,
    List<Subject>? subjects,
    Map<int, List<Chapter>>? chaptersBySubjectId,
    Map<int, List<Topic>>? topicsByChapterId,
    this.forcedFailure,
    this.simulatedDelay = Duration.zero,
  }) : _boards = boards ?? _defaultBoards,
       _subjects = subjects ?? _defaultSubjects,
       _chaptersBySubjectId =
           chaptersBySubjectId ?? _defaultChaptersBySubjectId,
       _topicsByChapterId = topicsByChapterId ?? _defaultTopicsByChapterId;

  final List<EducationBoard> _boards;
  final List<Subject> _subjects;
  final Map<int, List<Chapter>> _chaptersBySubjectId;
  final Map<int, List<Topic>> _topicsByChapterId;

  CurriculumFailure? forcedFailure;
  Duration simulatedDelay;

  @override
  Future<Either<CurriculumFailure, List<EducationBoard>>> getEducationBoards({
    bool forceRefresh = false,
  }) => _run(() {
    final items = _boards.where((b) => b.isActive).toList()
      ..sort((a, b) {
        final byOrder = a.sortOrder.compareTo(b.sortOrder);
        return byOrder != 0 ? byOrder : a.id.compareTo(b.id);
      });
    return List<EducationBoard>.unmodifiable(items);
  });

  @override
  Future<Either<CurriculumFailure, List<Subject>>> getSubjectsForGroup(
    AcademicGroup group, {
    bool forceRefresh = false,
  }) => _run(() {
    final items =
        _subjects.where((s) => s.isCleared && s.matchesGroup(group)).toList()
          ..sort((a, b) {
            final byOrder = a.sortOrder.compareTo(b.sortOrder);
            return byOrder != 0 ? byOrder : a.id.compareTo(b.id);
          });
    return List<Subject>.unmodifiable(items);
  });

  @override
  Future<Either<CurriculumFailure, List<Chapter>>> getChaptersForSubject(
    int subjectId, {
    bool forceRefresh = false,
  }) => _run(() {
    final source = _chaptersBySubjectId[subjectId] ?? const <Chapter>[];
    final items =
        source.where((c) => c.isActive && c.subjectId == subjectId).toList()
          ..sort((a, b) {
            final byOrder = a.sortOrder.compareTo(b.sortOrder);
            if (byOrder != 0) return byOrder;
            final byNum = a.chapterNumber.compareTo(b.chapterNumber);
            return byNum != 0 ? byNum : a.id.compareTo(b.id);
          });
    return List<Chapter>.unmodifiable(items);
  });

  @override
  Future<Either<CurriculumFailure, List<Topic>>> getTopicsForChapter(
    int chapterId, {
    bool forceRefresh = false,
  }) => _run(() {
    final source = _topicsByChapterId[chapterId] ?? const <Topic>[];
    final items =
        source.where((t) => t.isCleared && t.chapterId == chapterId).toList()
          ..sort((a, b) {
            final byOrder = a.sortOrder.compareTo(b.sortOrder);
            if (byOrder != 0) return byOrder;
            final byNum = a.topicNumber.compareTo(b.topicNumber);
            return byNum != 0 ? byNum : a.id.compareTo(b.id);
          });
    return List<Topic>.unmodifiable(items);
  });

  Future<Either<CurriculumFailure, T>> _run<T>(T Function() compute) async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
    final failure = forcedFailure;
    if (failure != null) return Left<CurriculumFailure, T>(failure);
    return Right<CurriculumFailure, T>(compute());
  }

  static EducationBoard _b(int id, String code, String en, String bn) =>
      EducationBoard(id: id, code: code, nameEn: en, nameBn: bn, sortOrder: id);

  static Subject _s(
    int id,
    String slug,
    String grp,
    String en,
    String bn,
    int order, {
    String r = 'cleared',
  }) => Subject(
    id: id,
    code: 'ssc_${slug}_$id',
    academicGroupCode: grp,
    subjectCode: '$id',
    paperCode: slug.endsWith('_1st')
        ? '1st'
        : slug.endsWith('_2nd')
        ? '2nd'
        : null,
    titleEn: en,
    titleBn: bn,
    syllabusVersion: 'NCTB-SSC-2026',
    rightsStatus: r,
    sortOrder: order,
  );

  static Chapter _c(int sid, int n, String en, String bn) => Chapter(
    id: sid * 10 + n,
    subjectId: sid,
    chapterNumber: n,
    titleEn: en,
    titleBn: bn,
    sortOrder: n,
  );

  static Topic _t(
    int cid,
    int n,
    String en,
    String bn, {
    ProvenanceSource src = ProvenanceSource.nctbSyllabus,
    String r = 'cleared',
    bool on = true,
  }) => Topic(
    id: cid * 10 + n,
    chapterId: cid,
    topicNumber: n,
    titleEn: en,
    titleBn: bn,
    provenanceSource: src,
    rightsStatus: r,
    sortOrder: n,
    isActive: on,
  );

  static final List<EducationBoard> _defaultBoards = List.unmodifiable([
    _b(1, 'dhaka', 'Dhaka Board', 'ঢাকা বোর্ড'),
    _b(2, 'chittagong', 'Chittagong Board', 'চট্টগ্রাম বোর্ড'),
    _b(3, 'rajshahi', 'Rajshahi Board', 'রাজশাহী বোর্ড'),
    _b(4, 'cumilla', 'Cumilla Board', 'কুমিল্লা বোর্ড'),
    _b(5, 'jashore', 'Jashore Board', 'যশোর বোর্ড'),
    _b(6, 'barishal', 'Barishal Board', 'বরিশাল বোর্ড'),
    _b(7, 'sylhet', 'Sylhet Board', 'সিলেট বোর্ড'),
    _b(8, 'dinajpur', 'Dinajpur Board', 'দিনাজপুর বোর্ড'),
    _b(9, 'mymensingh', 'Mymensingh Board', 'ময়মনসিংহ বোর্ড'),
    _b(10, 'madrasah', 'Madrasah Board', 'মাদ্রাসা বোর্ড'),
    _b(11, 'technical', 'Technical Board', 'কারিগরি বোর্ড'),
  ]);

  static final List<Subject> _defaultSubjects = List.unmodifiable([
    _s(101, 'bangla_1st', 'common', 'Bangla 1st Paper', 'বাংলা ১ম পত্র', 10),
    _s(102, 'bangla_2nd', 'common', 'Bangla 2nd Paper', 'বাংলা ২য় পত্র', 20),
    _s(107, 'english_1st', 'common', 'English 1st Paper', 'ইংরেজি ১ম পত্র', 30),
    _s(
      108,
      'english_2nd',
      'common',
      'English 2nd Paper',
      'ইংরেজি ২য় পত্র',
      40,
    ),
    _s(109, 'mathematics', 'common', 'Mathematics', 'গণিত', 50),
    _s(154, 'ict', 'common', 'ICT', 'তথ্য ও যোগাযোগ প্রযুক্তি', 60),
    _s(136, 'physics', 'science', 'Physics', 'পদার্থবিজ্ঞান', 110),
    _s(137, 'chemistry', 'science', 'Chemistry', 'রসায়ন', 120),
    _s(138, 'biology', 'science', 'Biology', 'জীববিজ্ঞান', 130),
    _s(126, 'higher_math', 'science', 'Higher Mathematics', 'উচ্চতর গণিত', 140),
    _s(
      150,
      'bgs',
      'science',
      'Bangladesh & Global Studies',
      'বাংলাদেশ ও বিশ্বপরিচয়',
      150,
    ),
    _s(
      146,
      'accounting',
      'business_studies',
      'Accounting',
      'হিসাববিজ্ঞান',
      210,
    ),
    _s(
      152,
      'finance_banking',
      'business_studies',
      'Finance & Banking',
      'ফিন্যান্স ও ব্যাংকিং',
      220,
      r: 'internal_draft',
    ),
    _s(153, 'history', 'humanities', 'History', 'ইতিহাস', 310),
    _s(
      110,
      'geography',
      'humanities',
      'Geography',
      'ভূগোল ও পরিবেশ',
      320,
      r: 'internal_draft',
    ),
  ]);

  static final Map<int, List<Chapter>> _defaultChaptersBySubjectId =
      Map.unmodifiable({
        101: [_c(101, 1, 'Shuva', 'শুভা')],
        109: [
          _c(109, 1, 'Real Numbers', 'বাস্তব সংখ্যা'),
          _c(109, 2, 'Sets & Functions', 'সেট ও ফাংশন'),
        ],
        154: [
          _c(154, 1, 'ICT & Bangladesh', 'তথ্য ও যোগাযোগ প্রযুক্তি'),
          _c(154, 2, 'Computer Safety', 'কম্পিউটার নিরাপত্তা'),
        ],
        136: [
          _c(136, 1, 'Physical Quantities', 'ভৌত রাশি ও পরিমাপ'),
          _c(136, 2, 'Motion', 'গতি'),
          _c(136, 3, 'Force', 'বল'),
        ],
        137: [_c(137, 2, 'States of Matter', 'পদার্থের অবস্থা')],
        146: [_c(146, 1, 'Intro to Accounting', 'হিসাববিজ্ঞান পরিচিতি')],
        153: [_c(153, 1, 'Intro to History', 'ইতিহাস পরিচিতি')],
      });

  static final Map<int, List<Topic>> _defaultTopicsByChapterId =
      Map.unmodifiable({
        1091: [_t(1091, 1, 'Rational Numbers', 'মূলদ ও অমূলদ সংখ্যা')],
        1541: [_t(1541, 1, 'Digital Bangladesh', 'ডিজিটাল বাংলাদেশ')],
        1542: [
          _t(
            1542,
            1,
            'Archived OS Note',
            'পুরাতন নোট',
            src: ProvenanceSource.curatedEditorial,
            on: false,
          ),
        ],
        1361: [_t(1361, 1, 'Fundamental Quantities', 'মৌলিক ও লব্ধ রাশি')],
        1362: [
          _t(1362, 1, 'Scalar & Vector', 'স্কেলার ও ভেক্টর রাশি'),
          _t(1362, 2, 'Distance & Velocity', 'দূরত্ব ও বেগ'),
          _t(1362, 3, 'Equations of Motion', 'গতির সমীকরণ'),
          _t(
            1362,
            4,
            'Graph Walkthrough',
            'লেখচিত্র (খসড়া)',
            src: ProvenanceSource.curatedEditorial,
            r: 'internal_draft',
          ),
        ],
        1461: [_t(1461, 1, 'Accounting Equation', 'হিসাব সমীকরণ')],
        1531: [_t(1531, 1, 'Historical Sources', 'ইতিহাসের উপাদান')],
      });
}
