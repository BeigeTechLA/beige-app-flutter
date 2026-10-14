import 'package:beige/core/restoration/draft_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('BookingDraft', () {
    test('fromRouteExtra accepts both shootTypeId and ShootTypeId keys', () {
      final a = BookingDraft.fromRouteExtra({'shootTypeId': 5});
      final b = BookingDraft.fromRouteExtra({'ShootTypeId': 5});
      expect(a.shootTypeId, 5);
      expect(b.shootTypeId, 5);
    });

    test('toRouteExtra emits ShootTypeId casing the route builders expect', () {
      final draft = BookingDraft(shootTypeId: 7, bookingId: 12);
      expect(draft.toRouteExtra()['ShootTypeId'], 7);
      expect(draft.toRouteExtra()['bookingId'], 12);
    });

    test('JSON round-trip preserves every field', () {
      const draft = BookingDraft(
        contentTypeId: 1,
        shootTypeId: 3,
        bookingId: 4,
        value: 5,
        currentRoute: '/shoot-date-time',
      );
      final restored = BookingDraft.fromJson(draft.toJson());
      expect(restored.contentTypeId, 1);
      expect(restored.shootTypeId, 3);
      expect(restored.bookingId, 4);
      expect(restored.value, 5);
      expect(restored.currentRoute, '/shoot-date-time');
    });

    test('mergeOver fills nulls from other but does not overwrite values', () {
      const partial = BookingDraft(bookingId: 9);
      const stored = BookingDraft(contentTypeId: 1, shootTypeId: 2);
      final merged = partial.mergeOver(stored);
      expect(merged.bookingId, 9);
      expect(merged.contentTypeId, 1);
      expect(merged.shootTypeId, 2);
    });

    test('parses int from String / num inputs defensively', () {
      final draft = BookingDraft.fromJson({
        'bookingId': '12',
        'contentTypeId': 5.0,
      });
      expect(draft.bookingId, 12);
      expect(draft.contentTypeId, 5);
    });
  });

  group('ManageBookingDraft', () {
    test('JSON round-trip preserves every field', () {
      const draft = ManageBookingDraft(
        bookingId: 12,
        shootTypeId: 1,
        projectName: 'Demo',
        eventDate: '2026-05-01',
        startTime: '10:00',
        endTime: '12:00',
        durationHours: 2.5,
        location: 'Studio',
        imageUrl: 'img.jpg',
        contentType: 'Photo',
        multiDays: [1, 2],
      );
      final restored = ManageBookingDraft.fromJson(draft.toJson());
      expect(restored.bookingId, 12);
      expect(restored.projectName, 'Demo');
      expect(restored.durationHours, 2.5);
      expect(restored.multiDays, [1, 2]);
    });

    test('fromRouteExtra captures all booking-management fields', () {
      final draft = ManageBookingDraft.fromRouteExtra(7, {
        'shootTypeId': 1,
        'projectName': 'Demo',
        'durationHours': 2,
      });
      expect(draft.bookingId, 7);
      expect(draft.shootTypeId, 1);
      expect(draft.projectName, 'Demo');
      expect(draft.durationHours, 2);
    });
  });

  group('CancelBookingDraft', () {
    test('JSON round-trip preserves every field', () {
      const draft = CancelBookingDraft(
        bookingId: 12,
        projectName: 'Demo',
        eventDate: '2026-05-01',
        startTime: '10:00',
        endTime: '12:00',
        durationHours: 2,
        location: 'Studio',
        contentType: 'Photo',
        imageUrl: 'img.jpg',
      );
      final restored = CancelBookingDraft.fromJson(draft.toJson());
      expect(restored.bookingId, 12);
      expect(restored.durationHours, 2);
      expect(restored.location, 'Studio');
    });
  });

  group('DraftStore', () {
    late SharedPreferences prefs;
    late DraftStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      store = DraftStore(prefs);
    });

    test('booking draft round-trips through SharedPreferences', () async {
      const draft = BookingDraft(
        contentTypeId: 1,
        bookingId: 7,
        currentRoute: '/more-details',
      );
      await store.writeBookingDraft(draft);
      final restored = store.readBookingDraft();
      expect(restored?.bookingId, 7);
      expect(restored?.currentRoute, '/more-details');
    });

    test('readBookingDraft returns null when nothing stored', () {
      expect(store.readBookingDraft(), isNull);
    });

    test('corrupt booking JSON is wiped on read', () async {
      await prefs.setString(DraftKeys.booking, 'not-json');
      expect(store.readBookingDraft(), isNull);
      expect(prefs.getString(DraftKeys.booking), isNull);
    });

    test('manage and cancel drafts are independent of booking draft', () async {
      const booking = BookingDraft(bookingId: 1);
      const manage = ManageBookingDraft(bookingId: 2);
      const cancel = CancelBookingDraft(bookingId: 3);
      await store.writeBookingDraft(booking);
      await store.writeManageBookingDraft(manage);
      await store.writeCancelBookingDraft(cancel);

      expect(store.readBookingDraft()?.bookingId, 1);
      expect(store.readManageBookingDraft()?.bookingId, 2);
      expect(store.readCancelBookingDraft()?.bookingId, 3);
    });

    test('clearBookingDraft only wipes the booking key', () async {
      await store.writeBookingDraft(const BookingDraft(bookingId: 1));
      await store.writeManageBookingDraft(
        const ManageBookingDraft(bookingId: 2),
      );
      await store.clearBookingDraft();
      expect(store.readBookingDraft(), isNull);
      expect(store.readManageBookingDraft()?.bookingId, 2);
    });

    test('clearAll wipes all draft keys', () async {
      await store.writeBookingDraft(const BookingDraft(bookingId: 1));
      await store.writeManageBookingDraft(
        const ManageBookingDraft(bookingId: 2),
      );
      await store.writeCancelBookingDraft(
        const CancelBookingDraft(bookingId: 3),
      );
      await store.clearAll();
      expect(store.readBookingDraft(), isNull);
      expect(store.readManageBookingDraft(), isNull);
      expect(store.readCancelBookingDraft(), isNull);
    });
  });

  group('BookingDraft v2 fields', () {
    const draftV2 = BookingDraft(
      bookingId: 10,
      scheduleMode: 'dated',
      matchingMethod: 'manual',
      shootTypeName: 'Wedding',
      editsNeeded: true,
      videoEditTypes: ['highlight_video_4_7', 'feature_video_10_20'],
      photoEditTypes: ['edited_photos'],
      roleCounts: {'photographer': 1, 'videographer': 1, 'photoVideoCreator': 0},
    );

    test('happy path — JSON round-trip preserves every v2 field', () {
      final restored = BookingDraft.fromJson(draftV2.toJson());
      expect(restored.scheduleMode, 'dated');
      expect(restored.matchingMethod, 'manual');
      expect(restored.shootTypeName, 'Wedding');
      expect(restored.editsNeeded, true);
      expect(restored.videoEditTypes, ['highlight_video_4_7', 'feature_video_10_20']);
      expect(restored.photoEditTypes, ['edited_photos']);
      expect(restored.roleCounts, {
        'photographer': 1,
        'videographer': 1,
        'photoVideoCreator': 0,
      });
    });

    test('route-extra round-trip carries v2 fields through the draft merge', () {
      final fromExtra = BookingDraft.fromRouteExtra(draftV2.toRouteExtra());
      expect(fromExtra.scheduleMode, 'dated');
      expect(fromExtra.matchingMethod, 'manual');
      expect(fromExtra.editsNeeded, true);
      expect(fromExtra.photoEditTypes, ['edited_photos']);
      expect(fromExtra.roleCounts?['photographer'], 1);
    });

    test('edge case — absent v2 fields serialize to nothing and read as null', () {
      const bare = BookingDraft(bookingId: 1);
      expect(bare.toJson().containsKey('scheduleMode'), false);
      expect(bare.toJson().containsKey('roleCounts'), false);
      final restored = BookingDraft.fromJson(bare.toJson());
      expect(restored.scheduleMode, isNull);
      expect(restored.videoEditTypes, isNull);
      expect(restored.roleCounts, isNull);
    });

    test('error case — malformed roleCounts/list values are coerced safely', () {
      final restored = BookingDraft.fromJson({
        'bookingId': 2,
        'roleCounts': {'photographer': '3', 'bad': 'x'},
        'videoEditTypes': [1, 'two'],
      });
      // string-numeric coerced, non-numeric dropped
      expect(restored.roleCounts, {'photographer': 3});
      expect(restored.videoEditTypes, ['1', 'two']);
    });

    test('copyWith overwrites a single field, leaving others intact', () {
      final updated = draftV2.copyWith(matchingMethod: 'beigeMatch');
      expect(updated.matchingMethod, 'beigeMatch');
      expect(updated.scheduleMode, 'dated');
      expect(updated.shootTypeName, 'Wedding');
    });

    test('mergeOver does not overwrite an existing v2 value', () {
      const partial = BookingDraft(matchingMethod: 'manual');
      const stored = BookingDraft(matchingMethod: 'beigeMatch', scheduleMode: 'deferred');
      final merged = partial.mergeOver(stored);
      expect(merged.matchingMethod, 'manual'); // kept
      expect(merged.scheduleMode, 'deferred'); // filled
    });
  });
}
