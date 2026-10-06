import 'package:dartz/dartz.dart';

import '../../../../core/network/exceptions/app_exception.dart';
import '../../../../core/network/exceptions/exception_handler.dart';
import '../../domain/entities/addon_catalogue_item.dart';
import '../../domain/entities/booking_enums.dart';
import '../../domain/entities/booking_review.dart';
import '../../domain/entities/booking_summary.dart';
import '../../domain/entities/creator_match.dart';
import '../../domain/entities/edit_selection.dart';
import '../../domain/entities/edit_type_option.dart';
import '../../domain/entities/payment_review.dart';
import '../../domain/entities/payment_sheet_config.dart';
import '../../domain/entities/shoot_type_option.dart';
import '../../domain/entities/submit_request.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource _remoteDataSource;

  BookingRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppException, List<dynamic>>> getShootTypes({
    required int contentTypeId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getShootTypes(
        contentTypeId: contentTypeId,
      );
      _assertNoError(response);
      final data = response['data'];
      if (data is List) return data;
      return <dynamic>[];
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> createBooking({
    required Map<String, dynamic> data,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.createBooking(data: data);
      _assertNoError(response);
      return response;
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> updateBooking({
    required int bookingId,
    required Map<String, dynamic> data,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.updateBooking(
        bookingId: bookingId,
        data: data,
      );
      _assertNoError(response);
      return response;
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> getEditTypes({
    required int shootTypeId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getEditTypes(
        shootTypeId: shootTypeId,
      );
      _assertNoError(response);
      return response['data'] as Map<String, dynamic>;
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> updateBookingTime({
    required int bookingId,
    required Map<String, dynamic> data,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.updateBookingTime(
        bookingId: bookingId,
        data: data,
      );
      _assertNoError(response);
      return response;
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> getBookingTime({
    required int bookingId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getBookingTime(
        bookingId: bookingId,
      );
      _assertNoError(response);
      return response['data'] as Map<String, dynamic>;
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> updateBookingDetails({
    required int bookingId,
    required Map<String, dynamic> data,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.updateBookingDetails(
        bookingId: bookingId,
        data: data,
      );
      _assertNoError(response);
      return response;
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> getCrewRecommendation({
    required int bookingId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getCrewRecommendation(
        bookingId: bookingId,
      );
      _assertNoError(response);
      return response['data'] as Map<String, dynamic>;
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> getCrewMatches({
    required int bookingId,
    String sort = 'nearest',
    int page = 1,
    int limit = 400,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getCrewMatches(
        bookingId: bookingId,
        sort: sort,
        page: page,
        limit: limit,
      );
      _assertNoError(response);
      return response['data'] as Map<String, dynamic>;
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> getHolds({
    required int bookingId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getHolds(bookingId: bookingId);
      _assertNoError(response);
      return response['data'] as Map<String, dynamic>;
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> addHold({
    required int bookingId,
    required int crewMemberId,
    required int roleId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.addHold(
        bookingId: bookingId,
        crewMemberId: crewMemberId,
        roleId: roleId,
      );
      _assertNoError(response);
      return response;
    });
  }

  @override
  Future<Either<AppException, Map<String, dynamic>>> removeHold({
    required int bookingId,
    required int crewMemberId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.removeHold(
        bookingId: bookingId,
        crewMemberId: crewMemberId,
      );
      _assertNoError(response);
      return response;
    });
  }

  @override
  Future<Either<AppException, List<dynamic>>> getBookingParticipants({
    required int bookingId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getBookingParticipants(
        bookingId: bookingId,
      );
      _assertNoError(response);
      final data = response['data'];
      if (data is List) return data;
      if (data is Map) {
        final flat = <dynamic>[];
        for (final key in const [
          'staff',
          'clients',
          'creativePartners',
          'cp',
        ]) {
          final v = data[key];
          if (v is List) flat.addAll(v);
        }
        if (flat.isNotEmpty) return flat;
      }
      final users = response['users'];
      if (users is List) return users;
      final participants = response['participants'];
      if (participants is List) return participants;
      return <dynamic>[];
    });
  }

  // ───── New Book-a-Shoot flow (api_flow.pdf) ──────────────────────────────

  @override
  Future<Either<AppException, List<ShootTypeOption>>> getShootTypeCatalogue() {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getShootTypesCatalogue();
      _assertNoError(response);
      return ShootTypeOption.listFrom(response);
    });
  }

  @override
  Future<Either<AppException, EditTypesCatalogue>> getEditTypesCatalogue({
    required BookingContentType contentType,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getEditTypesByContentType(
        contentType: contentType.wireValue,
      );
      _assertNoError(response);
      final data = response['data'] as Map<String, dynamic>? ?? response;
      return EditTypesCatalogue.fromData(data);
    });
  }

  @override
  Future<Either<AppException, List<AddonCatalogueItem>>> getAddonCatalogue() {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getAddons();
      _assertNoError(response);
      return AddonCatalogueItem.listFrom(response);
    });
  }

  @override
  Future<Either<AppException, Unit>> saveEdits({
    required int bookingId,
    required EditSelection selection,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.saveEdits(
        bookingId: bookingId,
        data: selection.toEditsPayload(),
      );
      _assertNoError(response);
      return unit;
    });
  }

  @override
  Future<Either<AppException, CreatorMatchPage>> getCreatorMatches({
    required int bookingId,
    int page = 1,
    int limit = 12,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getMatchesPaged(
        bookingId: bookingId,
        page: page,
        limit: limit,
      );
      _assertNoError(response);
      final data = response['data'] as Map<String, dynamic>? ?? response;
      return CreatorMatchPage.fromData(data, page: page);
    });
  }

  @override
  Future<Either<AppException, BookingReview>> reviewBooking({
    required int bookingId,
    required List<Map<String, dynamic>> addOnItems,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.postReview(
        bookingId: bookingId,
        data: {'add_on_items': addOnItems},
      );
      _assertNoError(response);
      final data = response['data'] as Map<String, dynamic>? ?? response;
      return BookingReview.fromData(data);
    });
  }

  @override
  Future<Either<AppException, Unit>> quoteBooking({
    required int bookingId,
    required List<Map<String, dynamic>> addOnItems,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.postQuote(
        bookingId: bookingId,
        data: {'add_on_items': addOnItems},
      );
      _assertNoError(response);
      return unit;
    });
  }

  @override
  Future<Either<AppException, PaymentReview>> getPaymentReview({
    required int bookingId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getPaymentReview(
        bookingId: bookingId,
      );
      _assertNoError(response);
      final data = response['data'] as Map<String, dynamic>? ?? response;
      return PaymentReview.fromData(data);
    });
  }

  @override
  Future<Either<AppException, Unit>> submitBooking({
    required int bookingId,
    required SubmitRequest request,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.submitBooking(
        bookingId: bookingId,
        data: request.toJson(),
      );
      _assertNoError(response);
      return unit;
    });
  }

  @override
  Future<Either<AppException, PaymentSheetConfig>> createPaymentSheet({
    required int bookingId,
    required BookingPaymentMethod method,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.createPaymentSheet(
        bookingId: bookingId,
        paymentMethod: method.wireValue,
      );
      _assertNoError(response);
      final data = response['data'] as Map<String, dynamic>? ?? response;
      return PaymentSheetConfig.fromData(data, method: method);
    });
  }

  @override
  Future<Either<AppException, BookingSummary>> getBookingSummary({
    required int bookingId,
  }) {
    return ExceptionHandler.guardAsync(() async {
      final response = await _remoteDataSource.getSummaryDetails(
        bookingId: bookingId,
      );
      _assertNoError(response);
      final data = response['data'] as Map<String, dynamic>? ?? response;
      return BookingSummary.fromData(data);
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
