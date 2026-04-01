import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/presentation/screens/add_edit_kit_screen.dart';
import 'package:frontend/core/app_theme.dart';
import 'package:frontend/data/dtos/first_aid_kit_list_dto.dart';
import 'package:frontend/data/dtos/medication_dto.dart';
import 'package:frontend/domain/repositories/first_aid_kit_repository.dart';
import 'package:intl/intl.dart';
import 'package:frontend/data/dtos/expiration_status.dart';
import 'package:frontend/presentation/screens/add_edit_medication_screen.dart';
import 'package:frontend/core/extensions.dart';
import 'package:frontend/data/dtos/medication_refill_dto.dart';

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
  bool _isLoading = true;
  String _errorMessage = '';
  String _kitName = '';

  final _kitRepository = FirstAidKitRepository();

  @override
  void initState() {
    super.initState();
    _loadKitDetailsAndContents();
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
              child: Text(l10n.cancel, style: TextStyle(color: Colors.grey)),
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
              child: Text(l10n.cancel, style: TextStyle(color: Colors.grey)),
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
            style: const TextStyle(color: Colors.grey, fontSize: 15),
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
                    l10n.refillMedicationTitle(medication.name),
                    Icons.add_shopping_cart_rounded,
                    AppTheme.primary,
                  ),
                  const SizedBox(height: 20),
                  _infoRow(
                    Icons.info_outline_rounded,
                    '${l10n.available}: ${medication.quantity} ${medication.unit.name.capitalize()}',
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
                      medication.unit.name.capitalize(),
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
                            colorScheme: const ColorScheme.light(
                              primary: AppTheme.primary,
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
                                  color: Colors.black87,
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
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100, 
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _kitDetails?.name ?? l10n.kitsContent,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(true),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black87),
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
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${_medications.length}',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                        if (_medications.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                l10n.noMedicationsFoundInThisKit,
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(bottom: 80),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _buildMedicationListItem(_medications[index]),
                                childCount: _medications.length,
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'ID: ${_kitDetails!.uniqueNumber}',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
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
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationListItem(MedicationDto medication) {
    final l10n = AppLocalizations.of(context)!;
    Color statusColor;
    String statusText;

    switch (medication.status) {
      case ExpirationStatus.expired:
        statusColor = Colors.redAccent;
        statusText = l10n.expired;
        break;
      case ExpirationStatus.critical:
        statusColor = Colors.orangeAccent;
        statusText = l10n.critical;
        break;
      case ExpirationStatus.warning:
        statusColor = Colors.amber.shade600;
        statusText = l10n.statusWarning;
        break;
      case ExpirationStatus.good:
        statusColor = Colors.green;
        statusText = l10n.statusGood;
        break;
    }

    bool isLowQuantity = medication.quantity < medication.minimumQuantity;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
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
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
            ],
            border: Border(left: BorderSide(color: statusColor, width: 4)),
          ),
          child: InkWell(
            onTap: () => _navigateToAddEditMedication(medicationId: medication.id),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          medication.name,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 16, color: isLowQuantity ? Colors.red : Colors.grey.shade500),
                      const SizedBox(width: 6),
                      Text(
                        '${medication.quantity} ${medication.unit.name.capitalize()}',
                        style: TextStyle(
                          fontSize: 14, 
                          fontWeight: FontWeight.w600, 
                          color: isLowQuantity ? Colors.red : Colors.black87
                        ),
                      ),
                      if (isLowQuantity) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.error_outline, size: 14, color: Colors.red.shade400),
                      ],
                      const Spacer(),
                      Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('dd.MM.yyyy').format(medication.expirationDate),
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  if (medication.quantity == 0) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () => _showRefillDialog(medication, l10n),
                        icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                        label: Text(l10n.refill),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: const BorderSide(color: AppTheme.primaryBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
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