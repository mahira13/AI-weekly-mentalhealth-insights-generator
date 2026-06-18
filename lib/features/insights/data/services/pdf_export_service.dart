import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../journal/domain/entities/journal_entry.dart';

class PdfExportService {
  const PdfExportService();

  Future<void> generateAndShare({
    required String dateRange,
    required String narrative,
    required List<String> anchors,
    required List<JournalEntry> timelineEntries,
  }) async {
    final regularFont = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();
    final document = pw.Document();
    final sortedEntries = [...timelineEntries]
      ..sort((left, right) => left.date.compareTo(right.date));
    final bulletAnchors = anchors
        .map((anchor) => anchor.trim())
        .where((anchor) => anchor.isNotEmpty)
        .toList(growable: false);

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: regularFont,
          bold: boldFont,
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            'Generated privately on your device',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
        ),
        build: (context) => [
          pw.Text(
            dateRange,
            style: pw.TextStyle(
              fontSize: 22,
              font: boldFont,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 20),
          _sectionTitle('AI narrative'),
          pw.Text(
            narrative.trim(),
            style: const pw.TextStyle(fontSize: 12, lineSpacing: 4),
          ),
          pw.SizedBox(height: 18),
          _sectionTitle('Anchors'),
          if (bulletAnchors.isEmpty)
            pw.Text(
              'No anchors available.',
              style: const pw.TextStyle(fontSize: 12),
            )
          else
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: bulletAnchors
                  .map(
                    (anchor) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 6),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            '• ',
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              anchor,
                              style: const pw.TextStyle(
                                fontSize: 12,
                                lineSpacing: 3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          pw.SizedBox(height: 18),
          _sectionTitle('Timeline data'),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(
              fontSize: 11,
              font: boldFont,
              fontWeight: pw.FontWeight.bold,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.grey300,
            ),
            cellStyle: const pw.TextStyle(fontSize: 11),
            cellAlignment: pw.Alignment.centerLeft,
            headers: const ['Date', 'Stress', 'Sleep', 'Mood'],
            data: sortedEntries
                .map(
                  (entry) => [
                    DateFormat('MMM d, yyyy').format(entry.date),
                    _formatMetric(entry.stressLevel),
                    _formatMetric(entry.sleepQuality),
                    _formatMetric(entry.negativeSymptom),
                  ],
                )
                .toList(growable: false),
          ),
        ],
      ),
    );

    final bytes = await document.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: _filenameFor(dateRange, bytes),
    );
  }

  pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 15,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  String _formatMetric(double value) {
    final rounded = value.toStringAsFixed(1);
    return rounded.endsWith('.0')
        ? rounded.substring(0, rounded.length - 2)
        : rounded;
  }

  String _filenameFor(String dateRange, Uint8List bytes) {
    final sanitized = dateRange
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    final suffix = sanitized.isEmpty ? bytes.length.toString() : sanitized;
    return 'weekly-insights-$suffix.pdf';
  }
}
