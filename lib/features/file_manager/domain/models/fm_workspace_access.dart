class FmWorkspaceClient {
  const FmWorkspaceClient({
    required this.email,
    this.name,
    this.accessId,
    this.pending = false,
  });
  final String email;
  final String? name;
  final int? accessId;
  final bool pending;

  factory FmWorkspaceClient.fromJson(Map<String, dynamic> json) =>
      FmWorkspaceClient(
        email: json['email'] as String,
        name: json['name'] as String?,
        accessId: (json['accessId'] as num?)?.toInt(),
        pending: json['pending'] as bool? ?? false,
      );
}

class FmWorkspaceAccess {
  const FmWorkspaceAccess({required this.owner, required this.clients});
  final FmWorkspaceClient owner;
  final List<FmWorkspaceClient> clients;
}

class FmWorkspaceGrant {
  const FmWorkspaceGrant({
    required this.client,
    required this.message,
    required this.emailSent,
  });
  final FmWorkspaceClient client;
  final String message;
  final bool emailSent;
}
