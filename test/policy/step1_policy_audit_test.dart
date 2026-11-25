// Audits Step 1 repository hygiene: file headers, line limits, import barrels,
// banned frameworks/patterns, secret safety, and PKCE/seed configuration.
import 'step1_policy_audit_test_imports.dart';

final RegExp _blockComment = RegExp(r'/\*.*?\*/', dotAll: true);
final RegExp _lineComment = RegExp(r'//[^\n]*');
final RegExp _hashComment = RegExp(r'#[^\n]*');
final RegExp _sqlLineComment = RegExp(r'--[^\n]*');
final RegExp _importLine = RegExp(
  r'''^\s*import\s+['"]([^'"]+)['"]''',
  multiLine: true,
);
final RegExp _jwtPattern = RegExp(
  r'eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}',
);

/// Legacy 1-line header files predating Step 1; do not add new entries here.
const Set<String> _legacySingleLineHeaders = <String>{
  'lib/core/env.dart',
  'lib/feature/community/domain/entities/activity_entry.dart',
  'lib/feature/community/screens/widgets/activity_group_header.dart',
  'lib/feature/community/screens/widgets/profile_stats_row.dart',
  'lib/feature/practice/domain/entities/entities_imports.dart',
  'lib/feature/practice/screens/widgets/practice_widgets_imports.dart',
  'test/feature/auth/data/in_memory_auth_repository_test.dart',
  'test/feature/auth/domain/auth_validators_test.dart',
};

String _norm(String path) => path.replaceAll('\\', '/');

bool _isGenerated(String path) =>
    path.endsWith('.g.dart') ||
    path.endsWith('.freezed.dart') ||
    path.endsWith('.drift.dart');

List<File> _dartFilesIn(String dir) {
  final root = Directory(dir);
  if (!root.existsSync()) return const <File>[];
  return (root
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart') && !_isGenerated(f.path))
      .toList()
    ..sort((a, b) => _norm(a.path).compareTo(_norm(b.path))));
}

String _stripDartComments(String source) => source
    .replaceAllMapped(
      _blockComment,
      (m) => '\n' * '\n'.allMatches(m[0]!).length,
    )
    .replaceAll(_lineComment, '');

bool _needsBarrel(String path) {
  if (const <String>{
    'lib/main.dart',
    'lib/bootstrap.dart',
    'lib/app.dart',
    'lib/config/router/app_router.dart',
    'test/policy/step1_policy_audit_test.dart',
  }.contains(path)) {
    return true;
  }
  if (!path.startsWith('lib/') ||
      path.endsWith('_imports.dart') ||
      path.endsWith('_dependencies.dart')) {
    return false;
  }
  return path.endsWith('_page.dart') ||
      path.endsWith('_cubit.dart') ||
      path.endsWith('_bloc.dart') ||
      path.startsWith('lib/core/error/') ||
      path.startsWith('lib/core/lifecycle/') ||
      path.startsWith('lib/core/supabase/') ||
      path.startsWith('lib/feature/curriculum/data/repo/') ||
      path.startsWith('lib/feature/curriculum/data/resource/') ||
      path.startsWith('lib/feature/auth/data/repo/supabase_') ||
      path.startsWith('lib/feature/auth/data/resource/supabase_') ||
      path.startsWith('lib/feature/profile/data/repo/supabase_') ||
      path.startsWith('lib/feature/profile/data/resource/');
}

bool _isGuardedDebugPrint(List<String> lines, int index) {
  final line = lines[index];
  if (line.contains('kDebugMode') || line.contains('assert(')) return true;
  var balance = 0;
  for (var i = index - 1; i >= 0 && i >= index - 20; i--) {
    final prev = lines[i];
    balance += '{'.allMatches(prev).length - '}'.allMatches(prev).length;
    if (prev.contains('if (!kDebugMode) return') && balance >= 0) return true;
    if ((prev.contains('kDebugMode') || prev.contains('assert(')) &&
        balance > 0) {
      return true;
    }
    if (balance < 0) break;
  }
  return false;
}

