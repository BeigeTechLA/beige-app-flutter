import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_providers.dart';
import 'data/push_preferences_remote_datasource.dart';
import 'data/push_preferences_repository_impl.dart';
import 'domain/push_preferences_repository.dart';

final _pushPreferencesDataSourceProvider =
    Provider<PushPreferencesRemoteDataSource>(
      (ref) => PushPreferencesRemoteDataSource(ref.watch(dioClientProvider)),
    );

final pushPreferencesRepositoryProvider = Provider<PushPreferencesRepository>(
  (ref) =>
      PushPreferencesRepositoryImpl(ref.watch(_pushPreferencesDataSourceProvider)),
);
