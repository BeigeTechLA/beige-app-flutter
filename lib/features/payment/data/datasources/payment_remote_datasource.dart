import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';

/// Raw API calls for payment operations.
class PaymentRemoteDataSource {
  final DioClient _dioClient;

  PaymentRemoteDataSource(this._dioClient);

  /// GET payment
  Future<Map<String, dynamic>> getSavedPaymentMethods() async {
    final response = await _dioClient.dio.get(ApiEndpoints.payment);
    return response.data as Map<String, dynamic>;
  }

  /// POST bookings/{bookingId}/paymentsheet
  Future<Map<String, dynamic>> createPaymentSheet({
    required int bookingId,
  }) async {
    final response = await _dioClient.dio.post(
      '${ApiEndpoints.bookings}/$bookingId/paymentsheet',
      data: {},
    );
    return response.data as Map<String, dynamic>;
  }

  /// PUT bookings/{bookingId}/payment
  Future<Map<String, dynamic>> updatePaymentInfo({
    required int bookingId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dioClient.dio.put(
      '${ApiEndpoints.bookings}/$bookingId/payment',
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// POST payment/{bookingId}/stripe/confirm
  Future<Map<String, dynamic>> confirmStripePayment({
    required int bookingId,
    required String paymentIntentId,
  }) async {
    final response = await _dioClient.dio.post(
      '${ApiEndpoints.payment}/$bookingId/stripe/confirm',
      data: {'payment_intent_id': paymentIntentId},
    );
    return response.data as Map<String, dynamic>;
  }
}
