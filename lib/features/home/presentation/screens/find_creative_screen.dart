import 'package:flutter/material.dart';
import '../../../../shared/widgets/finding_creative_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:beige/app/route_names.dart';

class FindCreativeScreen extends ConsumerStatefulWidget {
  final int bookingId;
  final int ShootTypeId;
  final int contentTypeId;

  const FindCreativeScreen({
    super.key,
    required this.bookingId,
    required this.ShootTypeId,
    required this.contentTypeId,
  });

  @override
  ConsumerState<FindCreativeScreen> createState() => _FindCreativeScreenState();
}

class _FindCreativeScreenState extends ConsumerState<FindCreativeScreen> {
  @override
  void initState() {
    super.initState();

    /// ⏱ Auto navigate after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.pushReplacementNamed(
        RouteNames.selectDreamTeam,
        extra: {
          'bookingId': widget.bookingId,
          'contentTypeId': widget.contentTypeId,
          'shootTypeId': widget.ShootTypeId,
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) => const FindingCreativeLoader();
}
