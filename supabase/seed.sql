-- Idempotent local development seed data for ChapterNo Step 1 (Foundation).
-- Populates Bangladesh education boards and NCTB SSC curriculum catalogue rows.
-- Contains ZERO demo student accounts, profiles, settings, or fake progress.

begin;

-- ---------------------------------------------------------------------------
-- 1. Bangladesh Education Boards (11 official boards)
-- ---------------------------------------------------------------------------
insert into public.education_boards (code, name_en, name_bn, sort_order, is_active)
values
  ('dhaka', 'Dhaka Board', 'ঢাকা বোর্ড', 1, true),
  ('chittagong', 'Chittagong Board', 'চট্টগ্রাম বোর্ড', 2, true),
  ('rajshahi', 'Rajshahi Board', 'রাজশাহী বোর্ড', 3, true),
  ('cumilla', 'Cumilla Board', 'কুমিল্লা বোর্ড', 4, true),
  ('jashore', 'Jashore Board', 'যশোর বোর্ড', 5, true),
  ('barishal', 'Barishal Board', 'বরিশাল বোর্ড', 6, true),
  ('sylhet', 'Sylhet Board', 'সিলেট বোর্ড', 7, true),
  ('dinajpur', 'Dinajpur Board', 'দিনাজপুর বোর্ড', 8, true),
  ('mymensingh', 'Mymensingh Board', 'ময়মনসিংহ বোর্ড', 9, true),
  ('madrasah', 'Madrasah Board', 'মাদ্রাসা বোর্ড', 10, true),
  ('technical', 'Technical Board', 'কারিগরি বোর্ড', 11, true)
on conflict (code) do update set
  name_en = excluded.name_en,
  name_bn = excluded.name_bn,
  sort_order = excluded.sort_order,
  is_active = excluded.is_active;

-- ---------------------------------------------------------------------------
-- 2. NCTB SSC Subjects (common + science pilot cleared; business/humanities)
-- ---------------------------------------------------------------------------
insert into public.subjects (
  code,
  education_level,
  academic_group,
  subject_code,
  paper_code,
  title_en,
  title_bn,
  syllabus_version,
  provenance_source,
  rights_status,
  sort_order,
  is_active
)
values
  -- Common SSC subjects
  (
    'ssc_bangla_1st_101',
    'ssc',
    'common',
    '101',
    '1st',
    'Bangla 1st Paper',
    'বাংলা ১ম পত্র',
    'NCTB-SSC-2026',
    'nctb_syllabus',
    'cleared',
    10,
    true
  ),
  (
    'ssc_bangla_2nd_102',
    'ssc',
    'common',
    '102',
    '2nd',
    'Bangla 2nd Paper',
    'বাংলা ২য় পত্র',
    'NCTB-SSC-2026',
    'nctb_syllabus',
    'cleared',
    20,
    true
  ),
  (
    'ssc_english_1st_107',
    'ssc',
    'common',
    '107',
    '1st',
    'English 1st Paper',
    'ইংরেজি ১ম পত্র',
    'NCTB-SSC-2026',
    'nctb_syllabus',
    'cleared',
    30,
    true
  ),
  (
    'ssc_english_2nd_108',
    'ssc',
    'common',
    '108',
    '2nd',
    'English 2nd Paper',
    'ইংরেজি ২য় পত্র',
    'NCTB-SSC-2026',
    'nctb_syllabus',
    'cleared',
    40,
    true
  ),
  (
    'ssc_mathematics_109',
    'ssc',
    'common',
    '109',
    null,
    'Mathematics',
    'গণিত',
    'NCTB-SSC-2026',
    'nctb_syllabus',
    'cleared',
    50,
    true
  ),
  (
    'ssc_ict_154',
    'ssc',
    'common',
    '154',
    null,
    'Information and Communication Technology',
    'তথ্য ও যোগাযোগ প্রযুক্তি',
    'NCTB-SSC-2026',
    'nctb_syllabus',
    'cleared',
    60,
    true
  ),

  -- Science pilot subjects
  (
    'ssc_physics_136',
    'ssc',
    'science',
    '136',
    null,
    'Physics',
    'পদার্থবিজ্ঞান',
    'NCTB-SSC-2026',
    'nctb_syllabus',
    'cleared',
    110,
    true
  ),
  (
    'ssc_chemistry_137',
    'ssc',
    'science',
    '137',
    null,
    'Chemistry',
    'রসায়ন',
    'NCTB-SSC-2026',
    'nctb_syllabus',
    'cleared',
    120,
    true
  ),
  (
    'ssc_biology_138',
    'ssc',
    'science',
    '138',
    null,
    'Biology',
    'জীববিজ্ঞান',
    'NCTB-SSC-2026',
    'nctb_syllabus',
    'cleared',
    130,
    true
  ),
  (
    'ssc_higher_math_126',
    'ssc',
    'science',
    '126',
    null,
    'Higher Mathematics',
    'উচ্চতর গণিত',
    'NCTB-SSC-2026',
    'nctb_syllabus',
    'cleared',
    140,
    true
  ),
  (
    'ssc_bgs_150',
    'ssc',
    'science',
    '150',
    null,
    'Bangladesh and Global Studies',
    'বাংলাদেশ ও বিশ্বপরিচয়',
    'NCTB-SSC-2026',
    'nctb_syllabus',
    'cleared',
    150,
    true
  ),

  -- Business Studies (cleared sample + internal_draft for RLS S-6 verification)
  (
    'ssc_accounting_146',
    'ssc',
    'business_studies',
    '146',
    null,
    'Accounting',
    'হিসাববিজ্ঞান',
    'NCTB-SSC-2026',
    'nctb_syllabus',
    'cleared',
    210,
    true
  ),
  (
    'ssc_finance_banking_152',
    'ssc',
    'business_studies',
    '152',
    null,
    'Finance and Banking',
    'ফিন্যান্স ও ব্যাংকিং',
    'NCTB-SSC-2026',
    'nctb_syllabus',
    'internal_draft',
    220,
    true
  ),

  -- Humanities (cleared sample + internal_draft for RLS S-6 verification)
  (
    'ssc_history_153',
    'ssc',
    'humanities',
    '153',
    null,
    'History of Bangladesh and World Civilization',
    'বাংলাদেশের ইতিহাস ও বিশ্বসভ্যতা',
    'NCTB-SSC-2026',
    'nctb_syllabus',
    'cleared',
    310,
    true
  ),
  (
    'ssc_geography_110',
    'ssc',
    'humanities',
    '110',
    null,
    'Geography and Environment',
    'ভূগোল ও পরিবেশ',
    'NCTB-SSC-2026',
    'nctb_syllabus',
    'internal_draft',
    320,
    true
  )
