// Exposes dependencies used by the Community feed page.
// Keeps dependency declarations separate from page composition.
export 'package:flutter/material.dart';
export 'package:flutter_bloc/flutter_bloc.dart';

export '../../../config/theme/app_colors.dart';
export '../../../config/theme/app_palette.dart';
export '../../../config/theme/app_spacing.dart';
export '../../../shared/widgets/app_icon_button/app_icon_button.dart';
export '../../../shared/widgets/app_loader/app_loader.dart';
export '../../../shared/widgets/app_feedback/app_snack_bar.dart';
export '../../../shared/widgets/app_state_view/app_state_view.dart';
export '../../../shared/widgets/app_text/app_text.dart';
export '../../home/screens/widgets/home_bottom_nav.dart'
    show HomeBottomNav, HomeNavTab;
export '../domain/entities/community_post.dart';
export 'cubits/community_feed_cubit.dart';
export 'cubits/community_feed_state.dart';
export 'widgets/community_avatar.dart';
export 'widgets/community_feed_top_bar.dart';
export 'widgets/community_widgets_imports.dart';
export 'widgets/feed_filter_bar.dart';
export 'widgets/post_card.dart';
