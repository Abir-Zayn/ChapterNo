// Exposes dependencies for the Student Profile Dashboard page.
// Keeps dependency declarations separate from page composition.
export 'package:flutter/material.dart';
export 'package:flutter_bloc/flutter_bloc.dart';
export 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

export '../../../config/theme/app_colors.dart';
export '../../../config/theme/app_palette.dart';
export '../../../config/theme/app_spacing.dart';
export '../../../shared/widgets/app_card/app_card.dart';
export '../../../shared/widgets/app_feedback/app_confirm_dialog.dart';
export '../../../shared/widgets/app_feedback/app_snack_bar.dart';
export '../../../shared/widgets/app_loader/app_loader.dart';
export '../../../shared/widgets/app_state_view/app_state_view.dart';
export '../../../shared/widgets/app_text/app_text.dart';
export '../domain/entities/student_profile.dart';
export 'cubits/profile_cubit.dart';
export 'cubits/profile_state.dart';
export 'widgets/profile_community_card.dart';
export 'widgets/profile_header_card.dart';
export 'widgets/profile_menu_section.dart';
export 'widgets/profile_stat_grid.dart';
