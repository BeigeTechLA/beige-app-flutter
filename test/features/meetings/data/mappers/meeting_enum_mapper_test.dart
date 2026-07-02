import 'package:beige/features/meetings/data/mappers/meeting_enum_mapper.dart';
import 'package:beige/features/meetings/domain/models/meeting_category.dart';
import 'package:beige/features/meetings/domain/models/meeting_platform.dart';
import 'package:beige/features/meetings/domain/models/meeting_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('statusFromServer', () {
    test('pending → pending', () {
      expect(
        MeetingEnumMapper.statusFromServer('pending'),
        MeetingStatus.pending,
      );
    });

    test('rescheduled → rescheduled', () {
      expect(
        MeetingEnumMapper.statusFromServer('rescheduled'),
        MeetingStatus.rescheduled,
      );
    });

    test('completed → completed', () {
      expect(
        MeetingEnumMapper.statusFromServer('completed'),
        MeetingStatus.completed,
      );
    });

    test('cancelled → cancelled', () {
      expect(
        MeetingEnumMapper.statusFromServer('cancelled'),
        MeetingStatus.cancelled,
      );
    });

    test('unknown / null → pending', () {
      expect(
        MeetingEnumMapper.statusFromServer('garbage'),
        MeetingStatus.pending,
      );
      expect(
        MeetingEnumMapper.statusFromServer(null),
        MeetingStatus.pending,
      );
    });
  });

  group('statusToServer', () {
    test('upcoming/initiated/revision/pending → pending', () {
      expect(
        MeetingEnumMapper.statusToServer(MeetingStatus.upcoming),
        'pending',
      );
      expect(
        MeetingEnumMapper.statusToServer(MeetingStatus.initiated),
        'pending',
      );
      expect(
        MeetingEnumMapper.statusToServer(MeetingStatus.revision),
        'pending',
      );
      expect(
        MeetingEnumMapper.statusToServer(MeetingStatus.pending),
        'pending',
      );
    });

    test('completed → completed', () {
      expect(
        MeetingEnumMapper.statusToServer(MeetingStatus.completed),
        'completed',
      );
    });

    test('cancelled → cancelled', () {
      expect(
        MeetingEnumMapper.statusToServer(MeetingStatus.cancelled),
        'cancelled',
      );
    });
  });

  group('category', () {
    test('fromServer always returns commercial (placeholder taxonomy)', () {
      expect(
        MeetingEnumMapper.categoryFromServer('post_production'),
        MeetingCategory.commercial,
      );
      expect(
        MeetingEnumMapper.categoryFromServer(null),
        MeetingCategory.commercial,
      );
    });

    test('toServer always returns post_production (placeholder taxonomy)', () {
      for (final c in MeetingCategory.values) {
        expect(MeetingEnumMapper.categoryToServer(c), 'post_production');
      }
    });
  });

  group('platformFromLink', () {
    test('zoom URL → zoom', () {
      expect(
        MeetingEnumMapper.platformFromLink('https://zoom.us/j/123456'),
        MeetingPlatform.zoom,
      );
    });

    test('teams URL → teams', () {
      expect(
        MeetingEnumMapper.platformFromLink(
          'https://teams.microsoft.com/l/meetup/abc',
        ),
        MeetingPlatform.teams,
      );
    });

    test('meet URL → meet', () {
      expect(
        MeetingEnumMapper.platformFromLink('https://meet.google.com/xyz'),
        MeetingPlatform.meet,
      );
    });

    test('empty / null / garbage → meet (default)', () {
      expect(
        MeetingEnumMapper.platformFromLink(''),
        MeetingPlatform.meet,
      );
      expect(
        MeetingEnumMapper.platformFromLink(null),
        MeetingPlatform.meet,
      );
      expect(
        MeetingEnumMapper.platformFromLink('https://example.com'),
        MeetingPlatform.meet,
      );
    });
  });
}
