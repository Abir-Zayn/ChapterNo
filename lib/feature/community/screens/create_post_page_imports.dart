// Exposes dependencies used by the create-post page and its forms.
// Keeps dependency declarations separate from page composition.
export 'package:flutter/material.dart';
export 'package:flutter_bloc/flutter_bloc.dart';

export '../../../config/theme/app_colors.dart';
export '../../../config/theme/app_spacing.dart';
export '../../../shared/widgets/app_button/app_button.dart';
export '../../../shared/widgets/app_icon_button/app_icon_button.dart';
export '../../../shared/widgets/app_loader/app_loader.dart';
export '../../../shared/widgets/app_feedback/app_snack_bar.dart';
export '../../../shared/widgets/app_text/app_text.dart';
export '../../../shared/widgets/app_text_field/app_text_field.dart';
export '../domain/entities/community_post.dart';
export '../domain/usecase/post_draft_validator.dart';
export 'cubits/create_post_cubit.dart';
export 'cubits/create_post_state.dart';
export 'widgets/attached_document_card.dart';
export 'widgets/attached_question_card.dart';
export 'widgets/community_failure_message.dart';
export 'widgets/community_widgets_imports.dart';
export 'widgets/guidelines_card.dart';
export 'widgets/pill_segmented_control.dart';
export 'widgets/subject_chip_row.dart';
export 'widgets/title_field_with_counter.dart';