on conflict (code) do update set
  education_level = excluded.education_level,
  academic_group = excluded.academic_group,
  subject_code = excluded.subject_code,
  paper_code = excluded.paper_code,
  title_en = excluded.title_en,
  title_bn = excluded.title_bn,
  syllabus_version = excluded.syllabus_version,
  provenance_source = excluded.provenance_source,
  rights_status = excluded.rights_status,
  sort_order = excluded.sort_order,
  is_active = excluded.is_active;

-- ---------------------------------------------------------------------------
-- 3. Representative NCTB SSC Chapters (bilingual title_en & title_bn)
-- ---------------------------------------------------------------------------
insert into public.chapters (
  subject_id,
  chapter_number,
  title_en,
  title_bn,
  summary_en,
  summary_bn,
  sort_order,
  is_active
)
select
  s.id,
  v.chapter_number,
  v.title_en,
  v.title_bn,
  v.summary_en,
  v.summary_bn,
  v.sort_order,
  v.is_active
from (
  values
    -- Bangla 1st Paper
    ('ssc_bangla_1st_101', 1, 'Shuva', 'শুভা', 'Prose study from Rabindranath Tagore.', 'রবীন্দ্রনাথ ঠাকুরের গদ্য পাঠ।', 1, true),
    ('ssc_bangla_1st_101', 2, 'Boi Pora', 'বই পড়া', 'Essay on reading habits by Pramatha Chaudhuri.', 'প্রমথ চৌধুরীর প্রবন্ধ পাঠ।', 2, true),
    ('ssc_bangla_1st_101', 3, 'Kapotakkho Nod', 'কপোতাক্ষ নদ', 'Sonnet by Michael Madhusudan Dutt.', 'মাইকেল মধুসূদন দত্তের সনেট।', 3, true),

    -- Bangla 2nd Paper
    ('ssc_bangla_2nd_102', 1, 'Language and Bangla Grammar', 'ভাষা ও বাংলা ব্যাকরণ', 'Foundations of Bangla language and grammar.', 'বাংলা ভাষা ও ব্যাকরণের মৌলিক ধারণা।', 1, true),
    ('ssc_bangla_2nd_102', 2, 'Phonology and Sound Change', 'ধ্বনিতত্ত্ব ও ধ্বনির পরিবর্তন', 'Vowels, consonants, and phonological shifts.', 'স্বরধ্বনি, ব্যঞ্জনধ্বনি ও ধ্বনি পরিবর্তন।', 2, true),
    ('ssc_bangla_2nd_102', 3, 'Word Formation and Sandhi', 'শব্দ গঠন ও সন্ধি', 'Rules of Bangla and Tatbhava sandhi.', 'শব্দ গঠন ও সন্ধির নিয়মাবলি।', 3, true),

    -- English 1st Paper
    ('ssc_english_1st_107', 1, 'Sense of Self', 'আত্মপরিচয়', 'Identity, responsibility, and personal growth.', 'আত্মপরিচয়, দায়িত্ববোধ ও ব্যক্তিগত বিকাশ।', 1, true),
    ('ssc_english_1st_107', 2, 'Pastimes', 'অবসর বিনোদন', 'Healthy leisure activities and reading comprehension.', 'অবসর বিনোদন ও পাঠ অনুধাবন।', 2, true),
    ('ssc_english_1st_107', 3, 'Events and Festivals', 'ঘটনা ও উৎসব', 'National and cultural observances in Bangladesh.', 'বাংলাদেশের জাতীয় ও সাংস্কৃতিক উৎসব।', 3, true),

    -- English 2nd Paper
    ('ssc_english_2nd_108', 1, 'Parts of Speech', 'পদ প্রকরণ (Parts of Speech)', 'Nouns, pronouns, verbs, adjectives, and modifiers.', 'ইংরেজি ব্যাকরণের মৌলিক পদ প্রকরণ।', 1, true),
    ('ssc_english_2nd_108', 2, 'Tense and Aspect', 'কাল (Tense)', 'Present, past, and future verb forms in context.', 'বর্তমান, অতীত ও ভবিষ্যৎ কালের ব্যবহার।', 2, true),
    ('ssc_english_2nd_108', 3, 'Voice and Narration', 'বাচ্য ও উক্তি', 'Active/passive transformations and reported speech.', 'বাচ্য পরিবর্তন ও উক্তি রূপান্তর।', 3, true),

    -- Mathematics
    ('ssc_mathematics_109', 1, 'Real Numbers', 'বাস্তব সংখ্যা', 'Classification and properties of real numbers.', 'বাস্তব সংখ্যার শ্রেণিবিভাগ ও বৈশিষ্ট্য।', 1, true),
    ('ssc_mathematics_109', 2, 'Sets and Functions', 'সেট ও ফাংশন', 'Set operations, Venn diagrams, and relations.', 'সেট প্রক্রিয়া, ভেনচিত্র ও অন্বয়-ফাংশন।', 2, true),
    ('ssc_mathematics_109', 3, 'Algebraic Expressions', 'বীজগাণিতিক রাশি', 'Square/cube formulas, factorization, and remainder theorem.', 'বর্গ ও ঘনের সূত্র, উৎপাদকে বিশ্লেষণ ও ভাগশেষ উপপাদ্য।', 3, true),

    -- ICT
    ('ssc_ict_154', 1, 'ICT and Our Bangladesh', 'তথ্য ও যোগাযোগ প্রযুক্তি এবং আমাদের বাংলাদেশ', 'Role of ICT in society, governance, and education.', 'সমাজ, প্রশাসন ও শিক্ষায় আইসিটির ভূমিকা।', 1, true),
    ('ssc_ict_154', 2, 'Computer and User Safety', 'কম্পিউটার ও কম্পিউটার ব্যবহারকারীর নিরাপত্তা', 'Hardware maintenance, malware protection, and troubleshooting.', 'হার্ডওয়্যার রক্ষণাবেক্ষণ ও নিরাপত্তা।', 2, true),
    ('ssc_ict_154', 3, 'Internet in My Education', 'আমার শিক্ষায় ইন্টারনেট', 'Digital textbooks and safe educational web resources.', 'ডিজিটাল কনটেন্ট ও শিক্ষামূলক ইন্টারনেট ব্যবহার।', 3, true),

    -- Physics (136)
    ('ssc_physics_136', 1, 'Physical Quantities and Their Measurement', 'ভৌত রাশি এবং পরিমাপ', 'SI units, dimensions, and measuring instruments.', 'এসআই একক, মাত্রা ও পরিমাপক যন্ত্র।', 1, true),
    ('ssc_physics_136', 2, 'Motion', 'গতি', 'Scalar/vector quantities, equations of motion, and graphs.', 'স্কেলার ও ভেক্টর রাশি, গতির সমীকরণ ও লেখচিত্র।', 2, true),
    ('ssc_physics_136', 3, 'Force', 'বল', 'Inertia, Newton''s laws, momentum, and friction.', 'জড়তা, নিউটনের গতিসূত্র, ভরবেগ ও ঘর্ষণ।', 3, true),

    -- Chemistry (137)
    ('ssc_chemistry_137', 1, 'Concept of Chemistry', 'রসায়নের ধারণা', 'Scope of chemistry and laboratory safety.', 'রসায়নের পরিধি ও পরীক্ষাগার নিরাপত্তা।', 1, true),
    ('ssc_chemistry_137', 2, 'States of Matter', 'পদার্থের অবস্থা', 'Kinetic theory, diffusion, effusion, and phase changes.', 'কণার গতিতত্ত্ব, ব্যাপন, নিঃসরণ ও অবস্থার পরিবর্তন।', 2, true),
    ('ssc_chemistry_137', 3, 'Structure of Matter', 'পদার্থের গঠন', 'Atomic number, mass number, isotopes, and electron shells.', 'পারমাণবিক সংখ্যা, ভর সংখ্যা, আইসোটোপ ও শক্তিস্তর।', 3, true),

    -- Biology (138)
    ('ssc_biology_138', 1, 'Lessons on Life', 'জীবন পাঠ', 'Classification of living organisms and binomial nomenclature.', 'জীবের শ্রেণিবিন্যাস ও দ্বিপদ নামকরণ।', 1, true),
    ('ssc_biology_138', 2, 'Cells and Tissues of Organism', 'জীবকোষ ও টিস্যু', 'Plant and animal cell organelles and tissue types.', 'উদ্ভিদ ও প্রাণিকোষের অঙ্গাণু এবং টিস্যু।', 2, true),
    ('ssc_biology_138', 3, 'Cell Division', 'কোষ বিভাজন', 'Mitosis, meiosis, and their biological significance.', 'মাইটোসিস, মিয়োসিস ও তাদের গুরুত্ব।', 3, true),

    -- Higher Mathematics (126)
    ('ssc_higher_math_126', 1, 'Set and Function', 'সেট ও ফাংশন', 'Universal sets, power sets, and inverse functions.', 'সার্বিক সেট, শক্তি সেট ও বিপরীত ফাংশন।', 1, true),
    ('ssc_higher_math_126', 2, 'Algebraic Expression', 'বীজগাণিতিক রাশি', 'Polynomials, symmetric expressions, and partial fractions.', 'বহুপদী, প্রতিসম রাশি ও আংশিক ভগ্নাংশ।', 2, true),
    ('ssc_higher_math_126', 3, 'Geometry', 'জ্যামিতি', 'Orthogonal projection, Apollonius theorem, and circumcircle.', 'লম্ব অভিক্ষেপ, অ্যাপোলোনিয়াসের উপপাদ্য ও পরিবৃত্ত।', 3, true),

    -- Bangladesh and Global Studies (150)
    ('ssc_bgs_150', 1, 'East Bengal Nationalist Movement', 'পূর্ব বাংলার আন্দোলন ও জাতীয়তাবাদের উত্থান', 'Language Movement of 1952 through the Six-Point demand.', '১৯৫২ সালের ভাষা আন্দোলন থেকে ছয় দফা।', 1, true),
    ('ssc_bgs_150', 2, 'Independent Bangladesh', 'স্বাধীন বাংলাদেশ', '1971 Liberation War and post-independence reconstruction.', '১৯৭১ সালের মুক্তিযুদ্ধ ও দেশ পুনর্গঠন।', 2, true),
    ('ssc_bgs_150', 3, 'The Solar System and the Earth', 'সৌরজগৎ ও ভূমণ্ডল', 'Latitude, longitude, rotation, and seasons.', 'অক্ষাংশ, দ্রাঘিমাংশ, আহ্নিক গতি ও ঋতু পরিবর্তন।', 3, true),

    -- Accounting (146)
    ('ssc_accounting_146', 1, 'Introduction to Accounting', 'হিসাববিজ্ঞান পরিচিতি', 'Objectives, users, and ethical principles of accounting.', 'হিসাববিজ্ঞানের উদ্দেশ্য ও মূল্যবোধ।', 1, true),
    ('ssc_accounting_146', 2, 'Transactions', 'লেনদেন', 'Accounting equation and source documents.', 'হিসাব সমীকরণ ও লেনদেনের দলিলপত্র।', 2, true),

    -- History (153)
    ('ssc_history_153', 1, 'Introduction to History', 'ইতিহাস পরিচিতি', 'Sources and classification of historical study.', 'ইতিহাসের উপাদান ও প্রকারভেদ।', 1, true),
    ('ssc_history_153', 2, 'World Civilization', 'বিশ্বসভ্যতা', 'Egyptian, Indus, Greek, and Roman civilizations.', 'মিসরীয়, সিন্ধু, গ্রিক ও রোমান সভ্যতা।', 2, true)
) as v(subject_code, chapter_number, title_en, title_bn, summary_en, summary_bn, sort_order, is_active)
join public.subjects s on s.code = v.subject_code
on conflict (subject_id, chapter_number) do update set
  title_en = excluded.title_en,
  title_bn = excluded.title_bn,
  summary_en = excluded.summary_en,
  summary_bn = excluded.summary_bn,
  sort_order = excluded.sort_order,
  is_active = excluded.is_active;

