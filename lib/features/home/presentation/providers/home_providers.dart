import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/home_remote_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/repositories/home_repository.dart';

final _homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return HomeRemoteDataSource(dioClient);
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final dataSource = ref.watch(_homeRemoteDataSourceProvider);
  return HomeRepositoryImpl(dataSource);
});
