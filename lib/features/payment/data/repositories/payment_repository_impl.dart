import 'package:dartz/dartz.dart';

import '../../../../core/network/exceptions/app_exception.dart';
import '../../../../core/network/exceptions/exception_handler.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource _remoteDataSource;

  PaymentRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppException, Map<String, dynamic>>> getSavedPaymentMethods() {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getSavedPaymentMethods();
      _assertNoError(response);
      return response['data'] as Map<String, dynamic>;
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> createPaymentSheet({
    required int bookingId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.createPaymentSheet(
        bookingId: bookingId,
      );
      _assertNoError(response);
      return response['data'] as Map<String, dynamic>;
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> updatePaymentInfo({
    required int bookingId,
    required Map<String, dynamic> data,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.updatePaymentInfo(
        bookingId: bookingId,
        data: data,
      );
      _assertNoError(response);
      return response;
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> confirmStripePayment({
    required int bookingId,
    required String paymentIntentId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.confirmStripePayment(
        bookingId: bookingId,
        paymentIntentId: paymentIntentId,
      );
      _assertNoError(response);
      return response;
    });
  }

  void _assertNoError(Map<String, dynamic> response) {
    if (response['error'] == true) {
      throw UnknownException(
        message: (response['message'] as String?) ?? 'Request failed',
      );
    }
  }
}
