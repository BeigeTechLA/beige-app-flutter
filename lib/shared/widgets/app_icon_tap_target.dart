import 'package:flutter/material.dart';

import '../../app/spacing.dart';

/// Wraps an [icon] widget in an accessible, min-44px tap target.
///
/// Keeps icons visually compact while guaranteeing a comfortable hit area and
/// a [Semantics] button label for screen readers.
class AppIconTapTarget extends StatelessWidget {
  const AppIconTapTarget({
    super.key,
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
    this.minSize = 44,
  });

  final Widget icon;
  final VoidCallback onTap;
  final String semanticLabel;
  final double minSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxs),
            child: Center(widthFactor: 1, heightFactor: 1, child: icon),
          ),
        ),
      ),
    );
  }
}
