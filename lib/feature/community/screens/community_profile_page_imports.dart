// Exposes dependencies used by the community profile dashboard page.
// Keeps dependency declarations separate from page composition.
export 'package:flutter/material.dart';
export 'package:flutter_bloc/flutter_bloc.dart';

export '../../../config/theme/app_colors.dart';
export '../../../config/theme/app_spacing.dart';
export '../../../shared/widgets/app_icon_button/app_icon_button.dart';
export '../../../shared/widgets/app_loader/app_loader.dart';
export '../../../shared/widgets/app_feedback/app_snack_bar.dart';
export '../../../shared/widgets/app_state_view/app_state_view.dart';
export '../../../shared/widgets/app_text/app_text.dart';
export '../domain/entities/community_post.dart';
export 'cubits/community_profile_cubit.dart';
export 'cubits/community_profile_state.dart';
export 'widgets/community_widgets_imports.dart';
export 'widgets/post_card.dart';
export 'widgets/profile_header_card.dart';
export 'widgets/profile_stats_row.dart';
export 'widgets/profile_tabs_bar.dart';
export '../domain/entities/community_profile.dart';
