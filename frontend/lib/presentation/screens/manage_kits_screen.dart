import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/data/dtos/first_aid_kit_list_dto.dart';
import 'package:frontend/data/dtos/department_dto.dart';
import 'package:frontend/data/dtos/user_dto.dart';
import 'package:frontend/domain/repositories/first_aid_kit_repository.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/presentation/screens/add_edit_kit_screen.dart';
import 'package:frontend/core/app_theme.dart';
import 'package:frontend/data/services/first_aid_kit_api_service.dart';
import 'package:frontend/presentation/screens/kit_contents_screen.dart';

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

  final List<String> _statusOptions = ['All', 'Good', 'Needs Attention'];
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
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.initialStatusFilter == l10n.needsAttention ? l10n.kitsNeedingAttention : l10n.manageKits,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.searchKitsByNameOrID,
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
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
                        options: _statusOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
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
                          const DropdownMenuItem(value: 'All', child: Text('All')),
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
                          const DropdownMenuItem(value: 'All', child: Text('All')),
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
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
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
                              style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
        border: Border(left: BorderSide(color: statusColor, width: 4)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToKitContents(kit),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kit.name,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${l10n.uniqueID}: ${kit.uniqueNumber}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildSoftBadge(kit.statusBadge, statusColor),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, thickness: 1),
                ),
                _buildCompactInfoRow(Icons.domain, '${kit.departmentName} • ${kit.roomName}'),
                const SizedBox(height: 6),
                _buildCompactInfoRow(Icons.person_outline, '${kit.responsibleUserFirstName} ${kit.responsibleUserLastName}'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniCounter(Icons.error_outline, l10n.critical, kit.criticalItemsCount, Colors.redAccent),
                      _buildMiniCounter(Icons.calendar_today_outlined, l10n.expired, kit.expiredItemsCount, Colors.orangeAccent),
                      _buildMiniCounter(Icons.inventory_2_outlined, l10n.lowStock, kit.lowQuantityItemsCount, Colors.amber.shade600),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniCounter(IconData icon, String label, int count, Color activeColor) {
    final hasIssues = count > 0;
    final color = hasIssues ? activeColor : Colors.grey.shade400;
    final textColor = hasIssues ? activeColor : Colors.grey.shade500;

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '$count $label',
          style: TextStyle(
            fontSize: 12,
            color: textColor,
            fontWeight: hasIssues ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterPill({
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<String>> options,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    bool isActive = selectedValue != null && selectedValue != 'All';
    
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? AppTheme.primary : Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue ?? options.first.value,
          icon: const Padding(
            padding: EdgeInsets.only(left: 4.0),
            child: Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          ),
          iconEnabledColor: isActive ? AppTheme.primary : Colors.grey.shade600,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          style: TextStyle(
            fontSize: 13, 
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? AppTheme.primary : Colors.black87,
          ),
          onChanged: onChanged,
          items: options,
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