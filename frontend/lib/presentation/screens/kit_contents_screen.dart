import 'package:flutter/material.dart';
import 'package:faims/l10n/app_localizations.dart';
import 'package:faims/presentation/screens/add_edit_kit_screen.dart';
import 'package:faims/core/app_theme.dart';
import 'package:faims/data/dtos/first_aid_kit_list_dto.dart';
import 'package:faims/data/dtos/medication_dto.dart';
import 'package:faims/domain/repositories/first_aid_kit_repository.dart';
import 'package:intl/intl.dart';
import 'package:faims/data/dtos/expiration_status.dart';
import 'package:faims/data/dtos/measurement_unit.dart';
import 'package:faims/presentation/screens/add_edit_medication_screen.dart';
import 'package:faims/data/dtos/medication_refill_dto.dart';

class KitContentsScreen extends StatefulWidget {
  final String kitId;

  const KitContentsScreen({
    super.key,
    required this.kitId,
  });

  @override
  State<KitContentsScreen> createState() => _KitContentsScreenState();
}

class _KitContentsScreenState extends State<KitContentsScreen> {
  FirstAidKitListDto? _kitDetails;
  List<MedicationDto> _medications = [];
  List<_MedicationGroup> _groupedMedications = [];
  final Set<String> _expandedGroups = {};
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;
  String _errorMessage = '';
  String _kitName = '';

