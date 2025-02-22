class RequestEntity {
  final String nameFile;
  final bool isSign;
  final DateTime? dateSign;
  final String urlFile;

  RequestEntity({
    required this.nameFile,
    required this.isSign,
    this.dateSign,
    required this.urlFile,
  });
}
