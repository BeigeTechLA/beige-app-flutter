import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/messages_remote_data_source.dart';
import '../../data/repositories/messages_repository_impl.dart';
import '../../domain/repositories/messages_repository.dart';

// Step 1: DataSource provider
final _messagesRemoteDataSourceProvider =
Provider<MessagesRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return MessagesRemoteDataSource(dioClient);
});

// Step 2: Repository provider
final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  final dataSource = ref.watch(_messagesRemoteDataSourceProvider);
  return MessagesRepositoryImpl(dataSource);
});