import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connectivity_service.dart';
import 'connectivity_status.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final connectivityStreamProvider = StreamProvider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.watch();
});

final connectivityStatusProvider = Provider<ConnectivityStatus>((ref) {
  return ref.watch(connectivityStreamProvider).maybeWhen(
        data: (status) => status,
        orElse: () => ConnectivityStatus.unknown,
      );
});