-- ---------------------------------------------------------------------------
-- 4. Representative Bilingual Topics (including internal_draft for RLS S-6)
-- ---------------------------------------------------------------------------
insert into public.topics (
  chapter_id,
  topic_number,
  title_en,
  title_bn,
  provenance_source,
  rights_status,
  sort_order,
  is_active
)
select
  c.id,
  v.topic_number,
  v.title_en,
  v.title_bn,
  v.provenance_source,
  v.rights_status,
  v.sort_order,
  v.is_active
from (
  values
    -- Physics Ch 1 & Ch 2 & Ch 3
    ('ssc_physics_136', 1, 1, 'Fundamental and Derived Quantities', 'মৌলিক ও লব্ধ রাশি', 'nctb_syllabus', 'cleared', 1, true),
    ('ssc_physics_136', 1, 2, 'Vernier Calipers and Screw Gauge', 'ভার্নিয়ার স্কেল ও স্ক্রু গজ', 'nctb_syllabus', 'cleared', 2, true),
    ('ssc_physics_136', 2, 1, 'Scalar and Vector Quantities', 'স্কেলার ও ভেক্টর রাশি', 'nctb_syllabus', 'cleared', 1, true),
    ('ssc_physics_136', 2, 2, 'Distance, Displacement, Speed and Velocity', 'দূরত্ব, সরণ, দ্রুতি ও বেগ', 'nctb_syllabus', 'cleared', 2, true),
    ('ssc_physics_136', 2, 3, 'Equations of Uniform Acceleration', 'সুষম ত্বরণের গতির সমীকরণ', 'nctb_syllabus', 'cleared', 3, true),
    ('ssc_physics_136', 2, 4, 'Editorial Graph Walkthrough (Draft)', 'লেখচিত্র বিশ্লেষণ (খসড়া)', 'curated_editorial', 'internal_draft', 4, true),
    ('ssc_physics_136', 3, 1, 'Inertia and Newton''s First Law', 'জড়তা ও নিউটনের প্রথম সূত্র', 'nctb_syllabus', 'cleared', 1, true),
    ('ssc_physics_136', 3, 2, 'Momentum and Conservation Principle', 'ভরবেগ ও ভরবেগের সংরক্ষণশীলতা', 'nctb_syllabus', 'cleared', 2, true),

    -- Chemistry Ch 2 & Ch 3
    ('ssc_chemistry_137', 2, 1, 'Kinetic Theory of Particles', 'কণার গতিতত্ত্ব', 'nctb_syllabus', 'cleared', 1, true),
    ('ssc_chemistry_137', 2, 2, 'Diffusion and Effusion', 'ব্যাপন ও নিঃসরণ', 'nctb_syllabus', 'cleared', 2, true),
    ('ssc_chemistry_137', 3, 1, 'Atomic Number, Mass Number and Isotopes', 'পারমাণবিক সংখ্যা, ভর সংখ্যা ও আইসোটোপ', 'nctb_syllabus', 'cleared', 1, true),
    ('ssc_chemistry_137', 3, 2, 'Electronic Configuration in Shells', 'শক্তিস্তরে ইলেকট্রন বিন্যাস', 'nctb_syllabus', 'cleared', 2, true),

    -- Biology Ch 2 & Ch 3
    ('ssc_biology_138', 2, 1, 'Structure of Plant and Animal Cells', 'উদ্ভিদ ও প্রাণিকোষের গঠন', 'nctb_syllabus', 'cleared', 1, true),
    ('ssc_biology_138', 3, 1, 'Stages of Mitosis', 'মাইটোসিস বিভাজনের ধাপসমূহ', 'nctb_syllabus', 'cleared', 1, true),
    ('ssc_biology_138', 3, 2, 'Significance of Meiosis', 'মিয়োসিস বিভাজনের গুরুত্ব', 'nctb_syllabus', 'cleared', 2, true),

    -- Mathematics Ch 1 & Ch 2 & Ch 3
    ('ssc_mathematics_109', 1, 1, 'Rational and Irrational Numbers', 'মূলদ ও অমূলদ সংখ্যা', 'nctb_syllabus', 'cleared', 1, true),
    ('ssc_mathematics_109', 2, 1, 'Set Operations and Venn Diagrams', 'সেট প্রক্রিয়া ও ভেনচিত্র', 'nctb_syllabus', 'cleared', 1, true),
    ('ssc_mathematics_109', 3, 1, 'Algebraic Identities and Factorization', 'বীজগাণিতিক সূত্র ও উৎপাদকে বিশ্লেষণ', 'nctb_syllabus', 'cleared', 1, true),

    -- Higher Math Ch 1 & Ch 2
    ('ssc_higher_math_126', 1, 1, 'Domain, Range and One-to-One Functions', 'ডোমেন, রেঞ্জ ও এক-এক ফাংশন', 'nctb_syllabus', 'cleared', 1, true),
    ('ssc_higher_math_126', 2, 1, 'Polynomial Remainder and Factor Theorems', 'বহুপদীর ভাগশেষ ও উৎপাদক উপপাদ্য', 'nctb_syllabus', 'cleared', 1, true),

    -- Bangla, English, ICT, BGS
    ('ssc_bangla_1st_101', 1, 1, 'Theme and Character Analysis of Shuva', 'শুভা গল্পের মূলভাব ও চরিত্র বিশ্লেষণ', 'nctb_syllabus', 'cleared', 1, true),
    ('ssc_bangla_2nd_102', 2, 1, 'Types of Sound Change in Bangla', 'বাংলা ধ্বনি পরিবর্তনের ধারা', 'nctb_syllabus', 'cleared', 1, true),
    ('ssc_english_1st_107', 3, 1, 'International Mother Language Day Reading', 'আন্তর্জাতিক মাতৃভাষা দিবস পাঠ', 'nctb_syllabus', 'cleared', 1, true),
    ('ssc_english_2nd_108', 2, 1, 'Present Perfect vs Past Simple', 'প্রেজেন্ট পারফেক্ট ও পাস্ট সিম্পল', 'nctb_syllabus', 'cleared', 1, true),
    ('ssc_ict_154', 1, 1, 'Digital Bangladesh and E-Governance', 'ডিজিটাল বাংলাদেশ ও ই-গভর্ন্যান্স', 'nctb_syllabus', 'cleared', 1, true),
    ('ssc_bgs_150', 1, 1, '1952 Language Movement Significance', '১৯৫২ সালের ভাষা আন্দোলনের তাৎপর্য', 'nctb_syllabus', 'cleared', 1, true),

    -- Inactive topic sample for RLS S-6 verification
    ('ssc_ict_154', 2, 1, 'Archived Legacy OS Maintenance Note', 'পুরাতন অপারেটিং সিস্টেম নোট', 'curated_editorial', 'cleared', 1, false)
) as v(
  subject_code,
  chapter_number,
  topic_number,
  title_en,
  title_bn,
  provenance_source,
  rights_status,
  sort_order,
  is_active
)
join public.subjects s on s.code = v.subject_code
join public.chapters c
  on c.subject_id = s.id
 and c.chapter_number = v.chapter_number
on conflict (chapter_id, topic_number) do update set
  title_en = excluded.title_en,
  title_bn = excluded.title_bn,
  provenance_source = excluded.provenance_source,
  rights_status = excluded.rights_status,
  sort_order = excluded.sort_order,
  is_active = excluded.is_active;

commit;
