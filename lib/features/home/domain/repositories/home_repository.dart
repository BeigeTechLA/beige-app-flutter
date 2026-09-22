import 'package:dartz/dartz.dart';

import '../../../../core/network/exceptions/app_exception.dart';

/// Contract for home-related API operations.
abstract class HomeRepository {
  /// Fetches home screen data (specialties, creatives, bookings, etc.).
  Future<Either<AppException, Map<String, dynamic>>> getHomeData();

  /// Creates or continues a booking.
  Future<Either<AppException, Map<String, dynamic>>> createBooking({
    required int contentType,
    int? bookingId,
  });

  /// Fetches shoot type IDs for a given content type.
  Future<Either<AppException, List<int>>> getShootTypes({
    required int contentTypeId,
  });
}
