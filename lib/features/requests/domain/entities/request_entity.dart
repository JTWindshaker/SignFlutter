class RequestEntity {
  final int? id;
  final String nameFile;
  final bool isSign;
  final DateTime? dateSign;
  final String urlFile;

  RequestEntity({
    this.id,
    required this.nameFile,
    required this.isSign,
    this.dateSign,
    required this.urlFile,
  });
}
