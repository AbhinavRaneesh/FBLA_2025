import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFProcessingScreen extends StatefulWidget {
  final String username;

  const PDFProcessingScreen({
    super.key,
    required this.username,
  });

  @override
  State<PDFProcessingScreen> createState() => _PDFProcessingScreenState();
}

class _PDFProcessingScreenState extends State<PDFProcessingScreen> {
  final TextEditingController _urlController = TextEditingController();
  String? _pdfUrl;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPdfLoading = false;

  // Validate if the URL is a proper PDF URL
  bool _isValidPdfUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && 
             (uri.scheme == 'http' || uri.scheme == 'https') &&
             (url.toLowerCase().endsWith('.pdf') || 
              url.toLowerCase().contains('.pdf') ||
              url.toLowerCase().contains('pdf'));
    } catch (e) {
      return false;
    }
  }

  Future<void> _loadPDF() async {
    if (_urlController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a PDF URL';
      });
      return;
    }

    final url = _urlController.text.trim();
    
    if (!_isValidPdfUrl(url)) {
      setState(() {
        _errorMessage = 'Please enter a valid PDF URL (must start with http/https)';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isPdfLoading = false;
      _pdfUrl = null; // Clear previous PDF
    });

    try {
      // Try to download the PDF content first to check CORS and validity
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 15),
      );
      
      if (response.statusCode == 200) {
        // Check if it's actually a PDF file by checking content
        final contentType = response.headers['content-type'];
        final bodyBytes = response.bodyBytes;
        
        // Check PDF magic number (PDF files start with %PDF)
        if (bodyBytes.length < 4 || 
            String.fromCharCodes(bodyBytes.take(4)) != '%PDF') {
          if (mounted) {
            setState(() {
              _errorMessage = 'URL does not point to a valid PDF file.';
            });
          }
          return;
        }
        
        // If we got here, the PDF is accessible and valid
        if (mounted) {
          setState(() {
            _pdfUrl = url;
            _isPdfLoading = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to access PDF (HTTP ${response.statusCode}). '
                'The server may not allow direct access to this PDF.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (e.toString().contains('TimeoutException')) {
            _errorMessage = 'Request timed out. The PDF may be too large or the server is slow.';
          } else if (e.toString().contains('SocketException')) {
            _errorMessage = 'Network error. Please check your internet connection.';
          } else if (e.toString().contains('FormatException')) {
            _errorMessage = 'Invalid URL format. Please enter a valid URL.';
          } else if (e.toString().toLowerCase().contains('cors') || 
                     e.toString().toLowerCase().contains('cross-origin')) {
            _errorMessage = 'CORS error: The server hosting this PDF doesn\'t allow cross-origin requests. '
                'Try using a different PDF URL or contact the server administrator.';
          } else {
            _errorMessage = 'Failed to access PDF: ${e.toString()}. '
                'This might be due to CORS restrictions or server security settings.';
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearPdf() {
    setState(() {
      _pdfUrl = null;
      _errorMessage = null;
      _isPdfLoading = false;
      _urlController.clear();
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
        backgroundColor: Colors.blue,
        actions: [
          if (_pdfUrl != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearPdf,
              tooltip: 'Clear PDF',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _urlController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Enter PDF URL',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: 'https://example.com/document.pdf',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.blueAccent,
                  ),
                ),
                suffixIcon: _urlController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () {
                          _urlController.clear();
                          setState(() {
                            _errorMessage = null;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _errorMessage = null;
                });
              },
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _loadPDF(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _loadPDF,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Load PDF',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                    if (_errorMessage!.toLowerCase().contains('cors')) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Try these working PDF URLs instead:',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '• https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf\n'
                        '• https://mozilla.github.io/pdf.js/web/compressed.tracemonkey-pldi-09.pdf',
                        style: TextStyle(color: Colors.blue, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (_pdfUrl != null && _errorMessage == null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'PDF loaded successfully',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        SfPdfViewer.network(
                          _pdfUrl!,
                          enableDoubleTapZooming: true,
                          enableTextSelection: true,
                          canShowScrollHead: true,
                          canShowScrollStatus: true,
                          enableDocumentLinkAnnotation: true,
                          pageSpacing: 4,
                          pageLayoutMode: PdfPageLayoutMode.single,
                          onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                            if (mounted) {
                              setState(() {
                                _errorMessage = 'PDF loading failed: ${details.error}. '
                                    'This might be due to CORS restrictions or the PDF being password protected.';
                                _isPdfLoading = false;
                                _pdfUrl = null;
                              });
                            }
                          },
                          onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                            if (mounted) {
                              setState(() {
                                _isPdfLoading = false;
                              });
                            }
                          },
                        ),
                        if (_isPdfLoading)
                          Container(
                            color: Colors.black.withOpacity(0.3),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(color: Colors.blue),
                                  SizedBox(height: 16),
                                  Text(
                                    'Loading PDF...',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}