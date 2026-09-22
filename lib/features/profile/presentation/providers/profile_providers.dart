import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';

final _profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((
  ref,
) {
  final dioClient = ref.watch(dioClientProvider);
  return ProfileRemoteDataSource(dioClient);
});

/// Provides [ProfileRepository] — the only profile dependency UI needs.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dataSource = ref.watch(_profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(dataSource);
});
