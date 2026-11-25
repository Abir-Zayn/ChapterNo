// Exposes dependencies used by the community feature's screen widgets.
// Keeps dependency declarations separate from widget implementations.
// Community widgets that use other community widgets import them directly.
export 'package:flutter/material.dart';
export 'package:hugeicons/hugeicons.dart';
export 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

export '../../../../config/theme/app_colors.dart';
export '../../../../config/theme/app_palette.dart';
export '../../../../config/theme/app_spacing.dart';
export '../../../../shared/widgets/app_button/app_button.dart';
export '../../../../shared/widgets/app_card/app_card.dart';
export '../../../../shared/widgets/app_icon_button/app_icon_button.dart';
export '../../../../shared/widgets/app_loader/app_loader.dart';

export '../../../../shared/widgets/app_state_view/app_state_view.dart';
export '../../../../shared/widgets/app_text/app_text.dart';
export '../../../../shared/widgets/app_text_field/app_text_field.dart';
export '../../../../shared/widgets/app_feedback/app_snack_bar.dart';
export '../../domain/entities/activity_entry.dart';
export '../../domain/entities/community_author.dart';
export '../../domain/entities/community_failure.dart';
export '../../domain/entities/community_post.dart';
export '../../domain/entities/community_profile.dart';
export '../../domain/entities/community_subjects.dart';
export '../../domain/entities/post_draft.dart';
export '../../domain/usecase/post_draft_validator.dart';
export 'community_avatar.dart';
export 'community_choice_chip.dart';
export 'community_icon_button.dart';
export 'community_time.dart';
export 'community_failure_message.dart';
