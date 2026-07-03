import 'package:flutter/foundation.dart';

@immutable
class DirectoryParticipant {
  final String id;
  final String name;
  final String? email;
  final String? role;
  final String type; // 'client' | 'staff' | 'creativePartner'
  final String? avatarUrl;
  final bool isDefault;
  final bool isOptional;
  final bool isSelected;

  const DirectoryParticipant({
    required this.id,
    required this.name,
    this.email,
    this.role,
    required this.type,
    this.avatarUrl,
    this.isDefault = false,
    this.isOptional = true,
    this.isSelected = false,
  });

  factory DirectoryParticipant.fromJson(Map<String, dynamic> json, {bool isDefault = false}) {
    final id = (json['id'] ?? json['user_id'] ?? json['_id'] ?? json['member_id'])?.toString() ?? '';
    
    String name = '';
    final direct = (json['name'] as String?)?.trim();
    if (direct != null && direct.isNotEmpty) {
      name = direct;
    } else {
      final full = (json['full_name'] as String?)?.trim();
      if (full != null && full.isNotEmpty) {
        name = full;
      } else {
        final display = (json['display_name'] as String?)?.trim();
        if (display != null && display.isNotEmpty) {
          name = display;
        } else {
          final first = (json['first_name'] as String?)?.trim() ?? '';
          final last = (json['last_name'] as String?)?.trim() ?? '';
          name = ('$first $last').trim();
        }
      }
    }

    final email = json['email'] as String?;
    // Default members (from a shoot's `default_members[]`) only carry
    // `member_type` — ignore `role`/`user_role` even when present so the
    // meeting-create picker classifies them by the intended field.
    final role = isDefault
        ? ((json['member_type'] as String?) ?? '')
        : ((json['role'] as String?) ??
            (json['user_role'] as String?) ??
            (json['member_type'] as String?) ??
            '');
    final avatarUrl = (json['profile_image_url'] as String?) ??
        (json['avatar_url'] as String?) ??
        (json['profile_image'] as String?) ??
        (json['avatar'] as String?) ??
        (json['profileImage'] as String?);

    final roleLower = role.toLowerCase();
    final String type;
    final bool roleImpliedOptional;
    if (roleLower == 'client') {
      type = 'client';
      roleImpliedOptional = false;
    } else if (roleLower == 'cp' || roleLower == 'creative_partner' || roleLower == 'creativepartner') {
      type = 'creativePartner';
      roleImpliedOptional = true;
    } else {
      type = 'staff';
      roleImpliedOptional = true;
    }
    final rawIsOptional = json['is_optional'] ?? json['isOptional'];
    final bool isOptional = rawIsOptional is bool
        ? rawIsOptional
        : roleImpliedOptional;

    return DirectoryParticipant(
      id: id,
      name: name,
      email: email,
      role: role,
      type: type,
      avatarUrl: avatarUrl,
      isDefault: isDefault,
      isOptional: isOptional,
      isSelected: !isOptional,
    );
  }

  DirectoryParticipant copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? type,
    String? avatarUrl,
    bool? isDefault,
    bool? isOptional,
    bool? isSelected,
  }) {
    return DirectoryParticipant(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      type: type ?? this.type,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isDefault: isDefault ?? this.isDefault,
      isOptional: isOptional ?? this.isOptional,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DirectoryParticipant && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
