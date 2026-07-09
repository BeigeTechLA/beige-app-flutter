/// Pure domain entity for an authenticated user.
/// No dependencies on any package — only plain Dart.
class UserEntity {
  final String id;
  final String token;
  final int environmentId;
  final String folder;
  final String name;
  final String designation;
  final String department;
  final String departmentId;

  const UserEntity({
    required this.id,
    required this.token,
    required this.environmentId,
    required this.folder,
    required this.name,
    required this.designation,
    required this.department,
    required this.departmentId,
  });
}
