import 'package:beige/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/route_names.dart';
import 'delete_account_screen.dart';
import 'delete_account_otp_screen.dart';
import 'delete_account_success_screen.dart';

@Preview(
  name: 'Before deletion',
  group: 'Account deletion',
  size: Size(375, 812),
)
Widget deleteAccountPreview() => const _FlowPreview('/');

@Preview(
  name: 'Verify identity',
  group: 'Account deletion',
  size: Size(375, 812),
)
Widget deleteAccountOtpPreview() => const _FlowPreview('/otp');

@Preview(
  name: 'Deletion requested',
  group: 'Account deletion',
  size: Size(375, 812),
)
Widget deleteAccountSuccessPreview() => const _FlowPreview('/success');

class _FlowPreview extends StatefulWidget {
  const _FlowPreview(this.location);
  final String location;
  @override
  State<_FlowPreview> createState() => _FlowPreviewState();
}

class _FlowPreviewState extends State<_FlowPreview> {
  late final _router = GoRouter(
    initialLocation: widget.location,
    routes: [
      GoRoute(path: '/', builder: (_, _) => const DeleteAccountScreen()),
      GoRoute(
        path: '/otp',
        name: RouteNames.deleteAccountOtp,
        builder: (_, _) => const DeleteAccountOtpScreen(),
      ),
      GoRoute(
        path: '/success',
        name: RouteNames.deleteAccountSuccess,
        builder: (_, _) => const DeleteAccountSuccessScreen(),
      ),
    ],
  );
  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.dark(),
    routerConfig: _router,
  );
}
