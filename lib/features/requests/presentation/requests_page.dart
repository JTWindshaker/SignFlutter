import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:sign/core/theme/app_colors.dart';
import 'package:sign/core/utils/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sign/features/requests/data/datasources/local/requests_local_datasource.dart';
import 'package:sign/features/requests/data/repositories/request_repository_impl.dart';
import 'package:sign/features/requests/domain/entities/request_entity.dart';
import 'package:sign/features/requests/domain/usecases/get_requests_usecase.dart';
import 'package:sign/features/requests/domain/usecases/save_request_usecase.dart';
import 'package:sign/features/requests/presentation/pdf_preview_card.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  bool isMenuOpen = false;
  late Future<List<RequestEntity>> requestsFuture;

  @override
  void initState() {
    super.initState();
    requestsFuture = fetchRequests();
  }

  void toggleMenu() {
    setState(() {
      isMenuOpen = !isMenuOpen;
    });
  }

  void showAlert(String buttonName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(buttonName),
            content: const Text('Has presionado el botón'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<List<RequestEntity>> fetchRequests() async {
    return await GetRequestsUseCase(
      RequestRepositoryImpl(RequestLocalDatasource()),
    )();
  }

  Future<void> pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      String fileName = result.files.single.name;

      // Guardar en base de datos
      final bool flag = Random().nextBool();
      RequestEntity newRequest = RequestEntity(
        nameFile: fileName,
        isSign: flag,
        dateSign: flag ? DateTime.now() : null,
        urlFile: filePath,
      );

      await SaveRequestUseCase(RequestRepositoryImpl(RequestLocalDatasource()))(
        newRequest,
      );

      // Recargar la lista después de guardar el archivo
      setState(() {
        requestsFuture = fetchRequests();
      });
    } else {
      //Selección cancelada.
    }
  }

  Future<void> scanPDF() async {
    try {
      // 1. Escanear el documento y obtener la ruta del PDF
      dynamic scannedPdf = await FlutterDocScanner().getScannedDocumentAsPdf();

      if (scannedPdf is Map && scannedPdf.containsKey('pdfUri')) {
        String filePath =
            Uri.parse(scannedPdf['pdfUri']).toFilePath(); // Extraer ruta real
        String fileName =
            filePath.split('/').last; // Obtener solo el nombre del archivo

        // 2. Generar los datos de la solicitud
        final bool flag = Random().nextBool();
        RequestEntity newRequest = RequestEntity(
          nameFile: fileName,
          isSign: flag,
          dateSign: flag ? DateTime.now() : null,
          urlFile: filePath, // Guardamos la ruta del PDF
        );

        // 3. Guardar la solicitud en la base de datos
        await SaveRequestUseCase(
          RequestRepositoryImpl(RequestLocalDatasource()),
        )(newRequest);

        // 4. Actualizar la lista de solicitudes
        setState(() {
          requestsFuture = fetchRequests();
        });

        print("Documento guardado en: $filePath");
      } else {
        print("No se pudo obtener el PDF.");
      }
    } on PlatformException catch (e) {
      print("Error al escanear el documento: $e");
    } catch (e) {
      print("Error inesperado: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60.0,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/images/logo.png", width: 45.0),
            SizedBox(width: 20),
            Text(AppConstants.appName, style: TextStyle(fontSize: 24.0)),
          ],
        ),
      ),
      body: FutureBuilder<List<RequestEntity>>(
        future: requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Error al cargar las solicitudes."),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No hay solicitudes.',
                style: TextStyle(fontSize: 18),
              ),
            );
          } else {
            List<RequestEntity> requests = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return PDFPreviewCard(
                  request: request,
                  onRequestDeleted: () async {
                    setState(() {
                      requestsFuture = fetchRequests();
                    });
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: SizedBox(
        width: 200,
        height: 200,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            // Cargar Documento
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: isMenuOpen ? 1 : 0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutQuad,
              builder: (context, double value, child) {
                return Positioned(
                  right: 120 * value * cos((0 * 45) * pi / 180),
                  bottom: 120 * value * sin((0 * 45) * pi / 180),
                  child: Opacity(
                    opacity: value,
                    child: Transform.rotate(
                      angle: (1 - value) * pi / 2,
                      child: SizedBox(
                        width: 50.0,
                        height: 50.0,
                        child: FloatingActionButton(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          onPressed: () => pickPDF(),
                          child: Icon(
                            MaterialCommunityIcons.file_document_edit,
                            size: 25.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Cargar Imagenes
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: isMenuOpen ? 1 : 0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutQuad,
              builder: (context, double value, child) {
                return Positioned(
                  right: 120 * value * cos((1 * 45) * pi / 180),
                  bottom: 120 * value * sin((1 * 45) * pi / 180),
                  child: Opacity(
                    opacity: value,
                    child: Transform.rotate(
                      angle: (1 - value) * pi / 2,
                      child: SizedBox(
                        width: 50.0,
                        height: 50.0,
                        child: FloatingActionButton(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          onPressed: () => showAlert("Botón ${1 + 1}"),
                          child: Icon(MaterialCommunityIcons.image, size: 25.0),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Escanear y generar PDF
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: isMenuOpen ? 1 : 0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutQuad,
              builder: (context, double value, child) {
                return Positioned(
                  right: 120 * value * cos((2 * 45) * pi / 180),
                  bottom: 120 * value * sin((2 * 45) * pi / 180),
                  child: Opacity(
                    opacity: value,
                    child: Transform.rotate(
                      angle: (1 - value) * pi / 2,
                      child: SizedBox(
                        width: 50.0,
                        height: 50.0,
                        child: FloatingActionButton(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          onPressed: () => scanPDF(),
                          child: Icon(
                            MaterialCommunityIcons.camera,
                            size: 25.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            FloatingActionButton(
              mini: isMenuOpen,
              backgroundColor: isMenuOpen ? Colors.white : AppColors.primary,
              foregroundColor: isMenuOpen ? AppColors.primary : Colors.white,
              onPressed: toggleMenu,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isMenuOpen ? 56.0 : 16.0),
              ),
              child: Icon(isMenuOpen ? Icons.close : Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
