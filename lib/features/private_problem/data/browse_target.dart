Uri buildBrowseUri(String rawInput) {
  final input = rawInput.trim();
  if (input.isEmpty) return Uri.parse(_searchBase);

  if (_looksLikeLink(input)) {
    final withScheme = input.contains('://') ? input : 'https://$input';
    try {
      return Uri.parse(withScheme);
    } on FormatException {
          }
  }

  return Uri.parse(
    '$_searchBase/search?q=${Uri.encodeComponent(input)}',
  );
}

bool _looksLikeLink(String input) {
  if (input.contains(' ')) return false;

  final lower = input.toLowerCase();
  if (lower.startsWith('http://') || lower.startsWith('https://')) return true;

      return input.contains('.') || input.contains('/');
}

const String _searchBase = 'https://www.google.com';
