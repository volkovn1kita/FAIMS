import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:faims/l10n/app_localizations.dart';

class PdfGenerator {
  static Future<Uint8List> generateReport({
    required String title,
    String? subtitle,
    required List<List<String>> tableData,
    required List<String> headers,
    required DateTime startDate,
    required DateTime endDate,
    required AppLocalizations l10n,
  }) async {
    final pdf = pw.Document(
      title: title,
      author: 'FAIMS',
      creator: 'FAIMS',
      subject: title,
    );

    final font = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();
    final mediumFont = await PdfGoogleFonts.notoSansMedium();

    final dateFormat = DateFormat('dd.MM.yyyy');
    final dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm');

    final primary = PdfColor.fromHex('#8F58E1');
    final primaryDark = PdfColor.fromHex('#6B3DBA');
    final primarySoft = PdfColor.fromHex('#F5F3FF');
    final ink = PdfColor.fromHex('#1F1F2E');
    final mutedInk = PdfColor.fromHex('#6B6B82');
    final hairline = PdfColor.fromHex('#E9E6F2');
    final zebra = PdfColor.fromHex('#FAFAFE');

    final totalRecords = tableData.length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 36, 36, 48),
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),
        header: (context) {
          if (context.pageNumber == 1) return pw.SizedBox();
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 16),
            padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: pw.BoxDecoration(
              color: primarySoft,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'FAIMS  ·  $title',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 11,
                    color: primaryDark,
                  ),
                ),
                pw.Text(
                  '${dateFormat.format(startDate)} – ${dateFormat.format(endDate)}',
                  style: pw.TextStyle(
                    font: mediumFont,
                    fontSize: 10,
                    color: mutedInk,
                  ),
                ),
              ],
            ),
          );
        },
        footer: (context) => pw.Container(
          margin: const pw.EdgeInsets.only(top: 12),
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: hairline, width: 0.8)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                l10n.pdfConfidential,
                style: pw.TextStyle(font: font, fontSize: 8, color: mutedInk),
              ),
              pw.Text(
                l10n.pdfPageOf(context.pageNumber, context.pagesCount),
                style: pw.TextStyle(
                    font: mediumFont, fontSize: 8, color: mutedInk),
              ),
            ],
          ),
        ),
        build: (context) => [
          _buildHero(
            l10n: l10n,
            title: title,
            subtitle: subtitle,
            primary: primary,
            primaryDark: primaryDark,
            primarySoft: primarySoft,
            ink: ink,
            mutedInk: mutedInk,
            font: font,
            mediumFont: mediumFont,
            boldFont: boldFont,
          ),
          pw.SizedBox(height: 18),
          _buildSummaryCard(
            l10n: l10n,
            startDate: startDate,
            endDate: endDate,
            totalRecords: totalRecords,
            dateFormat: dateFormat,
            primary: primary,
            primarySoft: primarySoft,
            ink: ink,
            mutedInk: mutedInk,
            hairline: hairline,
            font: font,
            mediumFont: mediumFont,
            boldFont: boldFont,
          ),
          pw.SizedBox(height: 22),
          if (tableData.isEmpty)
            _buildEmptyState(
              l10n: l10n,
              primarySoft: primarySoft,
              mutedInk: mutedInk,
              font: font,
            )
          else
            _buildTable(
              headers: headers,
              tableData: tableData,
              primary: primary,
              hairline: hairline,
              zebra: zebra,
              ink: ink,
              font: font,
              boldFont: boldFont,
              mediumFont: mediumFont,
            ),

          pw.SizedBox(height: 22),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(
                '${l10n.pdfGeneratedOn}: ${dateTimeFormat.format(DateTime.now())}',
                style: pw.TextStyle(font: font, fontSize: 9, color: mutedInk),
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHero({
    required AppLocalizations l10n,
    required String title,
    required String? subtitle,
    required PdfColor primary,
    required PdfColor primaryDark,
    required PdfColor primarySoft,
    required PdfColor ink,
    required PdfColor mutedInk,
    required pw.Font font,
    required pw.Font mediumFont,
    required pw.Font boldFont,
  }) {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [primary, primaryDark],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      padding: const pw.EdgeInsets.fromLTRB(22, 20, 22, 22),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(
                width: 36,
                height: 36,
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(9),
                ),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'F',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 20,
                    color: primaryDark,
                  ),
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'FAIMS',
                    style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 14,
                      color: PdfColors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  pw.Text(
                    l10n.pdfSystemReport,
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 9,
                      color: PdfColor.fromHex('#E5DAFF'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            title,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 26,
              color: PdfColors.white,
            ),
          ),
          if (subtitle != null && subtitle != title) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              subtitle,
              style: pw.TextStyle(
                font: mediumFont,
                fontSize: 12,
                color: PdfColor.fromHex('#E5DAFF'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryCard({
    required AppLocalizations l10n,
    required DateTime startDate,
    required DateTime endDate,
    required int totalRecords,
    required DateFormat dateFormat,
    required PdfColor primary,
    required PdfColor primarySoft,
    required PdfColor ink,
    required PdfColor mutedInk,
    required PdfColor hairline,
    required pw.Font font,
    required pw.Font mediumFont,
    required pw.Font boldFont,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: hairline, width: 1),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Expanded(
            child: _summaryStat(
              label: l10n.pdfReportPeriod,
              value:
                  '${dateFormat.format(startDate)} – ${dateFormat.format(endDate)}',
              ink: ink,
              mutedInk: mutedInk,
              font: font,
              boldFont: boldFont,
            ),
          ),
          pw.Container(width: 1, height: 38, color: hairline),
          pw.Expanded(
            child: pw.Padding(
              padding: const pw.EdgeInsets.only(left: 18),
              child: _summaryStat(
                label: l10n.pdfTotalRecords,
                value: totalRecords.toString(),
                ink: ink,
                mutedInk: mutedInk,
                font: font,
                boldFont: boldFont,
                valueColor: primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _summaryStat({
    required String label,
    required String value,
    required PdfColor ink,
    required PdfColor mutedInk,
    required pw.Font font,
    required pw.Font boldFont,
    PdfColor? valueColor,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(
          label.toUpperCase(),
          style: pw.TextStyle(
            font: font,
            fontSize: 8,
            color: mutedInk,
            letterSpacing: 0.6,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 14,
            color: valueColor ?? ink,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTable({
    required List<String> headers,
    required List<List<String>> tableData,
    required PdfColor primary,
    required PdfColor hairline,
    required PdfColor zebra,
    required PdfColor ink,
    required pw.Font font,
    required pw.Font boldFont,
    required pw.Font mediumFont,
  }) {
    return pw.TableHelper.fromTextArray(
      headerAlignment: pw.Alignment.centerLeft,
      cellAlignment: pw.Alignment.centerLeft,
      headerDecoration: pw.BoxDecoration(
        color: primary,
        borderRadius: const pw.BorderRadius.only(
          topLeft: pw.Radius.circular(8),
          topRight: pw.Radius.circular(8),
        ),
      ),
      headerHeight: 32,
      cellHeight: 26,
      headerStyle: pw.TextStyle(
        font: boldFont,
        fontSize: 10,
        color: PdfColors.white,
        letterSpacing: 0.4,
      ),
      cellStyle: pw.TextStyle(font: font, fontSize: 10, color: ink),
      cellAlignments: {
        1: pw.Alignment.centerRight,
        2: pw.Alignment.center,
      },
      headerAlignments: {
        1: pw.Alignment.centerRight,
        2: pw.Alignment.center,
      },
      rowDecoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: hairline, width: 0.6),
        ),
      ),
      oddRowDecoration: pw.BoxDecoration(
        color: zebra,
        border: pw.Border(
          bottom: pw.BorderSide(color: hairline, width: 0.6),
        ),
      ),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      headers: headers,
      data: tableData,
      border: null,
    );
  }

  static pw.Widget _buildEmptyState({
    required AppLocalizations l10n,
    required PdfColor primarySoft,
    required PdfColor mutedInk,
    required pw.Font font,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: pw.BoxDecoration(
        color: primarySoft,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Center(
        child: pw.Text(
          l10n.pdfNoData,
          style: pw.TextStyle(font: font, fontSize: 12, color: mutedInk),
        ),
      ),
    );
  }
}
