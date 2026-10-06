import 'package:flutter/foundation.dart';

import 'creator_assignment.dart';

/// A creator card from `GET /bookings/:id/matches`. Role support comes from the
/// API capability data, never from the name or card title.
@immutable
class CreatorMatch {
  const CreatorMatch({
    required this.crewMemberId,
    required this.name,
    required this.supportsPhotographer,
    required this.supportsVideographer,
    this.profileImageUrl,
    this.available = true,
  });

  final int crewMemberId;
  final String name;
  final bool supportsPhotographer;
  final bool supportsVideographer;
  final String? profileImageUrl;
  final bool available;

  CreatorCapability get capability => CreatorCapability(
    crewMemberId: crewMemberId,
    supportsPhotographer: supportsPhotographer,
    supportsVideographer: supportsVideographer,
  );

  factory CreatorMatch.fromJson(Map<String, dynamic> json) {
    // Capability flags are read from explicit role data where present, with a
    // tolerant fallback to a `roles`/`capabilities` string list. Exact field
    // names are unverified (D4) — adjust once fixtures are confirmed.
    bool flag(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v is bool && v) return true;
      }
      final roles = json['roles'] ?? json['capabilities'];
      if (roles is List) {
        final lower = roles.map((e) => e.toString().toLowerCase());
        for (final k in keys) {
          if (lower.contains(k.toLowerCase())) return true;
        }
      }
      return false;
    }

    return CreatorMatch(
      crewMemberId:
          (json['crew_member_id'] ?? json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? json['full_name'] ?? '').toString(),
      supportsPhotographer: flag(['supports_photographer', 'photographer']),
      supportsVideographer: flag(['supports_videographer', 'videographer']),
      profileImageUrl: (json['profile_image'] ?? json['image'])?.toString(),
      available: json['available'] as bool? ?? true,
    );
  }
}

/// A page of creator matches with pagination metadata so callers can
/// deduplicate and request further pages.
@immutable
class CreatorMatchPage {
  const CreatorMatchPage({
    required this.matches,
    required this.page,
    this.hasMore = false,
  });

  final List<CreatorMatch> matches;
  final int page;
  final bool hasMore;

  factory CreatorMatchPage.fromData(Map<String, dynamic> data, {required int page}) {
    final rawList = data['matches'] ?? data['data'] ?? data['creatives'];
    final matches = rawList is List
        ? rawList
              .whereType<Map<String, dynamic>>()
              .map(CreatorMatch.fromJson)
              .toList()
        : <CreatorMatch>[];
    final total = (data['total'] as num?)?.toInt();
    final limit = (data['limit'] as num?)?.toInt();
    final hasMore = data['has_more'] as bool? ??
        (total != null && limit != null ? page * limit < total : matches.isNotEmpty);
    return CreatorMatchPage(matches: matches, page: page, hasMore: hasMore);
  }
}
