import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:frontend/data/dtos/report_item_dto.dart';
import 'package:frontend/domain/repositories/reports_repository.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/utils/pdf_generator.dart';
import 'package:printing/printing.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ReportsRepository _repository = ReportsRepository();
  
  bool _isLoading = true;
  String _errorMessage = '';

  List<ReportItemDto> _purchaseList = [];
  List<ReportItemDto> _disposalList = [];

  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    _endDate = DateTime.now();
    _startDate = _endDate.subtract(const Duration(days: 30));

    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final results = await Future.wait([
        _repository.getPurchasingReport(_startDate, _endDate),
        _repository.getDisposalReport(_startDate, _endDate),
      ]);

      if (!mounted) return;
      setState(() {
        _purchaseList = results[0];
        _disposalList = results[1];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 143, 88, 225),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadReports();
    }
  }

  String _translateReason(String reasonKey, AppLocalizations l10n) {
    switch (reasonKey) {
      case 'current_deficit': return l10n.reasonCurrentDeficit;
      case 'period_expenses': return l10n.reasonPeriodExpenses;
      case 'expired_in_kits': return l10n.reasonExpiredInKits;
      case 'written_off_period': return l10n.reasonWrittenOffPeriod;
      default: return reasonKey;
    }
  }

  Future<void> _exportPdf(AppLocalizations l10n) async {
    final isPurchaseTab = _tabController.index == 0;
    final items = isPurchaseTab ? _purchaseList : _disposalList;
    final title = isPurchaseTab ? l10n.forPurchase : l10n.forDisposal;

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.listIsEmpty)),
      );
      return;
    }

    try {
      final headers = [l10n.columnName, l10n.columnQuantity, l10n.columnUnit, l10n.columnReason];
      
      final tableData = items.map((item) {
        return [
          item.medicationName,
          '+${item.quantity}',
          item.unit,
          _translateReason(item.reason, l10n),
        ];
      }).toList();

      final pdfBytes = await PdfGenerator.generateReport(
        title: title,
        tableData: tableData,
        headers: headers,
        startDate: _startDate,
        endDate: _endDate,
      );
      
      final filename = '${isPurchaseTab ? "purchase" : "disposal"}_report.pdf';
      await Printing.sharePdf(bytes: pdfBytes, filename: filename);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const purple = Color.fromARGB(255, 143, 88, 225);
    final dateformat = DateFormat('dd.MM.yyyy');

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.reportsAndLists,
          style: GoogleFonts.notoSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: purple,
          unselectedLabelColor: Colors.grey.shade500,
          indicatorColor: purple,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.notoSans(fontWeight: FontWeight.bold, fontSize: 15),
          unselectedLabelStyle: GoogleFonts.notoSans(fontWeight: FontWeight.w600, fontSize: 15),
          tabs: [
            Tab(text: l10n.forPurchase),
            Tab(text: l10n.forDisposal),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: InkWell(
              onTap: _selectDateRange,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: purple.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: purple.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded, color: purple, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${dateformat.format(_startDate)} - ${dateformat.format(_endDate)}',
                        style: GoogleFonts.notoSans(
                          color: purple,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down_rounded, color: purple.withOpacity(0.7)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: purple))
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildReportList(_purchaseList, Icons.shopping_cart_outlined, Colors.blue.shade600, l10n),
                          _buildReportList(_disposalList, Icons.delete_outline_rounded, Colors.red.shade500, l10n),
                        ],
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _exportPdf(l10n),
        backgroundColor: purple,
        icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
        label: Text(
          l10n.export,
          style: GoogleFonts.notoSans(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildReportList(List<ReportItemDto> items, IconData icon, Color iconColor, AppLocalizations l10n) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          l10n.listIsEmpty,
          style: GoogleFonts.notoSans(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20).copyWith(bottom: 80),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final translatedReason = _translateReason(item.reason, l10n);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.medicationName,
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      translatedReason,
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+${item.quantity}',
                    style: GoogleFonts.notoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    item.unit,
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}