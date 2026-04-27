import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/colors.dart';
import 'package:beige/app/route_names.dart';

class FindCreativeScreen extends ConsumerStatefulWidget {
  final int bookingId;
  final int specialtyId;
  final int ShootTypeId;
  final int contentTypeId;

  const FindCreativeScreen({
    super.key,
    required this.bookingId,
    required this.specialtyId,
    required this.ShootTypeId,
    required this.contentTypeId,
  });

  @override
  ConsumerState<FindCreativeScreen> createState() =>
      _FindCreativeScreenState();
}

class _FindCreativeScreenState extends ConsumerState<FindCreativeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    /// ⏱ Auto navigate after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.goNamed(RouteNames.selectDreamTeam, extra: {
        'bookingId': widget.bookingId,
        'contentTypeId': widget.contentTypeId,
        'specialtyId': widget.specialtyId,
        'shootTypeId': widget.ShootTypeId,
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 🔥 GLOW + SPARKLE LOADER
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: 199.5,
                  height: 199.5,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.white
                            .withValues(alpha: 0.35 * _controller.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _controller.value * 2 * 3.1416,
                          child: Transform.scale(
                            scale: 0.85 + (_controller.value * 0.3),
                            child: const Icon(
                              Icons.auto_awesome,
                              size: 34,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),


                );
              },
            ),

            const SizedBox(height: 24),

            /// 🔤 TEXT
            const Text(
              "Finding The Perfect Creator\nFor You...",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Unbounded",
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
