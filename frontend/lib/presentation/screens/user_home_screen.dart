import 'package:flutter/material.dart';
import 'package:frontend/data/dtos/first_aid_kit_list_dto.dart';
import 'package:frontend/data/dtos/medication_dto.dart';
import 'package:frontend/data/dtos/medication_create_dto.dart';
import 'package:frontend/data/dtos/medication_quantity_update_dto.dart';
import 'package:frontend/data/dtos/medication_write_off_dto.dart';
import 'package:frontend/domain/repositories/first_aid_kit_repository.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/presentation/screens/my_profile_screen.dart';
import 'package:frontend/core/extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:frontend/data/dtos/expiration_status.dart';
import 'package:frontend/data/dtos/measurement_unit.dart';
import 'package:frontend/presentation/screens/settings_screen.dart';

class UserHomeScreen extends StatefulWidget {
  final String userName;

  const UserHomeScreen({super.key, required this.userName});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _selectedIndex = 0;
  final _kitRepository = FirstAidKitRepository();

  FirstAidKitListDto? _myKit;
  List<MedicationDto> _medications = [];
  bool _isLoading = true;
  String _errorMessage = '';
  late String _userName;

  List<MedicationDto> _filteredMedications = [];
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<ExpirationStatus> _statusFilters = {};
  bool _filterLowStock = false;

  static const _purple = Color(0xFF8F58E1);
  static const _purpleLight = Color(0xFFF5F3FF);
  static const _purpleBorder = Color(0xFFE8E0FF);
  static const _purpleLabel = Color(0xFF9E86C8);