  final _kitRepository = FirstAidKitRepository();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadKitDetailsAndContents();
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
      _groupedMedications = _buildGroups(_filteredMedications());
    });
  }

  List<MedicationDto> _filteredMedications() {
    if (_searchQuery.isEmpty) return _medications;
    final q = _searchQuery.toLowerCase();
    return _medications.where((m) => m.name.toLowerCase().contains(q)).toList();
  }

  Future<void> _loadKitDetailsAndContents() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final loadedKit = await _kitRepository.getFirstAidKitById(widget.kitId);
      final loadedMedications = await _kitRepository.getMedicationsForKit(widget.kitId);

      if (!mounted) return;
      setState(() {
        _kitName = loadedKit.name;
        _kitDetails = loadedKit;
        _medications = loadedMedications;
        _medications.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
        _groupedMedications = _buildGroups(_filteredMedications());
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Error loading kit details or contents: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Groups medications by (name, unit). Within a group, batches with
  /// quantity == 0 are hidden when at least one non-zero batch exists,
  /// so a stale empty record stops triggering false "out of stock"
  /// warnings the moment a fresh batch is added.
  List<_MedicationGroup> _buildGroups(List<MedicationDto> meds) {
    final Map<String, List<MedicationDto>> byKey = {};
    for (final m in meds) {
      final key = '${m.name.trim().toLowerCase()}|${m.unit.name}';
      byKey.putIfAbsent(key, () => []).add(m);
    }

    final groups = <_MedicationGroup>[];
    byKey.forEach((_, batches) {
      final nonZero = batches.where((m) => m.quantity > 0).toList();
      final visible = nonZero.isNotEmpty ? nonZero : batches;
      visible.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
      groups.add(_MedicationGroup(
        name: batches.first.name,
        visibleBatches: visible,
        allBatches: batches,
      ));
    });

    groups.sort((a, b) => a.earliestExpiration.compareTo(b.earliestExpiration));
    return groups;
  }

  Future<void> _navigateToAddEditMedication({String? medicationId}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditMedicationScreen(
          kitId: widget.kitId,
          medicationId: medicationId,
        ),
      ),
    );

    if (result == true || result == null) {
      await _loadKitDetailsAndContents();
    }
  }

  Future<void> _navigateToEditKit() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditKitScreen(
          kitId: widget.kitId, 
        ),
      ),
    );

    if (result == true) {
      await _loadKitDetailsAndContents();
    }
  }

  Future<void> _confirmDeleteKit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_medications.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cannotDeleteKit(_kitName), style: TextStyle()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      return; 
    }
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.confirmDeletion, style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(l10n.confirmDeleteFirstAidKit(_kitName), style: TextStyle()),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.delete, style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      try {
        await _kitRepository.deleteKit(widget.kitId); 
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.firstAidKitDeletedSuccessfully, style: TextStyle()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); 
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _errorMessage = e.toString().contains('Exception:')
              ? e.toString().replaceAll('Exception: ', '')
              : 'Error deleting first aid kit: ${e.toString()}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage, style: TextStyle()),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _confirmDeleteMedication(String medicationId, String medicationName) async {
    final l10n = AppLocalizations.of(context)!;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.confirmDeletion, style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(l10n.firstAidKitDeleteAlert(medicationName), style: TextStyle()),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.delete, style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _deleteMedication(medicationId);
    }
  }

  Future<void> _deleteMedication(String medicationId) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      await _kitRepository.deleteMedication(medicationId, widget.kitId);
      await _loadKitDetailsAndContents(); 
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.medicationDeletedSuccessfully, style: TextStyle()),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Error deleting medication: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage, style: TextStyle()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _inputStyle(String label, String? suffix) =>
      InputDecoration(
        labelText: label,
        suffixText: suffix,
        filled: true,
        fillColor: AppTheme.primaryContainer,
        labelStyle: const TextStyle(color: AppTheme.primaryLabel, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primaryBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  Widget _sheetHandle() {
    final theme = Theme.of(context);
    return Center(
        child: Container(
          width: 44,
          height: 4,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  Widget _sheetTitle(String text, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Row(
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
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      );
  }

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
          String label, Color color, VoidCallback onPressed) =>
      SizedBox(
        width: double.infinity,
        height: 54,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.78)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
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
              style: TextStyle(
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
            style: TextStyle(color: Theme.of(ctx).colorScheme.onSurfaceVariant, fontSize: 15),
          ),
        ),
      );

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
              color: Theme.of(ctx).cardColor,
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
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: AppTheme.primary,
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
                        color: AppTheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppTheme.primaryBorder, width: 1.5),
                      ),
                      child: Row(children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 18, color: AppTheme.primaryLabel),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.newExpirationDate,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.primaryLabel,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                DateFormat('dd.MM.yyyy').format(date),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(ctx).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppTheme.primaryLabel),
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
        setState(() => _isLoading = true);
        try {
          await _kitRepository.refillMedication(
              medication.id,
              MedicationRefillDto(
                  addedQuantity: q, newExpirationDate: date));
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(l10n.medicationRefilledSuccess),
              backgroundColor: Colors.green));
          await _loadKitDetailsAndContents();
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(e.toString()), backgroundColor: Colors.red));
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          _kitDetails?.name ?? l10n.kitsContent,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.of(context).pop(true),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: theme.colorScheme.onSurface),
            onPressed: _isLoading ? null : _navigateToEditKit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _isLoading ? null : _confirmDeleteKit,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 16)))
              : _kitDetails == null
                  ? Center(child: Text(l10n.kitDetailsNotFound, style: TextStyle()))
                  : CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildKitInfoCard(l10n),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      l10n.medication,
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${_groupedMedications.length}',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (_medications.isNotEmpty) _buildSearchField(l10n),
                                if (_medications.isNotEmpty) const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                        if (_groupedMedications.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                l10n.noMedicationsFoundInThisKit,
                                style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(bottom: 80),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _buildGroupItem(_groupedMedications[index]),
                                childCount: _groupedMedications.length,
                              ),
                            ),
                          ),
                      ],
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditMedication(),
        backgroundColor: AppTheme.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildKitInfoCard(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: theme.shadowColor.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.medical_services_outlined, color: Colors.blue.shade400),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _kitDetails!.name,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'ID: ${_kitDetails!.uniqueNumber}',
                      style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, thickness: 1),
          ),
          _buildInfoPill(Icons.domain, _kitDetails!.departmentName),
          const SizedBox(height: 10),
          _buildInfoPill(Icons.meeting_room_outlined, _kitDetails!.roomName),
          const SizedBox(height: 10),
          _buildInfoPill(Icons.person_outline, '${_kitDetails!.responsibleUserFirstName} ${_kitDetails!.responsibleUserLastName}'),
        ],
      ),
    );
  }

  Widget _buildInfoPill(IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationListItem(MedicationDto medication) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final sColor = _statusColor(medication.status);
    final isLow = medication.quantity < medication.minimumQuantity;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Dismissible(
          key: Key(medication.id),
          direction: DismissDirection.horizontal,
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              if (medication.quantity > 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.quantityIsGreaterThan0Erorr(medication.name)),
                    backgroundColor: Colors.red,
                  ),
                );
                return false;
              }
              await _confirmDeleteMedication(medication.id, medication.name);
              return false;
            } else if (direction == DismissDirection.startToEnd) {
              await _navigateToAddEditMedication(medicationId: medication.id);
              return false;
            }
            return false;
          },
          background: _buildSwipeBackground(Icons.edit_outlined, Colors.blue.shade400, Alignment.centerLeft),
          secondaryBackground: _buildSwipeBackground(Icons.delete_outline, Colors.redAccent, Alignment.centerRight),
          child: Material(
            color: theme.cardColor,
            child: InkWell(
              onTap: () => _navigateToAddEditMedication(medicationId: medication.id),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left status stripe
                    Container(width: 4, color: sColor),
                    // Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: sColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Icon(Icons.vaccines_rounded, color: sColor, size: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    medication.name,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.onSurface),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                _buildCompactStatusTag(medication.status, l10n),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.inventory_2_outlined,
                                    size: 13,
                                    color: isLow ? Colors.red : theme.colorScheme.onSurfaceVariant),
                                const SizedBox(width: 5),
                                Text(
                                  '${medication.quantity} ${medication.unit.localizedName(context)}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isLow ? Colors.red : theme.colorScheme.onSurface),
                                ),
                                const SizedBox(width: 12),
                                Icon(Icons.calendar_today_outlined,
                                    size: 12,
                                    color: theme.colorScheme.onSurfaceVariant),
                                const SizedBox(width: 5),
                                Text(
                                  DateFormat('dd.MM.yyyy').format(medication.expirationDate),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            if (medication.quantity == 0) ...[
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                height: 34,
                                child: OutlinedButton.icon(
                                  onPressed: () => _showRefillDialog(medication, l10n),
                                  icon: const Icon(Icons.add_shopping_cart_rounded, size: 14),
                                  label: Text(l10n.refill, style: const TextStyle(fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.primary,
                                    padding: EdgeInsets.zero,
                                    side: const BorderSide(color: AppTheme.primaryBorder),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStatusTag(ExpirationStatus status, AppLocalizations l10n) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _statusText(status, l10n),
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildSearchField(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: l10n.searchMedicationHint,
          hintStyle: TextStyle(
              fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
          prefixIcon: Icon(Icons.search_rounded,
              color: theme.colorScheme.onSurfaceVariant, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded,
                      color: theme.colorScheme.onSurfaceVariant, size: 18),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Color _statusColor(ExpirationStatus status) {
    switch (status) {
      case ExpirationStatus.expired:
        return Colors.redAccent;
      case ExpirationStatus.critical:
        return Colors.orangeAccent;
      case ExpirationStatus.warning:
        return Colors.amber.shade600;
      case ExpirationStatus.good:
        return Colors.green;
    }
  }

  String _statusText(ExpirationStatus status, AppLocalizations l10n) {
    switch (status) {
      case ExpirationStatus.expired:
        return l10n.expired;
      case ExpirationStatus.critical:
        return l10n.critical;
      case ExpirationStatus.warning:
        return l10n.statusWarning;
      case ExpirationStatus.good:
        return l10n.statusGood;
    }
  }

  Widget _buildGroupItem(_MedicationGroup group) {
    if (!group.hasMultipleBatches) {
      return _buildMedicationListItem(group.visibleBatches.first);
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final sColor = _statusColor(group.worstStatus);
    final isExpanded = _expandedGroups.contains(group.name);
    final unitName = group.unit.localizedName(context);
    final isLow = group.isLow;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Material(
          color: theme.cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- Compact header (tap to expand/collapse) ----
              InkWell(
                onTap: () => setState(() {
                  if (isExpanded) {
                    _expandedGroups.remove(group.name);
                  } else {
                    _expandedGroups.add(group.name);
                  }
                }),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(width: 4, color: sColor),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: sColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Icon(Icons.vaccines_rounded, color: sColor, size: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    group.name,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.onSurface),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                _buildCompactStatusTag(group.worstStatus, l10n),
                              ]),
                              const SizedBox(height: 10),
                              Row(children: [
                                Icon(Icons.inventory_2_outlined,
                                    size: 13,
                                    color: isLow ? Colors.red : theme.colorScheme.onSurfaceVariant),
                                const SizedBox(width: 5),
                                Text(
                                  '${group.totalQuantity} $unitName',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isLow ? Colors.red : theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(Icons.calendar_today_outlined,
                                    size: 12, color: theme.colorScheme.onSurfaceVariant),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    DateFormat('dd.MM.yyyy').format(group.earliestExpiration),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isExpanded
                                            ? Icons.expand_less_rounded
                                            : Icons.expand_more_rounded,
                                        size: 14,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        l10n.batchesCount(group.visibleBatches.length),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ---- Expanded list of individual batches ----
              if (isExpanded) ...[
                Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.3)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                  child: Column(
                    children: [
                      for (int i = 0; i < group.visibleBatches.length; i++)
                        _buildBatchTile(group.visibleBatches[i], i + 1),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBatchTile(MedicationDto med, int index) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final sColor = _statusColor(med.status);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: sColor, width: 3)),
      ),
      child: InkWell(
        onTap: () => _navigateToAddEditMedication(medicationId: med.id),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('#$index',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.batchExpires(DateFormat('dd.MM.yyyy').format(med.expirationDate)),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: sColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _statusText(med.status, l10n),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: sColor),
                ),
              ),
            ]),
            const SizedBox(height: 6),
            Text(
              '${med.quantity} ${med.unit.localizedName(context)}',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToAddEditMedication(medicationId: med.id),
                    icon: const Icon(Icons.edit_outlined, size: 14),
                    label: Text(l10n.editMedication, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      padding: EdgeInsets.zero,
                      side: const BorderSide(color: AppTheme.primaryBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: med.quantity == 0
                      ? ElevatedButton.icon(
                          onPressed: () => _showRefillDialog(med, l10n),
                          icon: const Icon(Icons.add_shopping_cart_rounded, size: 14),
                          label: Text(l10n.refill, style: const TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryContainer,
                            foregroundColor: AppTheme.primary,
                            padding: EdgeInsets.zero,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        )
                      : OutlinedButton.icon(
                          onPressed: med.quantity > 0
                              ? () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.quantityIsGreaterThan0Erorr(med.name)),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              : () => _confirmDeleteMedication(med.id, med.name),
                          icon: const Icon(Icons.delete_outline, size: 14),
                          label: Text(l10n.delete, style: const TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            padding: EdgeInsets.zero,
                            side: BorderSide(color: Colors.red.shade200),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(IconData icon, Color color, Alignment alignment) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

/// Aggregated view of all batches of a medication that share the same name
/// AND unit. Batches with quantity == 0 are hidden when at least one
/// non-zero batch exists, so an old empty record stops triggering false
/// "out of stock" warnings the moment a fresh batch is added.
class _MedicationGroup {
  final String name;
  final List<MedicationDto> visibleBatches;
  final List<MedicationDto> allBatches;

  _MedicationGroup({
    required this.name,
    required this.visibleBatches,
    required this.allBatches,
  });

  bool get hasMultipleBatches => visibleBatches.length > 1;

  int get totalQuantity =>
      visibleBatches.fold<int>(0, (sum, m) => sum + m.quantity);

  int get totalMinimum =>
      visibleBatches.isEmpty ? 0 : visibleBatches.first.minimumQuantity;

  bool get isLow => totalQuantity < totalMinimum;

  MeasurementUnit get unit => visibleBatches.first.unit;

  DateTime get earliestExpiration => visibleBatches
      .map((m) => m.expirationDate)
      .reduce((a, b) => a.isBefore(b) ? a : b);

  ExpirationStatus get worstStatus {
    const order = {
      ExpirationStatus.expired: 4,
      ExpirationStatus.critical: 3,
      ExpirationStatus.warning: 2,
      ExpirationStatus.good: 1,
    };
    return visibleBatches
        .map((m) => m.status)
        .reduce((a, b) => order[a]! >= order[b]! ? a : b);
  }
}