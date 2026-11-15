// Exposes dependencies shared by the login, sign-up, and forgot-password
// pages, which are built from the same form widgets and state type.
// Keeps dependency declarations separate from page composition.
export 'package:flutter/material.dart';
export 'package:flutter_bloc/flutter_bloc.dart';
export 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

export '../../../config/theme/app_colors.dart';
export '../../../config/theme/app_spacing.dart';
export '../../../shared/widgets/app_button/app_button.dart';
export '../../../shared/widgets/app_feedback/app_snack_bar.dart';
export '../../../shared/widgets/app_password_field/app_password_field.dart';
export '../../../shared/widgets/app_text/app_text.dart';
export '../../../shared/widgets/app_text_field/app_text_field.dart';
export '../domain/usecase/auth_validators.dart';
export 'cubits/auth_form_state.dart';
export 'cubits/forgot_password_cubit.dart';
export 'cubits/login_cubit.dart';
export 'cubits/sign_up_cubit.dart';
export 'widgets/auth_failure_message.dart';
export 'widgets/auth_header.dart';
export 'widgets/auth_scaffold.dart';
export 'widgets/auth_switch_prompt.dart';
export 'widgets/date_of_birth_field.dart';
export 'widgets/legal_consent_text.dart';
export 'widgets/reset_link_sent_view.dart';
