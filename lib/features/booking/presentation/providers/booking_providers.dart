import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/booking_remote_datasource.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/repositories/booking_repository.dart';

final _bookingRemoteDataSourceProvider =
    Provider<BookingRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return BookingRemoteDataSource(dioClient);
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final dataSource = ref.watch(_bookingRemoteDataSourceProvider);
  return BookingRepositoryImpl(dataSource);
});
