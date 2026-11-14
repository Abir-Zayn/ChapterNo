// Exposes dependencies used by the app router.
// Keeps dependency declarations separate from route composition.
export 'package:flutter/material.dart';
export 'package:flutter_bloc/flutter_bloc.dart';
export 'package:go_router/go_router.dart';

export '../../feature/auth/data/resource/local_legal_documents.dart';
export '../../feature/auth/domain/entities/legal_document.dart';
export '../../feature/auth/domain/repositories/auth_repository.dart';
export '../../feature/auth/screens/cubits/forgot_password_cubit.dart';
export '../../feature/auth/screens/cubits/login_cubit.dart';
export '../../feature/auth/screens/cubits/sign_up_cubit.dart';
export '../../feature/auth/screens/cubits/splash_cubit.dart';
export '../../feature/auth/screens/forgot_password_page.dart';
export '../../feature/auth/screens/legal_document_page.dart';
export '../../feature/auth/screens/login_page.dart';
export '../../feature/auth/screens/sign_up_page.dart';
export '../../feature/auth/screens/splash_page.dart';
export '../../feature/auth/screens/welcome_page.dart';
export '../../feature/home/data/repo/in_memory_home_repository.dart';
export '../../feature/home/domain/repositories/home_repository.dart';
export '../../feature/home/screens/cubits/home_cubit.dart';
export '../../feature/home/screens/home_page.dart';
export '../../shared/widgets/app_feedback/app_snack_bar.dart';
export 'app_routes.dart';
