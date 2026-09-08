/// Parses AppShelf share/deep-link URLs:
/// - https://host/apps/{slug}
/// - appshelf://apps/{slug}
String? parseAppSlugFromUrl(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final input = raw.trim();
  if (input.startsWith('appshelf://')) {
    final path = input.replaceFirst('appshelf://', '');
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    final appsIdx = segments.indexOf('apps');
    if (appsIdx >= 0 && appsIdx + 1 < segments.length) {
      return segments[appsIdx + 1];
    }
    if (segments.isNotEmpty) return segments.last;
    return null;
  }
  final uri = Uri.tryParse(input);
  if (uri == null) return null;
  final segments = uri.pathSegments;
  final appsIdx = segments.indexOf('apps');
  if (appsIdx >= 0 && appsIdx + 1 < segments.length) {
    final slug = segments[appsIdx + 1];
    if (slug.isNotEmpty) return slug;
  }
  return null;
}
