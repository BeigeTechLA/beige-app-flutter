import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

/// Provides [AuthRemoteDataSource] — internal, not exposed to UI.
final _authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthRemoteDataSource(dioClient);
});

/// Provides [AuthRepository] — the only auth dependency UI needs.
///
/// Usage in Notifiers:
/// ```dart
/// final repo = ref.read(authRepositoryProvider);
/// final result = await repo.login(email: email, password: password);
/// ```
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(_authRemoteDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});
