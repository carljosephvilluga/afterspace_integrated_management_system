import 'dart:math' as math;

import 'package:aims/services/aims_api_client.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class SalesReportPdfExporter {
  SalesReportPdfExporter._();

  static const List<_SalesRangeDescriptor> _ranges = [
    _SalesRangeDescriptor(apiValue: 'daily', title: 'Daily'),
    _SalesRangeDescriptor(apiValue: 'weekly', title: 'Weekly'),
    _SalesRangeDescriptor(apiValue: 'monthly', title: 'Monthly'),
    _SalesRangeDescriptor(apiValue: 'yearly', title: 'Yearly'),
  ];

  static Future<void> exportAllRanges({required String requestedBy}) async {
    final generatedAt = DateTime.now();
    final sections = await Future.wait(
      _ranges.map((range) => _fetchRange(range)),
    );

    final pdf = pw.Document(
      title: 'AIMS Sales Report',
      author: requestedBy,
      creator: 'AfterSpace Integrated Management System',
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) {
          return [
            pw.Text(
              'AIMS Sales Report',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey900,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Generated: ${_formatGeneratedAt(generatedAt)}',
              style: const pw.TextStyle(
                fontSize: 11,
                color: PdfColors.blueGrey700,
              ),
            ),
            pw.Text(
              'Requested by: $requestedBy',
              style: const pw.TextStyle(
                fontSize: 11,
                color: PdfColors.blueGrey700,
              ),
            ),
            pw.SizedBox(height: 14),
            _buildOverviewCard(sections),
            pw.SizedBox(height: 18),
            ...sections.expand(_buildRangeSection),
          ];
        },
        footer: (context) {
          return pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.blueGrey600,
              ),
            ),
          );
        },
      ),
    );

    final filename = 'aims_sales_report_${_fileStamp(generatedAt)}.pdf';
    await Printing.sharePdf(bytes: await pdf.save(), filename: filename);
  }

  static Future<_RangeExportResult> _fetchRange(
    _SalesRangeDescriptor range,
  ) async {
    try {
      final series = await AimsApiClient.instance.fetchSalesReport(
        range: range.apiValue,
      );
      return _RangeExportResult(
        title: range.title,
        series: series,
        errorMessage: null,
      );
    } on AimsApiException catch (error) {
      return _RangeExportResult(
        title: range.title,
        series: null,
        errorMessage: error.message,
      );
    } catch (error) {
      return _RangeExportResult(
        title: range.title,
        series: null,
        errorMessage: error.toString(),
      );
    }
  }

  static pw.Widget _buildOverviewCard(List<_RangeExportResult> sections) {
    final available = sections
        .where((section) => section.series != null)
        .toList();
    final unavailable = sections.length - available.length;
    final totalSales = available.fold<double>(
      0,
      (sum, section) =>
          sum + section.series!.areaValues.fold<double>(0, (a, b) => a + b),
    );

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blueGrey200),
        color: PdfColors.blueGrey50,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Summary',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Ranges exported: ${available.length}/${sections.length}',
            style: const pw.TextStyle(fontSize: 11),
          ),
          if (unavailable > 0)
            pw.Text(
              'Unavailable ranges: $unavailable (backend returned an error)',
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.red700),
            ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Combined gross sales across exported ranges: '
            '${AimsApiClient.formatCurrency(totalSales)}',
            style: const pw.TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  static List<pw.Widget> _buildRangeSection(_RangeExportResult section) {
    final series = section.series;
    if (series == null) {
      return [
        _sectionTitle('${section.title} Report'),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.red200),
            color: PdfColors.red50,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Text(
            'Failed to load from backend: ${section.errorMessage ?? 'Unknown error'}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.red900),
          ),
        ),
        pw.SizedBox(height: 16),
      ];
    }

    if (series.labels.isEmpty || series.areaValues.isEmpty) {
      return [
        _sectionTitle('${section.title} Report'),
        pw.Text(
          'No sales data available for this range.',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.blueGrey700),
        ),
        pw.SizedBox(height: 16),
      ];
    }

    final totalSales = series.areaValues.fold<double>(
      0,
      (sum, value) => sum + value,
    );
    final peakIndex = _peakIndex(series.areaValues);
    final peakLabel = _valueAt(series.labels, peakIndex) ?? 'N/A';
    final peakValue = peakIndex >= 0 ? series.areaValues[peakIndex] : 0.0;

    final rowCount = math.min(series.labels.length, series.areaValues.length);
    final lineCount = series.lineValues.length;

    final rows = List<List<String>>.generate(rowCount, (index) {
      final label = series.labels[index];
      final gross = AimsApiClient.formatCurrency(series.areaValues[index]);
      final trend = index < lineCount
          ? AimsApiClient.formatCurrency(series.lineValues[index])
          : '-';
      return [label, gross, trend];
    });

    return [
      _sectionTitle('${section.title} Report'),
      pw.Text(
        'Total gross sales: ${AimsApiClient.formatCurrency(totalSales)}',
        style: const pw.TextStyle(fontSize: 10),
      ),
      pw.SizedBox(height: 2),
      pw.Text(
        'Peak period: $peakLabel (${AimsApiClient.formatCurrency(peakValue)})',
        style: const pw.TextStyle(fontSize: 10),
      ),
      pw.SizedBox(height: 8),
      pw.TableHelper.fromTextArray(
        headers: const ['Period', 'Gross Sales', 'Trend Line'],
        data: rows,
        cellStyle: const pw.TextStyle(fontSize: 9),
        headerStyle: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
        cellAlignment: pw.Alignment.centerLeft,
        headerAlignment: pw.Alignment.centerLeft,
        border: pw.TableBorder.all(color: PdfColors.blueGrey200, width: 0.5),
      ),
      pw.SizedBox(height: 16),
    ];
  }

  static int _peakIndex(List<double> values) {
    if (values.isEmpty) {
      return -1;
    }

    var maxIndex = 0;
    for (var i = 1; i < values.length; i++) {
      if (values[i] > values[maxIndex]) {
        maxIndex = i;
      }
    }
    return maxIndex;
  }

  static T? _valueAt<T>(List<T> values, int index) {
    if (index < 0 || index >= values.length) {
      return null;
    }
    return values[index];
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blueGrey900,
        ),
      ),
    );
  }

  static String _formatGeneratedAt(DateTime dateTime) {
    final month = _monthName(dateTime.month);
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$month $day, ${dateTime.year} $hour:$minute $suffix';
  }

  static String _fileStamp(DateTime dateTime) {
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$year$month$day-$hour$minute';
  }

  static String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    if (month < 1 || month > 12) {
      return 'Unknown';
    }
    return months[month - 1];
  }
}

class _SalesRangeDescriptor {
  const _SalesRangeDescriptor({required this.apiValue, required this.title});

  final String apiValue;
  final String title;
}

class _RangeExportResult {
  const _RangeExportResult({
    required this.title,
    required this.series,
    required this.errorMessage,
  });

  final String title;
  final SalesReportSeries? series;
  final String? errorMessage;
}
