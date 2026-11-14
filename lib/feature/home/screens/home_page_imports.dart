// Exposes dependencies used by the Student Home Dashboard page.
// Keeps external library and section component declarations separated.
export 'package:flutter/material.dart';
export 'package:flutter_bloc/flutter_bloc.dart';
export 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

export '../../../config/theme/app_colors.dart';
export '../../../config/theme/app_spacing.dart';
export '../../../shared/widgets/app_button/app_button.dart';
export '../../../shared/widgets/app_feedback/app_snack_bar.dart';
export '../../../shared/widgets/app_loader/app_loader.dart';
export '../../../shared/widgets/app_state_view/app_state_view.dart';
export '../../../shared/widgets/app_text/app_text.dart';
export 'cubits/home_cubit.dart';
export 'cubits/home_state.dart';
export 'widgets/continue_learning_card.dart';
export 'widgets/daily_goal_card.dart';
export 'widgets/home_bottom_nav.dart';
export 'widgets/home_header.dart';
export 'widgets/quick_actions_grid.dart';
export 'widgets/recent_activity_section.dart';
export 'widgets/subject_mastery_section.dart';
export 'home_page.dart';
