import 'package:dartz/dartz.dart';

import '../../../../core/network/exceptions/app_exception.dart';

/// Contract for my-shoots related API operations.
abstract class ShootRepository {
  /// Fetches shoots by status (upcoming / completed).
  Future<Either<AppException, List<dynamic>>> getMyShoots({
    required String status,
  });

  /// Fetches a single shoot's details.
  Future<Either<AppException, Map<String, dynamic>>> getShootDetails({
    required int bookingId,
  });

  /// Fetches a shoot's timeline.
  Future<Either<AppException, List<dynamic>>> getShootTimeline({
    required int bookingId,
  });

  /// Cancels a shoot.
  Future<Either<AppException, Map<String, dynamic>>> cancelShoot({
    required int bookingId,
  });

  /// Fetches booking summary details (for edit/reschedule review).
  Future<Either<AppException, Map<String, dynamic>>> getBookingSummary({
    required int bookingId,
  });

  /// Confirms a booking reschedule.
  Future<Either<AppException, Map<String, dynamic>>> confirmReschedule({
    required int bookingId,
  });
}
