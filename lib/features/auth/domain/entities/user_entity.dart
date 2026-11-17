import '../../../../core/session/account_status.dart';

/// Pure domain entity for an authenticated user.
/// No dependencies on any package — only plain Dart.
class UserEntity {
  final AccountStatus accountStatus;
  final String id;
  final String token;
  final int environmentId;
  final String folder;
  final String name;
  final String designation;
  final String department;
  final String departmentId;

  /// User's IANA timezone (e.g. `America/Los_Angeles`) from the login
  /// response `timezone` key. Empty when the server omits it.
  final String timezone;

  const UserEntity({
    this.accountStatus = AccountStatus.active,
    required this.id,
    required this.token,
    required this.environmentId,
    required this.folder,
    required this.name,
    required this.designation,
    required this.department,
    required this.departmentId,
    this.timezone = '',
  });
}