void main() {
  final allDart = <File>[..._dartFilesIn('lib'), ..._dartFilesIn('test')];

  test('all Dart files stay under 300 physical lines', () {
    final offenders = <String>[
      for (final f in allDart)
        if (LineSplitter.split(f.readAsStringSync()).length >= 300)
          '${_norm(f.path)}: ${LineSplitter.split(f.readAsStringSync()).length}',
    ];
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('manually maintained Dart files have a 2-3 line purpose header', () {
    final offenders = <String>[];
    for (final f in allDart) {
      final path = _norm(f.path);
      if (_legacySingleLineHeaders.contains(path)) continue;
      final lines = LineSplitter.split(f.readAsStringSync()).toList();
      final ok =
          lines.length >= 2 &&
          lines[0].trimLeft().startsWith('//') &&
          lines[1].trimLeft().startsWith('//') &&
          lines[0].replaceFirst(RegExp(r'^/+'), '').trim().isNotEmpty &&
          lines[1].replaceFirst(RegExp(r'^/+'), '').trim().isNotEmpty;
      if (!ok) offenders.add(path);
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('implementation/page/cubit files use paired *_imports.dart barrels', () {
    final offenders = <String>[];
    for (final f in allDart) {
      final path = _norm(f.path);
      if (path.endsWith('_dependencies.dart') &&
          !path.startsWith('lib/feature/community/') &&
          !path.startsWith('test/feature/community/')) {
        offenders.add('$path: new files must use *_imports.dart');
      }
      if (!_needsBarrel(path)) continue;
      final code = _stripDartComments(f.readAsStringSync());
      final uris = _importLine.allMatches(code).map((m) => m[1]!).toList();
      if (uris.isEmpty) continue;
      final hasBarrel = uris.any(
        (u) =>
            u.endsWith('_imports.dart') ||
            (path.startsWith('lib/feature/community/') &&
                u.endsWith('_dependencies.dart')),
      );
      if (!hasBarrel) offenders.add('$path: missing *_imports.dart');
      for (final u in uris.where((u) => u.startsWith('package:'))) {
        offenders.add('$path: direct package import ($u)');
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('zero banned DI/state/zone frameworks exist in source or pubspec', () {
    const banned = <String>[
      'riverpod',
      'flutter_riverpod',
      'hooks_riverpod',
      'get_it',
      'GetIt',
      'runZonedGuarded',
      'ProviderScope',
      'injectable',
    ];
    final offenders = <String>[];
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final pkg in banned.where((t) => t != 'GetIt')) {
      if (RegExp('^\\s*$pkg\\s*:', multiLine: true).hasMatch(pubspec)) {
        offenders.add('pubspec.yaml: $pkg');
      }
    }
    for (final f in allDart) {
      final path = _norm(f.path);
      if (path.startsWith('test/policy/')) continue;
      final code = _stripDartComments(f.readAsStringSync());
      for (final token in banned) {
        if (RegExp('\\b$token\\b').hasMatch(code)) {
          offenders.add('$path: $token');
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('zero hardcoded secrets and zero unguarded debugPrint calls', () {
    final secretOffenders = <String>[];
    final debugOffenders = <String>[];
    for (final f in allDart) {
      final path = _norm(f.path);
      if (path.startsWith('test/policy/')) continue;
      final stripped = _stripDartComments(f.readAsStringSync());
      for (final needle in const <String>['sb_secret_', 'service_role']) {
        if (stripped.contains(needle)) secretOffenders.add('$path: $needle');
      }
      if (_jwtPattern.hasMatch(stripped)) secretOffenders.add('$path: JWT');

      final lines = LineSplitter.split(stripped).toList();
      for (var i = 0; i < lines.length; i++) {
        if (!lines[i].contains('debugPrint(')) continue;
        if (!_isGuardedDebugPrint(lines, i)) {
          debugOffenders.add('$path:${i + 1}: unguarded debugPrint');
        }
        if (lines[i].contains('.toString()')) {
          debugOffenders.add('$path:${i + 1}: raw .toString() in debugPrint');
        }
      }
    }
    if (File('.env.example').existsSync()) {
      final env = File(
        '.env.example',
      ).readAsStringSync().replaceAll(_hashComment, '');
      if (env.contains('sb_secret_') ||
          env.contains('service_role') ||
          _jwtPattern.hasMatch(env)) {
        secretOffenders.add('.env.example: secret key material');
      }
    }
    if (Directory('supabase').existsSync()) {
      for (final f in Directory(
        'supabase',
      ).listSync(recursive: true).whereType<File>()) {
        if (!f.path.endsWith('.sql')) continue;
        final sql = f.readAsStringSync().replaceAll(_sqlLineComment, '');
        if (sql.contains('sb_secret_') || _jwtPattern.hasMatch(sql)) {
          secretOffenders.add('${_norm(f.path)}: secret key material');
        }
      }
    }
    expect(secretOffenders, isEmpty, reason: secretOffenders.join('\n'));
    expect(debugOffenders, isEmpty, reason: debugOffenders.join('\n'));
  });

  test('PKCE auth-callback deep links and clean seed.sql are configured', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(manifest, contains('android:launchMode="singleTop"'));
    expect(manifest, contains('android:exported="true"'));
    expect(manifest, contains('android:scheme="ai.actionboard.chapterno"'));
    expect(manifest, contains('android:host="auth-callback"'));
    expect(
      manifest,
      matches(
        RegExp(
          r'<meta-data\b(?=[^>]*android:name="flutter_deeplinking_enabled")(?=[^>]*android:value="false")[^>]*/>',
        ),
      ),
    );

    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    expect(plist, contains('<key>CFBundleURLTypes</key>'));
    expect(plist, contains('<string>ai.actionboard.chapterno</string>'));
    expect(
      plist,
      matches(RegExp(r'<key>FlutterDeepLinkingEnabled</key>\s*<false\s*/>')),
    );

    final seedSql = File('supabase/seed.sql').readAsStringSync();
    expect(seedSql, isNot(contains('auth.users')));
    expect(seedSql, isNot(contains('student_profiles')));
    expect(seedSql, isNot(contains('student_settings')));
  });
}
