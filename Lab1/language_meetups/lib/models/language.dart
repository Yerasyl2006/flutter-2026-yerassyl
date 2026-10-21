enum Language {
  english('English', 'EN'),
  korean('Korean', 'KO'),
  japanese('Japanese', 'JA'),
  german('German', 'DE'),
  spanish('Spanish', 'ES'),
  chinese('Chinese', 'ZH');

  const Language(this.label, this.code);
  final String label;
  final String code;
}
