import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../app/colors.dart';
import '../../../../../app/radii.dart';
import '../../../../../app/spacing.dart';
import '../../../../../app/text_styles.dart';
import '../../../../../shared/widgets/app_avatar.dart';
import '../../../domain/entities/message.dart';
import '../../../domain/role_label.dart';

const double _avatarDiameter = 24;
const double _bubbleRadius = 16;

/// Text or system message bubble. Audio variant lives in `audio_bubble.dart`.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.showSenderHeader,
    this.senderRole,
    this.senderName,
  });

  final Message message;
  final bool isMine;
  final bool showSenderHeader;
  final String? senderRole;
  /// Resolved from chat-details `participants.items` via id match. Falls back
  /// to `message.senderName` when null/empty.
  final String? senderName;

  String get _displayName {
    if (senderName != null && senderName!.isNotEmpty) return senderName!;
    if (message.senderName.isNotEmpty) return message.senderName;
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    if (message.type == MessageType.system) {
      return _SystemNotice(text: message.body ?? '');
    }
    final maxBubbleWidth = MediaQuery.sizeOf(context).width * 0.72;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenH,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMine) ...[
            if (showSenderHeader)
              AppAvatar(
                name: _displayName,
                size: AppAvatarSize.xs,
              )
            else
              const SizedBox(width: _avatarDiameter),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isMine && showSenderHeader) ...[
                  _SenderHeader(name: _displayName, role: senderRole),
                  const SizedBox(height: AppSpacing.xxs),
                ],
                Semantics(
                  label: _semanticLabel(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                    child: _Bubble(message: message, isMine: isMine),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                _BubbleMeta(message: message, isMine: isMine),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _semanticLabel() {
    final body = message.isDeleted
        ? 'This message was deleted'
        : (message.body ?? 'Attachment message');
    final sender = isMine ? 'You' : _displayName;
    return '$sender: $body';
  }
}

class _SenderHeader extends StatelessWidget {
  const _SenderHeader({required this.name, this.role});

  final String name;
  final String? role;

  @override
  Widget build(BuildContext context) {
    final formattedRole = roleLabel(role);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          name,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (formattedRole.isNotEmpty) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            formattedRole,
            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.isMine});

  final Message message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final bg = isMine ? AppColors.primary : AppColors.surfaceMid;
    final fg = isMine ? AppColors.onPrimary : AppColors.textPrimary;

    if (message.isDeleted) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.smd,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(_bubbleRadius),
        ),
        child: Text(
          'This message was deleted',
          style: AppTextStyles.bodyMedium.copyWith(
            color: fg.withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
    if (message.type == MessageType.image && message.file != null) {
      return _ImageContent(file: message.file!);
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.smd,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(_bubbleRadius),
      ),
      child: Text(
        message.body ?? '',
        style: AppTextStyles.bodyMedium.copyWith(color: fg),
      ),
    );
  }
}

class _ImageContent extends StatelessWidget {
  const _ImageContent({required this.file});

  final MessageFile file;

  bool get _isLocal => !file.url.startsWith('http');

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.mdAll,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 220, minWidth: 160),
        child: _isLocal
            ? Image.file(File(file.url), fit: BoxFit.cover)
            : CachedNetworkImage(
                imageUrl: file.url,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  color: AppColors.surfaceMid,
                  height: 160,
                ),
                errorWidget: (_, _, _) => Container(
                  color: AppColors.surfaceMid,
                  height: 160,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
      ),
    );
  }
}

class _BubbleMeta extends StatelessWidget {
  const _BubbleMeta({required this.message, required this.isMine});

  final Message message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.textTertiary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.isEdited) ...[
          Text(
            'edited',
            style: AppTextStyles.caption.copyWith(color: color),
          ),
          const SizedBox(width: AppSpacing.xxs),
        ],
        Text(
          DateFormat('hh:mm a').format(message.sentAt),
          style: AppTextStyles.caption.copyWith(color: color),
        ),
        if (isMine) ...[
          const SizedBox(width: AppSpacing.xxs),
          _StatusIcon(status: message.deliveryStatus, color: color),
        ],
      ],
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status, required this.color});

  final DeliveryStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (status) {
      case DeliveryStatus.sending:
        icon = Icons.schedule;
      case DeliveryStatus.failed:
        icon = Icons.error_outline;
      case DeliveryStatus.sent:
        icon = Icons.check;
      case DeliveryStatus.delivered:
        icon = Icons.done_all;
      case DeliveryStatus.read:
        icon = Icons.done_all;
    }
    final tint = status == DeliveryStatus.read ? AppColors.info : color;
    return ExcludeSemantics(child: Icon(icon, size: 12, color: tint));
  }
}

class _SystemNotice extends StatelessWidget {
  const _SystemNotice({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenH,
        vertical: AppSpacing.sm,
      ),
      child: Center(
        child: Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
