import 'package:beige/features/meetings/data/mappers/meeting_enum_mapper.dart';
import 'package:beige/features/meetings/domain/models/meeting_category.dart';
import 'package:beige/features/meetings/domain/models/meeting_platform.dart';
import 'package:beige/features/meetings/domain/models/meeting_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('statusFromServer', () {
    test('pending → upcoming', () {
      expect(
        MeetingEnumMapper.statusFromServer('pending'),
        MeetingStatus.upcoming,
      );
    });

    test('rescheduled → upcoming', () {
      expect(
        MeetingEnumMapper.statusFromServer('rescheduled'),
        MeetingStatus.upcoming,
      );
    });

    test('completed → completed', () {
      expect(
        MeetingEnumMapper.statusFromServer('completed'),
        MeetingStatus.completed,
      );
    });

    test('cancelled → completed', () {
      expect(
        MeetingEnumMapper.statusFromServer('cancelled'),
        MeetingStatus.completed,
      );
    });

    test('unknown / null → upcoming', () {
      expect(
        MeetingEnumMapper.statusFromServer('garbage'),
        MeetingStatus.upcoming,
      );
      expect(
        MeetingEnumMapper.statusFromServer(null),
        MeetingStatus.upcoming,
      );
    });
  });

  group('statusToServer', () {
    test('upcoming/initiated/revision → pending', () {
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
    });

    test('completed → completed', () {
      expect(
        MeetingEnumMapper.statusToServer(MeetingStatus.completed),
        'completed',
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
