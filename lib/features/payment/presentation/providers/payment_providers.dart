import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/payment_remote_datasource.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../domain/repositories/payment_repository.dart';

final _paymentRemoteDataSourceProvider =
    Provider<PaymentRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return PaymentRemoteDataSource(dioClient);
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final dataSource = ref.watch(_paymentRemoteDataSourceProvider);
  return PaymentRepositoryImpl(dataSource);
});
