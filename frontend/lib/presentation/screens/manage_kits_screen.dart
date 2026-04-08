import 'dart:async';
import 'package:flutter/material.dart';
import 'package:faims/data/dtos/first_aid_kit_list_dto.dart';
import 'package:faims/data/dtos/department_dto.dart';
import 'package:faims/data/dtos/user_dto.dart';
import 'package:faims/domain/repositories/first_aid_kit_repository.dart';
import 'package:faims/l10n/app_localizations.dart';
import 'package:faims/presentation/screens/add_edit_kit_screen.dart';
import 'package:faims/core/app_theme.dart';
import 'package:faims/data/services/first_aid_kit_api_service.dart';
import 'package:faims/presentation/screens/kit_contents_screen.dart';

class ManageKitsScreen extends StatefulWidget {
  final String? initialStatusFilter;

  const ManageKitsScreen({
    super.key,
    this.initialStatusFilter,
  });

  @override
  State<ManageKitsScreen> createState() => _ManageKitsScreenState();
}

class _ManageKitsScreenState extends State<ManageKitsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirstAidKitRepository _kitRepository = FirstAidKitRepository();
  final FirstAidKitApiService _apiService = FirstAidKitApiService();
  Timer? _debounce;

  List<FirstAidKitListDto> _kits = [];
  bool _isLoading = true;
  String _errorMessage = '';

  String? _selectedStatusFilter;
  String? _selectedResponsibleIdFilter;
  String? _selectedDepartmentIdFilter;

  // Status filter values sent to backend (English)
  static const _statusValueAll = 'All';
  static const _statusValueGood = 'Good';
  static const _statusValueNeedsAttention = 'Needs Attention';

  List<UserDto> _responsibleUsers = [];
  List<DepartmentDto> _departments = [];

  @override
  void initState() {
    super.initState();
    _selectedStatusFilter = widget.initialStatusFilter;

    _loadFilterData().then((_) {
      if (mounted) {
        _loadKits();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFilterData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final loadedUsers = await _kitRepository.getResponsibleUsers();
      final loadedDepartments = await _kitRepository.getDepartments();

      if (!mounted) return;
      setState(() {
        _responsibleUsers = loadedUsers;
        _departments = loadedDepartments;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Failed to load filter data: ${e.toString()}';
      });
    }
  }

  Future<void> _loadKits() async {
    setState(() {
      _isLoading = true;
      if (_errorMessage.isNotEmpty && !(_errorMessage.contains('Failed to load filter data'))) {
        _errorMessage = '';
      }
    });
    try {
      final List<FirstAidKitListDto> loadedKits = await _kitRepository.getFirstAidKits(
        searchTerm: _searchController.text,
        statusFilter: _selectedStatusFilter == 'All' || _selectedStatusFilter == null ? null : _selectedStatusFilter,
        responsibleUserId: _selectedResponsibleIdFilter == 'All' || _selectedResponsibleIdFilter == null ? null : _selectedResponsibleIdFilter,
        departmentId: _selectedDepartmentIdFilter == 'All' || _selectedDepartmentIdFilter == null ? null : _selectedDepartmentIdFilter,
      );
      setState(() {
        _kits = loadedKits;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Failed to load kits: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _loadKits();
    });
  }

  Future<void> _navigateToAddEditKit({String? kitId}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditKitScreen(kitId: kitId),
      ),
    );

    if (result == true) {
      _loadKits();
    }
  }

  Future<void> _navigateToKitContents(FirstAidKitListDto kit) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => KitContentsScreen(
          kitId: kit.id,
        ),
      ),
    );
    if (result == true) {
      _loadKits();
    }
  }

  Future<bool> _confirmDelete(String kitId, String kitName) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final medications = await _kitRepository.getMedicationsForKit(kitId);
      if (!mounted) return false;

      if (medications.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.cannotDeleteKitBecauseIsNotEmpty(kitName, medications.length.toString()), style: TextStyle()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        return false;
      }
    } catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.errorCheckingMedicationsForKit}: ${e.toString().replaceAll('Exception: ', '')}', style: TextStyle()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      return false;
    }

    final dialogResult = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.deleteFirstAidKit, style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(l10n.deleteKitAlert(kitName), style: TextStyle()),
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

    if (dialogResult == true) {
      try {
        await _apiService.deleteKit(kitId);
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.kitDeleteSuccessfully(kitName), style: TextStyle())),
        );
        return true;
      } catch (e) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.deletionError}: ${e.toString().replaceAll('Exception: ', '')}', style: TextStyle())),
        );
        return false;
      }
    }
    
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.initialStatusFilter == l10n.needsAttention ? l10n.kitsNeedingAttention : l10n.manageKits,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.searchKitsByNameOrID,
                      hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 15),
                      prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.brightness == Brightness.light
                          ? Colors.grey.shade100
                          : theme.colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      _buildFilterPill(
                        label: l10n.status,
                        icon: Icons.filter_alt_outlined,
                        options: [
                          DropdownMenuItem(value: _statusValueAll, child: Text(l10n.all)),
                          DropdownMenuItem(value: _statusValueGood, child: Text(l10n.statusGood)),
                          DropdownMenuItem(value: _statusValueNeedsAttention, child: Text(l10n.needsAttention)),
                        ],
                        selectedValue: _selectedStatusFilter,
                        onChanged: (newValue) {
                          setState(() => _selectedStatusFilter = newValue);
                          _loadKits();
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterPill(
                        label: l10n.responsible,
                        icon: Icons.person_outline,
                        options: [
                          DropdownMenuItem(value: _statusValueAll, child: Text(l10n.all)),
                          ..._responsibleUsers.map((user) => DropdownMenuItem(value: user.id, child: Text(user.fullName))),
                        ],
                        selectedValue: _selectedResponsibleIdFilter,
                        onChanged: (newValue) {
                          setState(() => _selectedResponsibleIdFilter = newValue);
                          _loadKits();
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterPill(
                        label: l10n.department,
                        icon: Icons.domain,
                        options: [
                          DropdownMenuItem(value: _statusValueAll, child: Text(l10n.all)),
                          ..._departments.map((dep) => DropdownMenuItem(value: dep.id, child: Text(dep.name))),
                        ],
                        selectedValue: _selectedDepartmentIdFilter,
                        onChanged: (newValue) {
                          setState(() => _selectedDepartmentIdFilter = newValue);
                          _loadKits();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: theme.shadowColor.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 16)))
                    : _kits.isEmpty
                        ? Center(
                            child: Text(
                              l10n.noKitsFoundMatchingYourCriteria,
                              style: TextStyle(fontSize: 15, color: theme.colorScheme.onSurfaceVariant),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16.0).copyWith(bottom: 80),
                            itemCount: _kits.length,
                            itemBuilder: (context, index) {
                              final kit = _kits[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Dismissible(
                                    key: Key(kit.id),
                                    direction: DismissDirection.horizontal,
                                    background: _buildSwipeBackground(Icons.edit_outlined, Colors.blue.shade400, Alignment.centerLeft),
                                    secondaryBackground: _buildSwipeBackground(Icons.delete_outline, Colors.redAccent, Alignment.centerRight),
                                    confirmDismiss: (direction) async {
                                      if (direction == DismissDirection.startToEnd) {
                                        _navigateToAddEditKit(kitId: kit.id);
                                        return false;
                                      } else if (direction == DismissDirection.endToStart) {
                                        return await _confirmDelete(kit.id, kit.name);
                                      }
                                      return false;
                                    },
                                    onDismissed: (direction) {
                                      if (direction == DismissDirection.endToStart) {
                                        setState(() => _kits.removeWhere((item) => item.id == kit.id));
                                      }
                                    },
                                    child: _buildKitListItemCard(kit, l10n),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditKit(),
        backgroundColor: AppTheme.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildKitListItemCard(FirstAidKitListDto kit, AppLocalizations l10n) {
    final theme = Theme.of(context);
    Color statusColor;
    switch (kit.statusBadge.toLowerCase()) {
      case 'good':
        statusColor = Colors.green;
        break;
      case 'needs attention':
        statusColor = Colors.orangeAccent;
        break;
      default:
        statusColor = Colors.grey.shade400;
    }

    final bool hasIssues = kit.criticalItemsCount > 0 || kit.expiredItemsCount > 0 || kit.lowQuantityItemsCount > 0;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToKitContents(kit),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 4, color: statusColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    kit.name,
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    kit.uniqueNumber,
                                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant, fontFamily: 'monospace'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildSoftBadge(_translateStatus(kit.statusBadge, l10n), statusColor),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Divider(height: 1, thickness: 0.5, color: theme.dividerColor),
                        ),
                        _buildCompactInfoRow(Icons.domain, '${kit.departmentName} • ${kit.roomName}'),
                        const SizedBox(height: 5),
                        _buildCompactInfoRow(Icons.person_outline, '${kit.responsibleUserFirstName} ${kit.responsibleUserLastName}'),
                        if (hasIssues) ...[
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (kit.expiredItemsCount > 0) ...[
                                _buildIssueChip(l10n.expired, kit.expiredItemsCount, const Color(0xFFE53935)),
                                const SizedBox(width: 6),
                              ],
                              if (kit.criticalItemsCount > 0) ...[
                                _buildIssueChip(l10n.critical, kit.criticalItemsCount, const Color(0xFFF57C00)),
                                const SizedBox(width: 6),
                              ],
                              if (kit.lowQuantityItemsCount > 0)
                                _buildIssueChip(l10n.lowStock, kit.lowQuantityItemsCount, const Color(0xFFF9A825)),
                            ],
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
    );
  }

  String _translateStatus(String backendStatus, AppLocalizations l10n) {
    switch (backendStatus.toLowerCase()) {
      case 'good':
        return l10n.statusGood;
      case 'needs attention':
        return l10n.needsAttention;
      default:
        return backendStatus;
    }
  }

  Widget _buildSoftBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildCompactInfoRow(IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildIssueChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            '$label $count',
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600, height: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill({
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<String>> options,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    bool isActive = selectedValue != null && selectedValue != 'All';

    return Container(
      height: 36,
      padding: const EdgeInsets.only(left: 10, right: 4),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary.withValues(alpha: 0.1) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? AppTheme.primary : theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isActive ? AppTheme.primary : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue ?? options.first.value,
              icon: const Padding(
                padding: EdgeInsets.only(left: 2.0),
                child: Icon(Icons.keyboard_arrow_down_rounded, size: 18),
              ),
              iconEnabledColor: isActive ? AppTheme.primary : theme.colorScheme.onSurfaceVariant,
              dropdownColor: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? AppTheme.primary : theme.colorScheme.onSurface,
              ),
              onChanged: onChanged,
              items: options,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeBackground(IconData icon, Color color, Alignment alignment) {
    return Container(
      color: color,
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