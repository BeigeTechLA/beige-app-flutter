import '../../domain/entities/chat_details.dart';
import 'participant_dto.dart';
import 'shared_file_dto.dart';

class ChatDetailsDto {
  /// REST shape from `GET /external-chat/room/:roomId/details`.
  ///
  /// Backend returns:
  /// ```
  /// { success, data: { room, profile, participants: { items, ... },
  ///   linkedShoot, sharedFiles: { items, ... }, notes: { value } } }
  /// ```
  /// `PaginationEnvelope.unwrapItem` strips `data`, so this receives the
  /// inner object.
  ///
  /// `conversationId` is passed in because the room is keyed by `room.id`
  /// (Mongo doc id) and we want to stay aligned with the caller's id.
  static ChatDetails fromRestJson(
    Map<String, dynamic> json, {
    required String conversationId,
  }) {
    final room = (json['room'] as Map<String, dynamic>?) ?? const {};
    final profile = (json['profile'] as Map<String, dynamic>?) ?? const {};

    final participantsItems =
        ((json['participants'] as Map<String, dynamic>?)?['items'] as List?) ??
        const [];

    final shootRaw = json['linkedShoot'] as Map<String, dynamic>?;

    final filesItems =
        ((json['sharedFiles'] as Map<String, dynamic>?)?['items'] as List?) ??
        const [];

    final notesBlock = json['notes'];
    final String notes = notesBlock is Map<String, dynamic>
        ? ((notesBlock['value'] as String?) ?? '')
        : ((notesBlock as String?) ?? '');

    return ChatDetails(
      conversationId: conversationId,
      roomName: (room['display_name'] ?? room['name'] ?? '') as String,
      contact: ContactInfo(
        id: (profile['id'] ?? '').toString(),
        name: (profile['name'] ?? '') as String,
        email: profile['email'] as String?,
        phone: profile['phone'] as String?,
        avatarUrl: profile['profileImage'] as String?,
      ),
      participants: participantsItems
          .cast<Map<String, dynamic>>()
          .map(ParticipantDto.fromRestJson)
          .toList(growable: false),
      linkedShoot: shootRaw == null ? null : _shootFrom(shootRaw),
      sharedFiles: filesItems
          .cast<Map<String, dynamic>>()
          .map(SharedFileDto.fromRestJson)
          .toList(growable: false),
      notes: notes,
    );
  }

  static LinkedShoot _shootFrom(Map<String, dynamic> raw) {
    final id = (raw['bookingId'] ?? raw['id'] ?? raw['_id'] ?? '').toString();
    final title =
        (raw['name'] ?? raw['title'] ?? raw['shootType'] ?? '') as String;
    final dateStr =
        (raw['eventDate'] ??
                raw['date'] ??
                raw['shoot_date'] ??
                raw['createdAt'])
            ?.toString();
    final date = dateStr == null
        ? DateTime.fromMillisecondsSinceEpoch(0)
        : DateTime.parse(dateStr).toLocal();
    return LinkedShoot(id: id, title: title, date: date);
  }
}
