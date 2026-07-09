/// Maps backend role codes to display labels used across the app (chat
/// bubbles, participant chips, member cards). Unknown roles are title-cased
/// so new codes render readably without code changes.
String roleLabel(String? raw) {
  if (raw == null) return '';
  final r = raw.trim().toLowerCase();
  if (r.isEmpty) return '';
  switch (r) {
    case 'cp':
    case 'creative_partner':
    case 'creativepartner':
      return 'Creative Partner';
    case 'client':
      return 'Client';
    case 'admin':
      return 'Admin';
    case 'sales_rep':
    case 'salesrep':
      return 'Sales Rep';
    case 'pm':
      return 'Production Manager';
    case 'staff':
      return 'Staff';
  }
  final clean = r.replaceAll('_', ' ').replaceAll('-', ' ');
  return clean
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');
}
