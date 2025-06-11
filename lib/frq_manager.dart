import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';

class FRQManager extends StatelessWidget {
  const FRQManager({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AP FRQs'),
        backgroundColor: const Color(0xFF1D1E33),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1D1E33), Color(0xFF2A2B4A)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSubjectSection(
                context,
                'AP Computer Science',
                [
                  {'year': '2025', 'title': 'AP Computer Science 2025', 'file': 'assets/apfrq/ap25-frq-computer-science-a.pdf'},
                  {'year': '2024', 'title': 'AP Computer Science 2024', 'file': 'assets/apfrq/ap24-frq-comp-sci-a.pdf'},
                  {'year': '2023', 'title': 'AP Computer Science 2023', 'file': 'assets/apfrq/ap23-frq-comp-sci-a.pdf'},
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectSection(BuildContext context, String subject, List<Map<String, String>> years) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subject,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...years.map((year) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildYearButton(context, year['title']!, year['year']!, year['file']),
            )),
      ],
    );
  }

  Widget _buildYearButton(BuildContext context, String title, String year, [String? file]) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.blue],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openPDF(context, year, file),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openPDF(BuildContext context, String year, [String? file]) async {
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF file not available for this year'),
          backgroundColor: Colors.red,
        ),
      );
      print('No file provided for year $year');
      return;
    }
    print('Attempting to open PDF: $file');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(filePath: file, year: year),
      ),
    );
  }
}

class PDFViewerScreen extends StatefulWidget {
  final String filePath;
  final String year;
  const PDFViewerScreen({super.key, required this.filePath, required this.year});

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  bool _loading = true;
  bool _error = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AP FRQ ${widget.year}'),
        backgroundColor: const Color(0xFF1D1E33),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Visibility(
            visible: !_error,
            child: SfPdfViewer.asset(
              widget.filePath,
              canShowPaginationDialog: true,
              canShowScrollHead: true,
              enableDoubleTapZooming: true,
              onDocumentLoaded: (details) {
                setState(() {
                  _loading = false;
                });
                print('PDF loaded: ${widget.filePath}');
              },
              onDocumentLoadFailed: (details) {
                setState(() {
                  _loading = false;
                  _error = true;
                });
                print('Failed to load PDF: ${widget.filePath}');
              },
            ),
          ),
          if (_loading)
            const Center(child: CircularProgressIndicator()),
          if (_error)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load PDF file:\n${widget.filePath}',
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
} 