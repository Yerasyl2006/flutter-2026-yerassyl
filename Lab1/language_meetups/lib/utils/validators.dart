String? validateTitle(String? v) {
  final s = (v ?? '').trim();
  if (s.isEmpty) return 'Enter a title';
  if (s.length < 3) return 'At least 3 characters';
  if (s.length > 60) return 'At most 60 characters';
  return null;
}

String? validatePlace(String? v, {required bool online}) {
  final s = (v ?? '').trim();
  if (s.isEmpty) return online ? 'Enter a link' : 'Enter a place';
  if (online && !s.startsWith('http')) return 'Link must start with http';
  return null;
}

String? validateCapacity(String? v, {int min = 2}) {
  final n = int.tryParse((v ?? '').trim());
  if (n == null) return 'Enter a number';
  if (n < min) return 'Minimum is $min';
  if (n > 100) return 'Maximum is 100';
  return null;
}

String? validateTopic(String? v) =>
    (v ?? '').length > 200 ? 'At most 200 characters' : null;

String? validateName(String? v) =>
    (v ?? '').trim().length < 2 ? 'Enter your name (2+ characters)' : null;
