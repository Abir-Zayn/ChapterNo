// Exposes router, theme, real auth/analytics pages, and E2E shells for
// the opaque-box E2eTestApp harness (swapped to ChapterNoApp in Wave 4).
export 'dart:async';

export 'package:chapter_no/config/router/app_routes.dart';
export 'package:chapter_no/config/theme/app_theme.dart';
export 'package:chapter_no/feature/auth/data/resource/local_legal_documents.dart';
export 'package:chapter_no/feature/auth/screens/cubits/forgot_password_cubit.dart';
export 'package:chapter_no/feature/auth/screens/cubits/login_cubit.dart';
export 'package:chapter_no/feature/auth/screens/cubits/sign_up_cubit.dart';
export 'package:chapter_no/feature/auth/screens/cubits/splash_cubit.dart';
export 'package:chapter_no/feature/auth/screens/forgot_password_page.dart';
export 'package:chapter_no/feature/auth/screens/login_page.dart';
export 'package:chapter_no/feature/auth/screens/sign_up_page.dart';
export 'package:chapter_no/feature/auth/screens/splash_page.dart';
export 'package:chapter_no/feature/auth/screens/welcome_page.dart';
export 'package:chapter_no/feature/auth/screens/legal_document_page.dart';
export 'package:chapter_no/feature/profile/screens/cubits/learning_analytics_cubit.dart';
export 'package:chapter_no/feature/profile/screens/cubits/profile_cubit.dart';
export 'package:chapter_no/feature/profile/screens/cubits/settings_cubit.dart';
export 'package:chapter_no/feature/profile/screens/learning_analytics_page.dart';
export 'package:chapter_no/shared/widgets/app_button/app_button.dart';
export 'package:chapter_no/shared/widgets/app_feedback/app_snack_bar.dart';
export 'package:chapter_no/shared/widgets/app_state_view/app_state_view.dart';
export 'package:flutter/material.dart';
export 'package:flutter_bloc/flutter_bloc.dart';
export 'package:go_router/go_router.dart';

export 'e2e_curriculum_fake.dart';
export 'e2e_fakes.dart';
export 'e2e_onboarding_home_shells.dart';
export 'e2e_profile_fake.dart';
export 'e2e_profile_settings_shells.dart';
