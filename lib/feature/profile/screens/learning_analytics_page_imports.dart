// Exposes dependencies for the Learning Analytics page.
// Keeps dependency declarations separate from page composition.
export 'package:flutter/material.dart';
export 'package:flutter_bloc/flutter_bloc.dart';
export 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

export '../../../config/theme/app_colors.dart';
export '../../../config/theme/app_palette.dart';
export '../../../config/theme/app_spacing.dart';
export '../../../shared/widgets/app_card/app_card.dart';
export '../../../shared/widgets/app_feedback/app_snack_bar.dart';
export '../../../shared/widgets/app_icon_button/app_icon_button.dart';
export '../../../shared/widgets/app_loader/app_loader.dart';
export '../../../shared/widgets/app_state_view/app_state_view.dart';
export '../../../shared/widgets/app_text/app_text.dart';
export '../domain/entities/learning_analytics.dart';
export 'cubits/learning_analytics_cubit.dart';
export 'cubits/learning_analytics_state.dart';
export 'widgets/analytics_revision_and_cq.dart';
export 'widgets/analytics_study_chart.dart';
export 'widgets/analytics_subject_card.dart';
export 'widgets/profile_stat_grid.dart';
