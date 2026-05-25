import 'package:dartz/dartz.dart';

import '../../../../core/network/exceptions/app_exception.dart';

/// Contract for creative-related API operations.
abstract class CreativeRepository {
  Future<Either<AppException, Map<String, dynamic>>> getCreativeProfile({
    required int creativeId,
  });
}
