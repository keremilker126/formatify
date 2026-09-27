// lib/views/home_view.dart

import 'package:flutter/material.dart';
import '../models/document_model.dart';
import '../services/document_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final DocumentService _documentService = DocumentService();
  DocumentModel? _selectedDocument;
  bool _isLoading = false;
  String? _savedFilePath; // Kaydedilen dosyanın yolunu tutmak için

  void _pickFile() async {
    setState(() {
      _isLoading = true;
      _savedFilePath = null; // Yeni dosya seçildiğinde eski yolu sıfırla
    });

    DocumentModel? doc = await _documentService.pickDocument();
    
    setState(() {
      _selectedDocument = doc;
      _isLoading = false;
    });
  }

  void _startFormatting() async {
    if (_selectedDocument == null) return;

    setState(() => _isLoading = true);
    
    // Belgeyi formatla ve cihaza kaydet
    String? path = await _documentService.formatAndSaveDocument(_selectedDocument!);
    
    setState(() {
      _isLoading = false;
      _savedFilePath = path;
    });

    if (path != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belge başarıyla formatlandı ve kaydedildi!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _resetSelection() {
    setState(() {
      _selectedDocument = null;
      _savedFilePath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formatify - Belge Dönüştürücü'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_selectedDocument == null) ...[
                  // Dosya Seçim Alanı
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.cloud_upload_outlined, size: 80, color: Colors.blue),
                        const SizedBox(height: 16),
                        const Text(
                          'Formatlamak istediğiniz belgeyi yükleyin',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Desteklenen formatlar: PDF, DOC, DOCX, TXT, MD',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _pickFile,
                          icon: const Icon(Icons.folder_open),
                          label: const Text('Dosya Seç'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Seçilen Belge Detayları ve Dönüştürme Ayarları
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.insert_drive_file, size: 48, color: Colors.blue),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedDocument!.name,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Boyut: ${(_selectedDocument!.sizeBytes / 1024).toStringAsFixed(2)} KB',
                                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: _isLoading ? null : _resetSelection,
                                tooltip: 'Dosyayı Değiştir',
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          const Text(
                            'Hedef Formatı Seçin:',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<TargetFormat>(
                            value: _selectedDocument!.targetFormat,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            items: TargetFormat.values.map((format) {
                              return DropdownMenuItem(
                                value: format,
                                child: Text(format.name.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: _isLoading
                                ? null
                                : (val) {
                                    setState(() {
                                      if (val != null) _selectedDocument!.targetFormat = val;
                                    });
                                  },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _startFormatting,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    'Formatlamayı Başlat',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),

                          // Dönüştürme bittikten sonra görünen "Dosyayı Aç" butonu
                          if (_savedFilePath != null) ...[
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _documentService.openSavedDocument(_savedFilePath!),
                              icon: const Icon(Icons.open_in_new),
                              label: const Text('Kaydedilen Dosyayı Aç'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}