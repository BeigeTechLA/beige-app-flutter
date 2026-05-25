import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/shoot_remote_datasource.dart';
import '../../data/repositories/shoot_repository_impl.dart';
import '../../domain/repositories/shoot_repository.dart';

final _shootRemoteDataSourceProvider = Provider<ShootRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ShootRemoteDataSource(dioClient);
});

final shootRepositoryProvider = Provider<ShootRepository>((ref) {
  final dataSource = ref.watch(_shootRemoteDataSourceProvider);
  return ShootRepositoryImpl(dataSource);
});
