import '../network/api_endpoints.dart';

/// Builds a complete image URL from a raw path string.
///
/// Automatically handles:
/// - `null` or empty path values (returns `''`).
/// - Full HTTP/HTTPS URLs (returns path as-is without prepending base URL).
/// - Relative image paths (prepends `ApiEndpoints.imageUrl`).
/// - Cache busting token via `?v=<bust>` parameter.
String buildImageUrl(String? path, {int bust = 0}) {
  if (path == null || path.trim().isEmpty) return '';
  final trimmedPath = path.trim();
  final String fullUrl =
      (trimmedPath.startsWith('http://') || trimmedPath.startsWith('https://'))
          ? trimmedPath
          : '${ApiEndpoints.imageUrl}$trimmedPath';
  return bust > 0 ? '$fullUrl?v=$bust' : fullUrl;
}
