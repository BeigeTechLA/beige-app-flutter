import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/creative_remote_datasource.dart';
import '../../data/repositories/creative_repository_impl.dart';
import '../../domain/repositories/creative_repository.dart';

final _creativeRemoteDataSourceProvider =
    Provider<CreativeRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return CreativeRemoteDataSource(dioClient);
});

final creativeRepositoryProvider = Provider<CreativeRepository>((ref) {
  final dataSource = ref.watch(_creativeRemoteDataSourceProvider);
  return CreativeRepositoryImpl(dataSource);
});