  @override
  void initState() {
    super.initState();
    _userName = widget.userName;
    _searchController.addListener(_onSearchChanged);
    _loadMyKitAndMedications();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<MedicationDto> filtered = List.from(_medications);
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((m) =>
              m.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    if (_statusFilters.isNotEmpty) {
      filtered =
          filtered.where((m) => _statusFilters.contains(m.status)).toList();
    }
    if (_filterLowStock) {
      filtered =
          filtered.where((m) => m.quantity < m.minimumQuantity).toList();
    }
    setState(() {
      _filteredMedications = filtered;
    });
  }

  Future<void> _loadMyKitAndMedications() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final kit = await _kitRepository.getMyKit();
      final medications = await _kitRepository.getMedicationsForKit(kit.id);
      if (!mounted) return;
      setState(() {
        _myKit = kit;
        _medications = medications;
        _medications
            .sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
        _applyFilters();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onItemTapped(int index) async {
    if (index == _selectedIndex && index != 1) return;
    if (index == 0) {
      setState(() => _selectedIndex = index);
    } else if (index == 1) {
      final updatedName = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (context) => const MyProfileScreen()),
      );
      if (!mounted) return;
      if (updatedName != null) {
        setState(() => _userName = updatedName);
      }
      setState(() => _selectedIndex = 0);
      await _loadMyKitAndMedications();
    }
  }

  InputDecoration _inputStyle(String label, String? suffix) =>
      InputDecoration(
        labelText: label,
        suffixText: suffix,
        filled: true,
        fillColor: _purpleLight,
        labelStyle: const TextStyle(color: _purpleLabel, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _purpleBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _purple, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  Widget _sheetHandle() => Center(
        child: Container(
          width: 44,
          height: 4,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

  Widget _sheetTitle(String text, IconData icon, Color color) => Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      );

  Widget _infoRow(IconData icon, String text, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );

  Widget _buildActionBtn(
          String label, Color color, VoidCallback onPressed) =>
      SizedBox(
        width: double.infinity,
        height: 54,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.78)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              label,
              style: GoogleFonts.notoSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );

  Widget _cancelBtn(BuildContext ctx, String label) => SizedBox(
        width: double.infinity,
        height: 48,
        child: TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ),
      );

  Future<void> _showUseMedicationDialog(
      MedicationDto medication, AppLocalizations l10n) async {
    final quantityController = TextEditingController(text: '1');
    bool confirmed = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sheetHandle(),
              const SizedBox(height: 8),
              _sheetTitle(
                l10n.useMedicationTitle(medication.name),
                Icons.medication_liquid_rounded,
                _purple,
              ),
              const SizedBox(height: 20),
              _infoRow(
                Icons.inventory_2_outlined,
                '${l10n.available}: ${medication.quantity} ${medication.unit.name.capitalize()}',
                _purple,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.notoSans(
                    fontWeight: FontWeight.w600, fontSize: 15),
                decoration: _inputStyle(
                  l10n.quantityToUse,
                  medication.unit.name.capitalize(),
                ),
              ),
              const SizedBox(height: 28),
              _buildActionBtn(l10n.use, _purple, () {
                confirmed = true;
                Navigator.pop(ctx);
              }),
              const SizedBox(height: 4),
              _cancelBtn(ctx, l10n.cancel),
            ],
          ),
        ),
      ),
    );

    if (confirmed) {
      final q = int.tryParse(quantityController.text) ?? 0;
      if (q > 0 && q <= medication.quantity) {
        await _performAction(
          () => _kitRepository.useMedication(
              medication.id, MedicationQuantityUpdateDto(quantity: q)),
          l10n.medicationUsedSuccess,
        );
      }
    }
  }

  Future<void> _showWriteOffDialog(
      MedicationDto medication, AppLocalizations l10n) async {
    final qController = TextEditingController();
    final rController = TextEditingController();
    bool confirmed = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sheetHandle(),
              const SizedBox(height: 8),
              _sheetTitle(
                l10n.writeOffMedicationTitle(medication.name),
                Icons.delete_sweep_rounded,
                Colors.redAccent,
              ),
              const SizedBox(height: 20),
              _infoRow(
                Icons.warning_amber_rounded,
                '${l10n.available}: ${medication.quantity} ${medication.unit.name.capitalize()}',
                Colors.red.shade700,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: qController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.notoSans(
                    fontWeight: FontWeight.w600, fontSize: 15),
                decoration: _inputStyle(
                  l10n.quantityToWriteOff,
                  medication.unit.name.capitalize(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: rController,
                maxLines: 3,
                style: GoogleFonts.notoSans(fontSize: 14),
                decoration:
                    _inputStyle(l10n.reasonRequired, null).copyWith(
                  hintText: l10n.reasonHint,
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 28),
              _buildActionBtn(l10n.writeOff, Colors.redAccent, () {
                confirmed = true;
                Navigator.pop(ctx);
              }),
              const SizedBox(height: 4),
              _cancelBtn(ctx, l10n.cancel),
            ],
          ),
        ),
      ),
    );

    if (confirmed) {
      final q = int.tryParse(qController.text) ?? 0;
      final r = rController.text.trim();
      if (q > 0 && r.isNotEmpty) {
        await _performAction(
          () => _kitRepository.writeOffMedication(medication.id,
              MedicationWriteOffDto(quantity: q, reason: r)),
          l10n.medicationWrittenOffSuccess,
        );
      }
    }
  }

  Future<void> _showAddMedicationDialog(AppLocalizations l10n) async {
    final nameC = TextEditingController();
    final qC = TextEditingController();
    final minC = TextEditingController();
    DateTime date = DateTime.now().add(const Duration(days: 365));
    MeasurementUnit unit = MeasurementUnit.pieces;
    bool confirmed = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sheetHandle(),
                  const SizedBox(height: 8),
                  _sheetTitle(
                    l10n.addNewMedication,
                    Icons.add_circle_outline_rounded,
                    _purple,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameC,
                    textCapitalization: TextCapitalization.sentences,
                    style: GoogleFonts.notoSans(
                        fontWeight: FontWeight.w600, fontSize: 15),
                    decoration: _inputStyle(l10n.medicationName, null),
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: qC,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.notoSans(
                            fontWeight: FontWeight.w600, fontSize: 15),
                        decoration: _inputStyle(l10n.quantity, null),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: minC,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.notoSans(
                            fontWeight: FontWeight.w600, fontSize: 15),
                        decoration: _inputStyle(l10n.minRequired, null),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<MeasurementUnit>(
                    initialValue: unit,
                    decoration: _inputStyle(l10n.unit, null),
                    borderRadius: BorderRadius.circular(16),
                    items: MeasurementUnit.values
                        .map((u) => DropdownMenuItem(
                              value: u,
                              child: Text(
                                u.name.capitalize(),
                                style: GoogleFonts.notoSans(
                                    fontWeight: FontWeight.w500),
                              ),
                            ))
                        .toList(),
                    onChanged: (v) => setS(() => unit = v!),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: date,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now()
                            .add(const Duration(days: 3650)),
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: _purple,
                              onSurface: Colors.black87,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) setS(() => date = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: _purpleLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: _purpleBorder, width: 1.5),
                      ),
                      child: Row(children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 18, color: _purple),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.expirationDate,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: _purpleLabel,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                DateFormat('dd.MM.yyyy').format(date),
                                style: GoogleFonts.notoSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: _purpleLabel),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildActionBtn(l10n.add, _purple, () {
                    confirmed = true;
                    Navigator.pop(ctx);
                  }),
                  const SizedBox(height: 4),
                  _cancelBtn(ctx, l10n.cancel),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (confirmed && nameC.text.trim().isNotEmpty) {
      final dto = MedicationCreateDto(
        firstAidKitId: _myKit!.id,
        name: nameC.text.trim(),
        quantity: int.tryParse(qC.text) ?? 0,
        minimumQuantity: int.tryParse(minC.text) ?? 0,
        unit: unit,
        expirationDate: date,
      );
      await _performAction(
        () => _kitRepository.addMedication(dto),
        l10n.medicationAddedSuccess,
      );
    }
  }

  Future<void> _performAction(
      Future<void> Function() action, String successMsg) async {
    setState(() => _isLoading = true);
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(successMsg), backgroundColor: Colors.green));
      await _loadMyKitAndMedications();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('FAIMS',
            style: GoogleFonts.notoSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _purple,
                letterSpacing: 1.2)),
        leading: IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () => Navigator.of(context)
                .pushNamedAndRemoveUntil('/login', (r) => false)),
        actions: [
          IconButton(
              icon: const Icon(Icons.settings_outlined,
                  color: Colors.black87),
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (c) => const SettingsScreen()))),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _purple))
          : RefreshIndicator(
              onRefresh: _loadMyKitAndMedications,
              color: _purple,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeHeader(l10n),
                    const SizedBox(height: 24),
                    if (_myKit != null) ...[
                      _buildKitInfoCard(l10n),
                      const SizedBox(height: 32),
                      _buildSectionHeader(l10n),
                      const SizedBox(height: 16),
                      _buildFilterSection(l10n),
                      _buildMedicationList(l10n),
                    ] else
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 60.0, horizontal: 20.0),
                          child: Column(
                            children: [
                              Icon(Icons.inventory_2_outlined,
                                  size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                l10n.notAssignedToKit,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.notoSans(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNav(l10n),
    );
  }

  Widget _buildWelcomeHeader(AppLocalizations l10n) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.welcomeUser(_userName),
              style: GoogleFonts.notoSans(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.medical_information_rounded,
                  size: 14, color: Colors.blue),
              const SizedBox(width: 6),
              Text(l10n.userRoleUser,
                  style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold)),
            ]),
          ),
        ],
      );

  Widget _buildKitInfoCard(AppLocalizations l10n) => Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 163, 108, 245),
                Color.fromARGB(255, 123, 68, 205)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: _purple.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8))
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          Row(children: [
            Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle),
                child: const Icon(Icons.inventory_2_rounded,
                    color: Colors.white, size: 28)),
            const SizedBox(width: 16),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(_myKit!.name,
                      style: GoogleFonts.notoSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text('ID: ${_myKit!.uniqueNumber}',
                      style: GoogleFonts.notoSans(
                          fontSize: 12, color: Colors.white70)),
                ])),
            _buildKitStatusBadge(l10n, _myKit!.statusBadge),
          ]),
          const SizedBox(height: 20),
          Container(height: 1, color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 20),
          _buildKitDetailRow(
              Icons.business_rounded, l10n.department, _myKit!.departmentName),
          const SizedBox(height: 12),
          _buildKitDetailRow(
              Icons.meeting_room_rounded, l10n.room, _myKit!.roomName),
          if (_myKit!.expiredItemsCount > 0 ||
              _myKit!.criticalItemsCount > 0) ...[
            const SizedBox(height: 20),
            _buildKitWarningBox(l10n),
          ],
        ]),
      );

  Widget _buildKitStatusBadge(AppLocalizations l10n, String status) {
    bool isG = status == 'Good';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: isG ? Colors.green.shade400 : Colors.orange.shade400,
          borderRadius: BorderRadius.circular(12)),
      child: Text(isG ? l10n.statusGood : l10n.statusWarning,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white)),
    );
  }

  Widget _buildKitDetailRow(IconData i, String l, String v) =>
      Row(children: [
        Icon(i, size: 18, color: Colors.white70),
        const SizedBox(width: 12),
        Text('$l:', style: const TextStyle(fontSize: 14, color: Colors.white70)),
        const SizedBox(width: 8),
        Expanded(
            child: Text(v,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white))),
      ]);

  Widget _buildKitWarningBox(AppLocalizations l10n) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          const Icon(Icons.warning_amber_rounded,
              color: Colors.orangeAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
              child: Text(
                  '${_myKit!.expiredItemsCount} ${l10n.expired}, ${_myKit!.criticalItemsCount} ${l10n.critical}',
                  style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w600))),
        ]),
      );

  Widget _buildSectionHeader(AppLocalizations l10n) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(l10n.medications,
            style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        TextButton.icon(
          onPressed: () => _showAddMedicationDialog(l10n),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: Text(l10n.add),
          style: TextButton.styleFrom(
            foregroundColor: _purple,
            textStyle:
                GoogleFonts.notoSans(fontWeight: FontWeight.bold),
          ),
        ),
      ]);

  Widget _buildFilterSection(AppLocalizations l10n) => Column(children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ]),
          child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                  hintText: l10n.searchMedicationHint,
                  prefixIcon:
                      const Icon(Icons.search_rounded, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15))),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _buildFilterChip(
                  l10n.expired, ExpirationStatus.expired, Colors.red),
              const SizedBox(width: 8),
              _buildFilterChip(l10n.critical, ExpirationStatus.critical,
                  Colors.deepOrange),
              const SizedBox(width: 8),
              FilterChip(
                  label: Text(l10n.lowStock),
                  selected: _filterLowStock,
                  onSelected: (v) => setState(() {
                        _filterLowStock = v;
                        _applyFilters();
                      }),
                  selectedColor: Colors.amber.shade100,
                  checkmarkColor: Colors.amber.shade900,
                  backgroundColor: Colors.white,
                  shape: const StadiumBorder(
                      side: BorderSide(color: Color(0xFFEEEEEE)))),
            ])),
        const SizedBox(height: 16),
      ]);

  Widget _buildFilterChip(
      String label, ExpirationStatus status, Color color) {
    bool isS = _statusFilters.contains(status);
    return FilterChip(
        label: Text(label),
        selected: isS,
        onSelected: (v) => setState(() {
              v
                  ? _statusFilters.add(status)
                  : _statusFilters.remove(status);
              _applyFilters();
            }),
        selectedColor: color.withOpacity(0.1),
        checkmarkColor: color,
        backgroundColor: Colors.white,
        shape: const StadiumBorder(
            side: BorderSide(color: Color(0xFFEEEEEE))));
  }

  Widget _buildMedicationList(AppLocalizations l10n) {
    if (_filteredMedications.isEmpty) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(40),
              child: Text(l10n.noMedicationsFound,
                  style: const TextStyle(color: Colors.grey))));
    }
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _filteredMedications.length,
        itemBuilder: (c, i) =>
            _buildMedicationCard(_filteredMedications[i], l10n));
  }

  Widget _buildMedicationCard(MedicationDto med, AppLocalizations l10n) {
    Color sColor = _getStatusColor(med.status);
    bool isLow = med.quantity < med.minimumQuantity;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Row(children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: sColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.vaccines_rounded, color: sColor, size: 24)),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(med.name,
                    style: GoogleFonts.notoSans(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                    '${l10n.expires}: ${DateFormat('dd.MM.yyyy').format(med.expirationDate)}',
                    style:
                        const TextStyle(fontSize: 12, color: Colors.grey)),
              ])),
          _buildStatusTag(med.status, l10n),
        ]),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _buildStatItem(l10n.quantity,
              '${med.quantity} ${med.unit.name.capitalize()}',
              isLow ? Colors.red : Colors.black87),
          _buildStatItem(l10n.minRequired,
              '${med.minimumQuantity} ${med.unit.name.capitalize()}',
              Colors.grey),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
              child: OutlinedButton(
                  onPressed: () => _showWriteOffDialog(med, l10n),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.shade100),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: Text(l10n.writeOff))),
          const SizedBox(width: 12),
          Expanded(
              child: ElevatedButton(
                  onPressed: () => _showUseMedicationDialog(med, l10n),
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color.fromARGB(255, 173, 128, 245),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0),
                  child: Text(l10n.use))),
        ]),
      ]),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w600)),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: valueColor)),
      ]);

  Widget _buildStatusTag(ExpirationStatus status, AppLocalizations l10n) {
    String text = '';
    Color color = _getStatusColor(status);
    switch (status) {
      case ExpirationStatus.expired:
        text = l10n.expired;
        break;
      case ExpirationStatus.critical:
        text = l10n.critical;
        break;
      case ExpirationStatus.warning:
        text = l10n.statusWarning;
        break;
      case ExpirationStatus.good:
        text = l10n.statusGood;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color)),
    );
  }

  Color _getStatusColor(ExpirationStatus s) {
    switch (s) {
      case ExpirationStatus.expired:
        return Colors.red;
      case ExpirationStatus.critical:
        return Colors.deepOrange;
      case ExpirationStatus.warning:
        return Colors.orange;
      case ExpirationStatus.good:
        return Colors.green;
    }
  }

  Widget _buildBottomNav(AppLocalizations l10n) => Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5))
        ]),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.white,
          currentIndex: _selectedIndex,
          selectedItemColor: _purple,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
                icon: const Icon(Icons.home_rounded), label: l10n.home),
            BottomNavigationBarItem(
                icon: const Icon(Icons.person_rounded),
                label: l10n.profile),
          ],
        ),
      );
}