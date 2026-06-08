class ClientSnapshot {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImage;
  final String role;

  ClientSnapshot({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImage,
    required this.role,
  });

  factory ClientSnapshot.fromJson(Map<String, dynamic> json) {
    return ClientSnapshot(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profileImage: json['profileImage'],
      role: json['role'] ?? '',
    );
  }
}

class ParticipantModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? profileImage;
  final String? phone;

  ParticipantModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImage,
    this.phone,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      profileImage: json['profileImage'],
      phone: json['phone'],
    );
  }
}

class MessgeListModel {
  final String id;
  final String name;
  final String displayName;
  final String updatedAt;
  final String createdAt;
  final String status;
  final Map<String, dynamic> unreadCounts;
  final ClientSnapshot? clientSnapshot;
  final List<ParticipantModel> cpIds;
  final List<ParticipantModel> managerIds;
  final String? lastMessage;
  final String? orderId;
  final String? externalOrderRef;
  final int chatId;

  MessgeListModel({
    required this.id,
    required this.name,
    required this.displayName,
    required this.updatedAt,
    required this.createdAt,
    required this.status,
    required this.unreadCounts,
    this.clientSnapshot,
    required this.cpIds,
    required this.managerIds,
    this.lastMessage,
    this.orderId,
    this.externalOrderRef,
    required this.chatId,
  });

  factory MessgeListModel.fromJson(Map<String, dynamic> json) {
    return MessgeListModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      displayName: json['display_name'] ?? json['name'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      createdAt: json['createdAt'] ?? '',
      status: json['status'] ?? '',
      unreadCounts: Map<String, dynamic>.from(json['unread_counts'] ?? {}),
      clientSnapshot: json['client_snapshot'] != null
          ? ClientSnapshot.fromJson(json['client_snapshot'])
          : null,
      cpIds: (json['cp_ids'] as List<dynamic>? ?? [])
          .map((e) => ParticipantModel.fromJson(e))
          .toList(),
      managerIds: (json['manager_ids'] as List<dynamic>? ?? [])
          .map((e) => ParticipantModel.fromJson(e))
          .toList(),
      lastMessage: json['last_message'],
      orderId: json['order_id'],
      externalOrderRef: json['external_order_ref'],
      chatId: json['chat_id'] is int
          ? json['chat_id']
          : int.tryParse(json['chat_id']?.toString() ?? '0') ?? 0,
    );
  }

  /// Total unread count across all participants
  int get totalUnreadCount =>
      unreadCounts.values.fold<int>(0, (sum, v) => sum + (int.tryParse(v.toString()) ?? 0));
  /// Display name: prefer display_name, fallback to client name
  String get resolvedDisplayName =>
      displayName.isNotEmpty ? displayName : (clientSnapshot?.name ?? name);
}