import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class PdfViewerScreen extends StatefulWidget {
  final String filePath;
  final String fileName;

  const PdfViewerScreen({
    Key? key,
    required this.filePath,
    required this.fileName,
  }) : super(key: key);

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  bool _isLoading = true;
  String? _localPath;
  String? _error;
  int? _totalPages;
  int _currentPage = 0;
  bool pdfReady = false;
  PDFViewController? _pdfViewController;

  @override
  void initState() {
    super.initState();
    print('[PdfViewer] initState with path: ${widget.filePath}');
    _loadPdf();
  }

  Future<void> _shareFile() async {
    try {
      if (kIsWeb) return;
      final sourcePath = _localPath ?? widget.filePath;
      final srcFile = File(sourcePath);
      if (!await srcFile.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File tidak ditemukan untuk dibagikan'),
            ),
          );
        }
        return;
      }

      final name = widget.fileName.toLowerCase().endsWith('.pdf')
          ? widget.fileName
          : '${widget.fileName}.pdf';

      await Share.shareXFiles([
        XFile(sourcePath, name: name, mimeType: 'application/pdf'),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal membagikan: $e')));
      }
    }
  }

  Future<void> _saveToDevice() async {
    try {
      if (kIsWeb) return;
      final sourcePath = _localPath ?? widget.filePath;
      final srcFile = File(sourcePath);
      if (!await srcFile.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File sumber tidak ditemukan')),
          );
        }
        return;
      }

      Directory? dir;
      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        dir = await getApplicationDocumentsDirectory();
      }
      dir ??= await getApplicationDocumentsDirectory();

      final name = widget.fileName.toLowerCase().endsWith('.pdf')
          ? widget.fileName
          : '${widget.fileName}.pdf';
      final dstPath = '${dir.path}/$name';
      await srcFile.copy(dstPath);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Tersimpan di: $dstPath')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    }
  }

  Future<void> _loadPdf() async {
    try {
      print('[PdfViewer] Loading PDF from: ${widget.filePath}');

      // Check if file exists
      final file = File(widget.filePath);
      final exists = await file.exists();

      print('[PdfViewer] File exists: $exists');

      if (!exists) {
        setState(() {
          _error = 'File tidak ditemukan';
          _isLoading = false;
        });
        return;
      }

      final length = await file.length();
      print('[PdfViewer] File size: $length bytes');

      if (length == 0) {
        setState(() {
          _error = 'File kosong';
          _isLoading = false;
        });
        return;
      }

      final bytes = await file.readAsBytes();
      if (bytes.length < 5) {
        setState(() {
          _error = 'File terlalu kecil untuk menjadi PDF';
          _isLoading = false;
        });
        return;
      }

      if (!(bytes[0] == 0x25 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x44 &&
          bytes[3] == 0x46)) {
        print(
          '[PdfViewer] Warning: Invalid PDF signature. First bytes: ${bytes.take(10).toList()}',
        );
      }

      setState(() {
        _localPath = widget.filePath;
        _isLoading = false;
      });

      print('[PdfViewer] PDF loaded successfully');
    } catch (e, stackTrace) {
      print('[PdfViewer] Error loading PDF: $e');
      print('[PdfViewer] StackTrace: $stackTrace');

      setState(() {
        _error = 'Gagal memuat PDF: ${e.toString()}';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat PDF: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Share / Save to Files',
              onPressed: _shareFile,
            ),
          if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'Download',
              onPressed: _saveToDevice,
            ),
          if (_totalPages != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  '${_currentPage + 1}/$_totalPages',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat PDF...'),
                ],
              ),
            )
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _error = null;
                        });
                        _loadPdf();
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            )
          : _localPath != null
          ? PDFView(
              filePath: _localPath!,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
              pageSnap: true,
              onRender: (pages) {
                print('[PdfViewer] PDF rendered with $pages pages');
                setState(() {
                  _totalPages = pages;
                  pdfReady = true;
                });
              },
              onError: (error) {
                print('[PdfViewer] PDFView error: $error');
                setState(() {
                  _error = 'Error menampilkan PDF: $error';
                });
              },
              onPageError: (page, error) {
                print('[PdfViewer] Page $page error: $error');
              },
              onViewCreated: (PDFViewController pdfViewController) {
                print('[PdfViewer] PDFView created');
                _pdfViewController = pdfViewController;
              },
              onPageChanged: (int? page, int? total) {
                print('[PdfViewer] Page changed to $page/$total');
                setState(() {
                  _currentPage = page ?? 0;
                });
              },
            )
          : const Center(child: Text('Tidak dapat memuat PDF')),
      floatingActionButton: _totalPages != null && _totalPages! > 1
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'prev',
                  onPressed: _currentPage > 0
                      ? () {
                          _pdfViewController?.setPage(_currentPage - 1);
                        }
                      : null,
                  backgroundColor: _currentPage > 0 ? null : Colors.grey,
                  child: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  heroTag: 'next',
                  onPressed: _currentPage < _totalPages! - 1
                      ? () {
                          _pdfViewController?.setPage(_currentPage + 1);
                        }
                      : null,
                  backgroundColor: _currentPage < _totalPages! - 1
                      ? null
                      : Colors.grey,
                  child: const Icon(Icons.arrow_forward),
                ),
              ],
            )
          : null,
    );
  }
}
