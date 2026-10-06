import 'package:beige/features/booking/data/datasources/booking_remote_datasource.dart';
import 'package:beige/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:beige/features/booking/domain/entities/booking_enums.dart';
import 'package:beige/features/booking/domain/entities/edit_selection.dart';
import 'package:beige/features/booking/domain/entities/submit_request.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements BookingRemoteDataSource {}

void main() {
  late _MockRemote remote;
  late BookingRepositoryImpl repo;

  setUp(() {
    remote = _MockRemote();
    repo = BookingRepositoryImpl(remote);
  });

  group('getShootTypeCatalogue', () {
    test('maps data list sorted by display order (happy path)', () async {
      when(() => remote.getShootTypesCatalogue()).thenAnswer(
        (_) async => {
          'data': [
            {'name': 'Music Video', 'display_order': 2},
            {'name': 'Wedding', 'display_order': 1, 'image': 'w.png'},
          ],
        },
      );

      final result = await repo.getShootTypeCatalogue();

      final list = result.getOrElse(() => []);
      expect(list.map((e) => e.name), ['Wedding', 'Music Video']);
      expect(list.first.imageUrl, 'w.png');
    });

    test('empty data yields empty list (edge case)', () async {
      when(
        () => remote.getShootTypesCatalogue(),
      ).thenAnswer((_) async => {'data': <dynamic>[]});

      final result = await repo.getShootTypeCatalogue();
      expect(result.getOrElse(() => []), isEmpty);
    });

    test('error:true envelope becomes a Left failure (error case)', () async {
      when(() => remote.getShootTypesCatalogue()).thenAnswer(
        (_) async => {'error': true, 'message': 'boom'},
      );

      final result = await repo.getShootTypeCatalogue();
      expect(result.isLeft(), isTrue);
    });
  });

  group('getEditTypesCatalogue', () {
    test('requests exact content_type wire value and maps keys', () async {
      when(
        () => remote.getEditTypesByContentType(
          contentType: any(named: 'contentType'),
        ),
      ).thenAnswer(
        (_) async => {
          'data': {
            'video_edit_types': [
              {'key': 'highlight_video_4_7', 'label': 'Highlight Video'},
            ],
            'photo_edit_types': [
              {'key': 'edited_photos', 'label': 'Edited Photos'},
            ],
          },
        },
      );

      final result = await repo.getEditTypesCatalogue(
        contentType: BookingContentType.photographerVideographer,
      );

      verify(
        () => remote.getEditTypesByContentType(
          contentType: 'photographer,videographer',
        ),
      ).called(1);
      final cat = result.getOrElse(
        () => throw StateError('expected catalogue'),
      );
      expect(cat.videoEditTypes.single.key, 'highlight_video_4_7');
      expect(cat.photoEditTypes.single.key, 'edited_photos');
    });
  });

  group('saveEdits', () {
    test('sends edits_needed:false with empty arrays for No', () async {
      when(
        () => remote.saveEdits(
          bookingId: any(named: 'bookingId'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => {'error': false});

      await repo.saveEdits(bookingId: 7, selection: const EditSelection());

      final captured = verify(
        () => remote.saveEdits(
          bookingId: 7,
          data: captureAny(named: 'data'),
        ),
      ).captured.single as Map<String, dynamic>;
      expect(captured['edits_needed'], false);
      expect(captured['video_edit_types'], isEmpty);
      expect(captured['photo_edit_types'], isEmpty);
    });
  });

  group('reviewBooking / quoteBooking', () {
    test('both wrap items in add_on_items', () async {
      when(
        () => remote.postReview(
          bookingId: any(named: 'bookingId'),
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => {
          'data': {
            'project': {'service': 'Wedding Photo + Video'},
            'schedule': {'is_date_to_be_decided': true},
            'editing_services': {'receive_text': "You'll Receive 425 Photos"},
          },
        },
      );
      when(
        () => remote.postQuote(
          bookingId: any(named: 'bookingId'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => {'error': false});

      final items = [
        {'slug': 'v4-additional-camera', 'quantity': 1},
      ];
      final review = await repo.reviewBooking(bookingId: 9, addOnItems: items);
      await repo.quoteBooking(bookingId: 9, addOnItems: items);

      final mapped = review.getOrElse(
        () => throw StateError('expected review'),
      );
      expect(mapped.service, 'Wedding Photo + Video');
      expect(mapped.isDateToBeDecided, isTrue);
      expect(mapped.editingServices.receiveText, "You'll Receive 425 Photos");

      final reviewData = verify(
        () => remote.postReview(
          bookingId: 9,
          data: captureAny(named: 'data'),
        ),
      ).captured.single as Map<String, dynamic>;
      expect(reviewData['add_on_items'], items);
    });
  });

  group('submitBooking', () {
    test('serializes ai_matchmaker + crew ids', () async {
      when(
        () => remote.submitBooking(
          bookingId: any(named: 'bookingId'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async => {'error': false});

      await repo.submitBooking(
        bookingId: 3,
        request: const SubmitRequest(
          contact: ContactInfo(
            fullName: 'Harsh Patel',
            email: 'harsh@test.com',
            phone: '7777777777',
          ),
          selectedCrewIds: [2129, 2130],
        ),
      );

      final data = verify(
        () => remote.submitBooking(
          bookingId: 3,
          data: captureAny(named: 'data'),
        ),
      ).captured.single as Map<String, dynamic>;
      expect(data['matching_method'], 'ai_matchmaker');
      expect(data['selected_crew_ids'], [2129, 2130]);
      expect(data.containsKey('let_beige_choose'), isFalse);
    });
  });

  group('createPaymentSheet', () {
    test('passes provider wire value and maps stripe config', () async {
      when(
        () => remote.createPaymentSheet(
          bookingId: any(named: 'bookingId'),
          paymentMethod: any(named: 'paymentMethod'),
        ),
      ).thenAnswer(
        (_) async => {
          'data': {'payment_intent_client_secret': 'pi_secret'},
        },
      );

      final result = await repo.createPaymentSheet(
        bookingId: 5,
        method: BookingPaymentMethod.stripe,
      );

      verify(
        () => remote.createPaymentSheet(
          bookingId: 5,
          paymentMethod: 'stripe',
        ),
      ).called(1);
      final cfg = result.getOrElse(() => throw StateError('expected config'));
      expect(cfg.isUsable, isTrue);
      expect(cfg.stripePaymentIntentClientSecret, 'pi_secret');
    });
  });
}
