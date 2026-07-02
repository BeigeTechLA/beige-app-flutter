/// One row in the create-meeting shoot picker. Carries the bare fields the
/// dropdown needs — id (sent as `order_id` on create) and title (display).
class ShootOption {
  const ShootOption({
    required this.id,
    required this.title,
    this.defaultMembers = const [],
  });

  final int id;
  final String title;
  final List<dynamic> defaultMembers;
}