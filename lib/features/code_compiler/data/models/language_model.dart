class LanguageModel {
  final String displayName;
  final String compilerId;
  final String fileExtension;
  final String boilerplate;

  const LanguageModel({
    required this.displayName,
    required this.compilerId,
    required this.fileExtension,
    required this.boilerplate,
  });
}
