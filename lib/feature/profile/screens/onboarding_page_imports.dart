// Exposes dependencies used by the Onboarding page.
// Keeps dependency declarations separate from page composition.
export 'package:flutter/material.dart';
export 'package:flutter_bloc/flutter_bloc.dart';

export '../../../config/theme/app_colors.dart';
export '../../../config/theme/app_palette.dart';
export '../../../config/theme/app_spacing.dart';
export '../../../shared/widgets/app_button/app_button.dart';
export '../../../shared/widgets/app_feedback/app_snack_bar.dart';
export '../../../shared/widgets/app_text/app_text.dart';
export '../../../shared/widgets/app_text_field/app_text_field.dart';
export '../domain/entities/onboarding_draft.dart';
export 'cubits/onboarding_cubit.dart';
export 'cubits/onboarding_state.dart';
export 'widgets/academic_group_selector.dart';
export 'widgets/batch_year_chips.dart';
export 'widgets/board_selector_field.dart';
