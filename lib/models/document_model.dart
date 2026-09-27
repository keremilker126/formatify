// lib/models/document_model.dart

enum TargetFormat { pdf, docx, txt, md }

class DocumentModel {
  final String id;
  final String name;
  final int sizeBytes;
  final dynamic fileBytes; // Web için byte verisi, mobil/masaüstü için dosya verisi
  TargetFormat targetFormat;

  DocumentModel({
    required this.id,
    required this.name,
    required this.sizeBytes,
    required this.fileBytes,
    this.targetFormat = TargetFormat.pdf,
  });
}