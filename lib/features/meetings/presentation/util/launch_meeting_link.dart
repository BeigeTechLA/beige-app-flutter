import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/widgets/top_message.dart';

/// Opens a meeting link in the platform's external browser / native app
/// (Meet / Zoom / Teams resolve via OS scheme handler).
Future<void> launchMeetingLink(BuildContext context, String link) async {
  if (link.trim().isEmpty) {
    if (context.mounted) {
      TopMessage.show(context, 'No meeting link available');
    }
    return;
  }

  final uri = Uri.tryParse(link);
  if (uri == null || !uri.hasScheme) {
    if (context.mounted) {
      TopMessage.show(context, 'Invalid meeting link');
    }
    return;
  }

  try {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      TopMessage.show(context, 'Could not open meeting link');
    }
  } catch (_) {
    if (context.mounted) {
      TopMessage.show(context, 'Could not open meeting link');
    }
  }
}
