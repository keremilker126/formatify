// lib/services/document_service.dart

import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:open_file/open_file.dart';
import '../models/document_model.dart';

class DocumentService {
  // Belge seçme
  Future<DocumentModel?> pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'md'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      final file = result.files.single;
      return DocumentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: file.name,
        sizeBytes: file.size,
        fileBytes: file.bytes,
      );
    }
    return null;
  }

  // Belgeyi formatlama ve kaydetme
  Future<String?> formatAndSaveDocument(DocumentModel document) async {
    // İşlem simülasyonu (2 saniye bekleme)
    await Future.delayed(const Duration(seconds: 2));

    List<int> processedBytes = document.fileBytes;
    String extension = document.targetFormat.name;
    String baseName = document.name.split('.').first;

    try {
      // Dosyayı platforma uygun şekilde kaydeder
      String? savedPath = await FileSaver.instance.saveFile(
        name: '${baseName}_formatted',
        bytes: Uint8List.fromList(processedBytes),
        fileExtension: extension,
        mimeType: _getMimeType(extension),
      );

      return savedPath; // Kaydedilen dosyanın yolunu döner
    } catch (e) {
      return null;
    }
  }

  // Kaydedilen dosyayı açma
  Future<void> openSavedDocument(String path) async {
    await OpenFile.open(path);
  }

  MimeType _getMimeType(String ext) {
    switch (ext) {
      case 'pdf':
        return MimeType.pdf;
      case 'txt':
        return MimeType.text;
      case 'docx':
      case 'doc':
        return MimeType.microsoftWord;
      default:
        return MimeType.other;
    }
  }
}