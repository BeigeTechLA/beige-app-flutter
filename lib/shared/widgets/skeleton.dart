import 'package:flutter/material.dart';
import '../../app/colors.dart';
import '../../app/spacing.dart';

/// A custom, premium pulsing skeleton loader for placeholders.
/// Animates opacity from 0.25 to 0.65 sequentially to feel alive and responsive.
class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.height,
    this.width,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  final double? height;
  final double? width;
  final BorderRadiusGeometry? borderRadius;
  final BoxShape shape;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.25,
      end: 0.60,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: AppColors.shimmerHighlight,
              shape: widget.shape,
              borderRadius: widget.shape == BoxShape.circle
                  ? null
                  : (widget.borderRadius ?? BorderRadius.circular(8)),
            ),
          ),
        );
      },
    );
  }
}

/// A list of skeleton items matching the structure of [ConversationTile].
class ConversationListSkeleton extends StatelessWidget {
  const ConversationListSkeleton({super.key, this.itemCount = 8});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const Divider(
        color: AppColors.dividerDark,
        height: 1,
        indent: AppSpacing.screenH,
        endIndent: AppSpacing.screenH,
      ),
      itemBuilder: (context, index) {
        return const ConversationTileSkeleton();
      },
    );
  }
}

/// A skeleton matching a single conversation list tile.
class ConversationTileSkeleton extends StatelessWidget {
  const ConversationTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenH,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Skeleton(width: 40, height: 40, shape: BoxShape.circle),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Skeleton(width: 140, height: 14),
                    Spacer(),
                    Skeleton(width: 50, height: 10),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [Skeleton(width: 200, height: 10)],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A structured skeleton representing a chat message thread.
/// Displays alternating left and right aligned chat message bubble skeletons.
class ChatThreadSkeleton extends StatelessWidget {
  const ChatThreadSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // A pre-defined list of message bubble skeletons to mimic a real conversation layout.
    final List<({bool isMine, double width, bool showAvatar})> layout = [
      (isMine: false, width: 140.0, showAvatar: true),
      (isMine: true, width: 90.0, showAvatar: false),
      (isMine: false, width: 220.0, showAvatar: true),
      (isMine: false, width: 100.0, showAvatar: false),
      (isMine: true, width: 160.0, showAvatar: false),
      (isMine: false, width: 180.0, showAvatar: true),
      (isMine: true, width: 110.0, showAvatar: false),
      (isMine: false, width: 150.0, showAvatar: true),
    ];

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: layout.length,
      itemBuilder: (context, index) {
        final item = layout[index];
        return ChatBubbleSkeleton(
          isMine: item.isMine,
          width: item.width,
          showAvatar: item.showAvatar,
        );
      },
    );
  }
}

/// A single message bubble skeleton.
class ChatBubbleSkeleton extends StatelessWidget {
  const ChatBubbleSkeleton({
    super.key,
    required this.isMine,
    required this.width,
    required this.showAvatar,
  });

  final bool isMine;
  final double width;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    final maxBubbleWidth = MediaQuery.sizeOf(context).width * 0.72;
    final bubbleWidth = width.clamp(0.0, maxBubbleWidth);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenH,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMine) ...[
            if (showAvatar)
              const Skeleton(width: 40, height: 40, shape: BoxShape.circle)
            else
              const SizedBox(width: 40),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMine
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isMine && showAvatar) ...[
                  const Skeleton(width: 80, height: 10),
                  const SizedBox(height: AppSpacing.xxs),
                ],
                Skeleton(
                  width: bubbleWidth,
                  height: 44,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isMine ? 16 : 0),
                    topRight: Radius.circular(isMine ? 0 : 16),
                    bottomLeft: const Radius.circular(16),
                    bottomRight: const Radius.circular(16),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                const Skeleton(width: 50, height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
