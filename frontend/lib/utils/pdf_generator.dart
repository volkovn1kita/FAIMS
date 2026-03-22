import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

class PdfGenerator {
  static Future<Uint8List> generateReport({
    required String title,
    required List<List<String>> tableData,
    required List<String> headers,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();
    final dateformat = DateFormat('dd.MM.yyyy');

    final primaryColor = PdfColor.fromHex('#8F58E1');
    final lightBgColor = PdfColor.fromHex('#F5F3FF');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 20),
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 2)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'FAIMS System Report',
                      style: pw.TextStyle(font: boldFont, fontSize: 14, color: primaryColor),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      title,
                      style: pw.TextStyle(font: boldFont, fontSize: 28, color: PdfColors.black),
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: pw.BoxDecoration(
                    color: lightBgColor,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(
                    '${dateformat.format(startDate)} - ${dateformat.format(endDate)}',
                    style: pw.TextStyle(font: boldFont, fontSize: 12, color: primaryColor),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 30),
          pw.TableHelper.fromTextArray(
            context: context,
            headerAlignment: pw.Alignment.centerLeft,
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration: pw.BoxDecoration(
              color: primaryColor,
              borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(8)),
            ),
            headerStyle: pw.TextStyle(font: boldFont, fontSize: 12, color: PdfColors.white),
            cellStyle: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.grey800),
            rowDecoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 1)),
            ),
            oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey50),
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            headers: headers,
            data: tableData,
          ),
          pw.Spacer(),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Generated automatically by FAIMS',
                style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey500),
              ),
              pw.Text(
                dateformat.format(DateTime.now()),
                style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey500),
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }
}