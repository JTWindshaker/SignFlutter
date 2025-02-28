import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:intl/intl.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:sign/core/theme/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sign/features/requests/domain/usecases/delete_request_usecase.dart';
import 'package:sign/features/requests/data/repositories/request_repository_impl.dart';
import 'package:sign/features/requests/data/datasources/local/requests_local_datasource.dart';
import 'package:sign/features/requests/domain/entities/request_entity.dart';

class PDFPreviewCard extends StatelessWidget {
  final RequestEntity request;
  final VoidCallback onRequestDeleted;

  const PDFPreviewCard({
    super.key,
    required this.request,
    required this.onRequestDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Vista previa del PDF
          Container(
            width: 90,
            height: 120,
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: PDFView(
                filePath: request.urlFile,
                enableSwipe: false,
                swipeHorizontal: false,
                autoSpacing: false,
                pageFling: false,
                onRender: (pages) {},
                onError:
                    (error) => const Center(
                      child: Icon(Icons.error, color: Colors.red),
                    ),
                onPageChanged: (page, total) {},
              ),
            ),
          ),
          // Contenido de la tarjeta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Nombre del archivo
                    Expanded(
                      child: Text(
                        request.nameFile,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Icono de firmado si tiene fecha de firma
                    if (request.dateSign != null)
                      Icon(
                        MaterialCommunityIcons.check_decagram,
                        color: AppColors.secondary,
                      ),
                  ],
                ),
                // Estado (Borrador o Fecha de firma)
                Text(
                  request.dateSign != null
                      ? "Firmado: ${_toTitleCase(DateFormat('dd MMM yyyy HH:mm', 'es').format(request.dateSign!.toLocal()))}"
                      : "Borrador",
                  style: TextStyle(
                    fontStyle:
                        request.dateSign == null
                            ? FontStyle.italic
                            : FontStyle.normal,
                    color: Colors.grey[700],
                  ),
                ),
                // Botones de eliminar y compartir
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, request.id!),
                    ),
                    IconButton(
                      icon: Icon(Icons.share, color: AppColors.primary),
                      onPressed:
                          () => _sharePDF(
                            filePath: request.urlFile,
                            text: "Mira este PDF: ${request.nameFile}",
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _toTitleCase(String text) {
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  void _sharePDF({required String filePath, required String text}) async {
    final result = await Share.shareXFiles(
      [XFile(filePath)],
      text: text,
      subject: text,
    );

    if (result.status == ShareResultStatus.success) {
      print('Correcto');
    }

    if (result.status == ShareResultStatus.dismissed) {
      print('No Compartió');
    }
  }

  /// Muestra un diálogo de confirmación antes de eliminar la solicitud
  void _confirmDelete(BuildContext context, int idRequest) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Eliminar Solicitud"),
            content: const Text(
              "¿Estás seguro de que quieres eliminar este documento?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () async {
                  await _deleteRequest(idRequest);
                  onRequestDeleted();
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 10),
                          Text("Archivo eliminado correctamente"),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
                child: const Text(
                  "Eliminar",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  /// Elimina la solicitud de la base de datos

  Future<void> _deleteRequest(int idRequest) async {
    DeleteRequestUseCase(RequestRepositoryImpl(RequestLocalDatasource()))(
      idRequest,
    );

    print("Solicitud eliminada: ${request.nameFile}");
  }
}
