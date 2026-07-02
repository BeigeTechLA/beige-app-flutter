import 'package:beige/features/meetings/data/dto/meeting_dto.dart';
import 'package:beige/features/meetings/domain/models/meeting_platform.dart';
import 'package:beige/features/meetings/domain/models/meeting_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MeetingDto.fromRestJson', () {
    test('parses full payload with participants + order project', () {
      final m = MeetingDto.fromRestJson({
        'id': 198,
        'meeting_title': 'Kickoff',
        'description': 'planning sync',
        'meeting_date_time': '2026-06-11T13:00:00Z',
        'meeting_end_time': '2026-06-11T14:00:00Z',
        'meeting_status': 'pending',
        'meeting_type': 'post_production',
        'meetLink': 'https://meet.google.com/abc',
        'order': {'name': 'Cover Story Shoot'},
        'participants': [
          {'id': 5, 'name': 'A'},
          {'id': 7, 'name': 'B'},
        ],
      });

      expect(m.id, '198');
      expect(m.title, 'Kickoff');
      expect(m.description, 'planning sync');
      expect(m.project, 'Cover Story Shoot');
      expect(m.platform, MeetingPlatform.meet);
      expect(m.status, MeetingStatus.pending);
      expect(m.link, 'https://meet.google.com/abc');
      expect(m.participants.length, 2);
      expect(m.participants.first.id, '5');
      expect(m.participants.first.name, 'A');
      // Server has no reminder field — default 15.
      expect(m.reminderMinutes, 15);
      // Server has no agenda — empty.
      expect(m.agenda, isEmpty);
    });

    test('parses nullable fields defensively', () {
      final m = MeetingDto.fromRestJson({
        'id': 42,
        'meeting_title': 'No Frills',
        'meeting_date_time': '2026-06-11T13:00:00Z',
        'meeting_end_time': '2026-06-11T14:00:00Z',
        'meeting_status': 'cancelled',
        'meetLink': '',
        // description, order, participants all missing.
      });

      expect(m.description, '');
      expect(m.project, '');
      expect(m.participants, isEmpty);
      // cancelled → cancelled (direct pass-through).
      expect(m.status, MeetingStatus.cancelled);
      // Empty link → meet default.
      expect(m.platform, MeetingPlatform.meet);
    });

    test('zoom link → zoom platform', () {
      final m = MeetingDto.fromRestJson({
        'id': '7',
        'meeting_title': 'Z',
        'meeting_date_time': '2026-06-11T13:00:00Z',
        'meeting_end_time': '2026-06-11T14:00:00Z',
        'meeting_status': 'pending',
        'meetLink': 'https://zoom.us/j/999',
      });

      expect(m.platform, MeetingPlatform.zoom);
    });

    test('UTC time round-trip → local', () {
      final m = MeetingDto.fromRestJson({
        'id': '1',
        'meeting_title': 'T',
        'meeting_date_time': '2026-06-11T13:00:00Z',
        'meeting_end_time': '2026-06-11T14:00:00Z',
        'meeting_status': 'pending',
        'meetLink': 'https://meet.google.com/x',
      });

      // Stored as local; the parsed instant must equal the UTC instant given.
      expect(
        m.startAt.toUtc().toIso8601String(),
        '2026-06-11T13:00:00.000Z',
      );
      expect(m.startAt.isUtc, false);
    });

    test('falls back to _id when id absent', () {
      final m = MeetingDto.fromRestJson({
        '_id': 'mongo-style-id',
        'meeting_title': 'T',
        'meeting_date_time': '2026-06-11T13:00:00Z',
        'meeting_end_time': '2026-06-11T14:00:00Z',
        'meeting_status': 'pending',
        'meetLink': '',
      });

      expect(m.id, 'mongo-style-id');
    });

    test('empty date string → epoch sentinel (no throw)', () {
      final m = MeetingDto.fromRestJson({
        'id': '1',
        'meeting_title': 'T',
        'meeting_date_time': '',
        'meeting_end_time': '',
        'meeting_status': 'pending',
        'meetLink': '',
      });

      expect(m.startAt.millisecondsSinceEpoch, 0);
      expect(m.endAt.millisecondsSinceEpoch, 0);
    });

    test('extracts createdById from nested created_by user object', () {
      final m = MeetingDto.fromRestJson({
        'id': '1',
        'meeting_title': 'T',
        'meeting_date_time': '2026-06-11T13:00:00Z',
        'meeting_end_time': '2026-06-11T14:00:00Z',
        'meeting_status': 'pending',
        'meetLink': '',
        'created_by': {'id': 198, 'name': 'Arpit S', 'role': 'client'},
      });

      expect(m.createdById, '198');
    });

    test('accepts scalar created_by id', () {
      final m = MeetingDto.fromRestJson({
        'id': '1',
        'meeting_title': 'T',
        'meeting_date_time': '2026-06-11T13:00:00Z',
        'meeting_end_time': '2026-06-11T14:00:00Z',
        'meeting_status': 'pending',
        'meetLink': '',
        'created_by': 42,
      });

      expect(m.createdById, '42');
    });

    test('null created_by → createdById null', () {
      final m = MeetingDto.fromRestJson({
        'id': '1',
        'meeting_title': 'T',
        'meeting_date_time': '2026-06-11T13:00:00Z',
        'meeting_end_time': '2026-06-11T14:00:00Z',
        'meeting_status': 'pending',
        'meetLink': '',
        // created_by omitted
      });

      expect(m.createdById, isNull);
    });
  });
}
