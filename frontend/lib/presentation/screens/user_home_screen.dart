import 'package:flutter/material.dart';
import 'package:faims/data/dtos/first_aid_kit_list_dto.dart';
import 'package:faims/data/dtos/medication_dto.dart';
import 'package:faims/data/dtos/medication_create_dto.dart';
import 'package:faims/data/dtos/medication_quantity_update_dto.dart';
import 'package:faims/data/dtos/medication_write_off_dto.dart';
import 'package:faims/data/dtos/medication_refill_dto.dart';
import 'package:faims/domain/repositories/first_aid_kit_repository.dart';
import 'package:faims/domain/repositories/auth_repository.dart';
import 'package:faims/l10n/app_localizations.dart';
import 'package:faims/presentation/screens/my_profile_screen.dart';
import 'package:faims/presentation/screens/settings_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:faims/core/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:faims/data/dtos/expiration_status.dart';
import 'package:faims/data/dtos/measurement_unit.dart';

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

  InputDecoration _inputStyle(String label, String? suffix) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      suffixText: suffix,
      filled: true,
      fillColor: isDark
          ? theme.colorScheme.surfaceContainerHigh
          : AppTheme.primaryContainer,
      labelStyle: TextStyle(
        color: isDark ? theme.colorScheme.onSurfaceVariant : AppTheme.primaryLabel,
        fontSize: 14,
      ),
      suffixStyle: TextStyle(
        color: theme.colorScheme.onSurfaceVariant,
        fontSize: 14,
      ),
      floatingLabelStyle: TextStyle(
        color: isDark ? theme.colorScheme.primary : AppTheme.primary,
        fontWeight: FontWeight.w600,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? theme.colorScheme.outline.withValues(alpha: 0.3) : AppTheme.primaryBorder,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _sheetHandle() => Center(
        child: Container(
          width: 44,
          height: 4,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

  Widget _sheetTitle(String text, IconData icon, Color color) => Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      );

  Widget _infoRow(IconData icon, String text, Color color) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.18)),
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
          String label, Color color, VoidCallback onPressed) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: isDark ? 0 : 3,
          shadowColor: isDark ? Colors.transparent : color.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _cancelBtn(BuildContext ctx, String label) => SizedBox(
        width: double.infinity,
        height: 48,
        child: TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(
            label,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 15),
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
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
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
                AppTheme.primary,
              ),
              const SizedBox(height: 20),
              _infoRow(
                Icons.inventory_2_outlined,
                '${l10n.available}: ${medication.quantity} ${medication.unit.localizedName(context)}',
                AppTheme.primary,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15),
                decoration: _inputStyle(
                  l10n.quantityToUse,
                  medication.unit.localizedName(context),
                ),
              ),
              const SizedBox(height: 28),
              _buildActionBtn(l10n.use, AppTheme.primary, () {
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

  Future<void> _showRefillDialog(
      MedicationDto medication, AppLocalizations l10n) async {
    final qController = TextEditingController();
    DateTime date = DateTime.now().add(const Duration(days: 365));
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
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
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
                    l10n.refillMedicationTitle(medication.name),
                    Icons.add_shopping_cart_rounded,
                    AppTheme.primary,
                  ),
                  const SizedBox(height: 20),
                  _infoRow(
                    Icons.info_outline_rounded,
                    '${l10n.available}: ${medication.quantity} ${medication.unit.localizedName(context)}',
                    AppTheme.primary,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: qController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                    decoration: _inputStyle(
                      l10n.quantity,
                      medication.unit.localizedName(context),
                    ),
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
                            colorScheme: ColorScheme.fromSeed(
                              seedColor: AppTheme.primary,
                              brightness: Theme.of(context).brightness,
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
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).colorScheme.surfaceContainerHigh
                            : AppTheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)
                                : AppTheme.primaryBorder,
                            width: 1),
                      ),
                      child: Row(children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 18, color: Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : AppTheme.primaryLabel),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.newExpirationDate,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Theme.of(context).colorScheme.onSurfaceVariant
                                        : AppTheme.primaryLabel,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                DateFormat('dd.MM.yyyy').format(date),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : AppTheme.primaryLabel),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildActionBtn(l10n.refill, AppTheme.primary, () {
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

    if (confirmed) {
      final q = int.tryParse(qController.text) ?? 0;
      if (q > 0) {
        await _performAction(
          () => _kitRepository.refillMedication(
              medication.id,
              MedicationRefillDto(
                  addedQuantity: q, newExpirationDate: date)),
          l10n.medicationRefilledSuccess,
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
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
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
                '${l10n.available}: ${medication.quantity} ${medication.unit.localizedName(context)}',
                Colors.red.shade700,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: qController,
                keyboardType: TextInputType.number,
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15),
                decoration: _inputStyle(
                  l10n.quantityToWriteOff,
                  medication.unit.localizedName(context),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: rController,
                maxLines: 3,
                style: TextStyle(fontSize: 14),
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
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
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
                    AppTheme.primary,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameC,
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                    decoration: _inputStyle(l10n.medicationName, null),
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: qC,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                        decoration: _inputStyle(l10n.quantity, null),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: minC,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                        decoration: _inputStyle(l10n.minRequired, null),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<MeasurementUnit>(
                    initialValue: unit,
                    decoration: _inputStyle(l10n.unit, null),
                    dropdownColor: Theme.of(ctx).brightness == Brightness.dark
                        ? Theme.of(ctx).colorScheme.surfaceContainerHigh
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Theme.of(ctx).colorScheme.onSurface,
                    ),
                    items: MeasurementUnit.values
                        .map((u) => DropdownMenuItem(
                              value: u,
                              child: Text(u.localizedName(context)),
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
                            colorScheme: ColorScheme.fromSeed(
                              seedColor: AppTheme.primary,
                              brightness: Theme.of(context).brightness,
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
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).colorScheme.surfaceContainerHigh
                            : AppTheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)
                                : AppTheme.primaryBorder,
                            width: 1),
                      ),
                      child: Row(children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 18, color: AppTheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.expirationDate,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Theme.of(context).colorScheme.onSurfaceVariant
                                        : AppTheme.primaryLabel,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                DateFormat('dd.MM.yyyy').format(date),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : AppTheme.primaryLabel),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildActionBtn(l10n.add, AppTheme.primary, () {
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.light
          ? const Color(0xFFF5F3FF)
          : theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0,
        centerTitle: true,
        title: Text('FAIMS',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
                letterSpacing: 1.2)),
        leading: IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () async {
              await AuthRepository().logout();
              if (!context.mounted) return;
              context.go('/login');
            }),
        actions: [
          IconButton(
              icon: Icon(Icons.settings_outlined,
                  color: theme.colorScheme.onSurface),
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (c) => const SettingsScreen()))),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(_errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red)),
                ))
              : RefreshIndicator(
                  onRefresh: _loadMyKitAndMedications,
                  color: AppTheme.primary,
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
                                      size: 64, color: theme.colorScheme.onSurfaceVariant),
                                  const SizedBox(height: 16),
                                  Text(
                                    l10n.notAssignedToKit,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: theme.colorScheme.onSurfaceVariant,
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
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.medical_information_rounded,
                  size: 14, color: Colors.blue),
              const SizedBox(width: 6),
              Text(l10n.userRoleUser,
                  style: TextStyle(
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
              colors: [AppTheme.primaryLight, AppTheme.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.3),
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
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle),
                child: const Icon(Icons.inventory_2_rounded,
                    color: Colors.white, size: 28)),
            const SizedBox(width: 16),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(_myKit!.name,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text('ID: ${_myKit!.uniqueNumber}',
                      style: TextStyle(
                          fontSize: 12, color: Colors.white70)),
                ])),
            _buildKitStatusBadge(l10n, _myKit!.statusBadge),
          ]),
          const SizedBox(height: 20),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
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
            color: Colors.white.withValues(alpha: 0.1),
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
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface)),
        TextButton.icon(
          onPressed: () => _showAddMedicationDialog(l10n),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: Text(l10n.add),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primary,
            textStyle:
                TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ]);

  Widget _buildFilterSection(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(children: [
        Container(
          decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ]),
          child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                  hintText: l10n.searchMedicationHint,
                  prefixIcon:
                      Icon(Icons.search_rounded, color: theme.colorScheme.onSurfaceVariant),
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
                  backgroundColor: theme.cardColor,
                  shape: StadiumBorder(
                      side: BorderSide(color: theme.dividerColor))),
            ])),
        const SizedBox(height: 16),
      ]);
  }

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
        selectedColor: color.withValues(alpha: 0.1),
        checkmarkColor: color,
        backgroundColor: Theme.of(context).cardColor,
        shape: StadiumBorder(
            side: BorderSide(color: Theme.of(context).dividerColor)));
  }

  Widget _buildMedicationList(AppLocalizations l10n) {
    if (_filteredMedications.isEmpty) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(40),
              child: Text(l10n.noMedicationsFound,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))));
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
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Row(children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: sColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.vaccines_rounded, color: sColor, size: 24)),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(med.name,
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                    '${l10n.expires}: ${DateFormat('dd.MM.yyyy').format(med.expirationDate)}',
                    style:
                        TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
              ])),
          _buildStatusTag(med.status, l10n),
        ]),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _buildStatItem(l10n.quantity,
              '${med.quantity} ${med.unit.localizedName(context)}',
              isLow ? Colors.red : theme.colorScheme.onSurface),
          _buildStatItem(l10n.minRequired,
              '${med.minimumQuantity} ${med.unit.localizedName(context)}',
              theme.colorScheme.onSurfaceVariant),
        ]),
        const SizedBox(height: 16),
        if (med.quantity > 0)
          Row(children: [
            Expanded(
                child: ElevatedButton.icon(
                    onPressed: () => _showUseMedicationDialog(med, l10n),
                    icon: const Icon(Icons.medical_services_outlined, size: 18),
                    label: Text(l10n.use),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0))),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                  onPressed: () => _showWriteOffDialog(med, l10n),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: Text(l10n.writeOff),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)))),
            ),
          ])
        else
          Row(children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                    onPressed: () => _showRefillDialog(med, l10n),
                    icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                    label: Text(l10n.refill),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryContainer,
                        foregroundColor: AppTheme.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)))),
              ),
            ),
          ]),
      ]),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
          color: color.withValues(alpha: 0.1),
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

  Widget _buildBottomNav(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5))
        ]),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: theme.cardColor,
          currentIndex: _selectedIndex,
          selectedItemColor: AppTheme.primary,
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
}