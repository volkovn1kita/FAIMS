import 'package:flutter/material.dart';
import 'package:frontend/data/dtos/first_aid_kit_list_dto.dart';
import 'package:frontend/data/dtos/department_dto.dart';
import 'package:frontend/data/dtos/user_dto.dart';
import 'package:frontend/domain/repositories/first_aid_kit_repository.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/presentation/screens/add_edit_kit_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/data/services/first_aid_kit_api_service.dart';
import 'package:frontend/presentation/screens/kit_contents_screen.dart';

class ManageKitsScreen extends StatefulWidget {
  // НОВЕ: Додаємо необов'язковий параметр initialStatusFilter
  final String? initialStatusFilter;

  const ManageKitsScreen({
    super.key,
    this.initialStatusFilter, // Додаємо до конструктора
  });

  @override
  State<ManageKitsScreen> createState() => _ManageKitsScreenState();
}

class _ManageKitsScreenState extends State<ManageKitsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirstAidKitRepository _kitRepository = FirstAidKitRepository();
  final FirstAidKitApiService _apiService = FirstAidKitApiService();

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
    // НОВЕ: Встановлюємо initialStatusFilter, якщо він переданий
    _selectedStatusFilter = widget.initialStatusFilter;

    _loadFilterData().then((_) {
      if (mounted) {
        _loadKits();
      }
    });
  }

  @override
  void dispose() {
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

      if (!mounted) return; // <--- Додати тут
      setState(() {
        _responsibleUsers = loadedUsers;
        _departments = loadedDepartments;
      });
    } catch (e) {
      if (!mounted) return; // <--- І тут
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Failed to load filter data: ${e.toString()}';
      });
    } finally {
      if (!mounted) return; // <--- І ще тут
      setState(() {
        // _isLoading = false; <-- якщо потрібно
      });
    }
  }


  Future<void> _loadKits() async {
    setState(() {
      _isLoading = true;
      if (_errorMessage.isNotEmpty && !(_errorMessage.contains('Failed to load filter data'))) {
        _errorMessage = ''; // Clear error if it's not related to filters
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
        print('Error loading kits: $e');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    // TODO: Add Debouncer here to avoid making a request for every character
    _loadKits();
  }

  // === NAVIGATION AND ACTION METHODS ===

  // Opens the add/edit kit screen
  Future<void> _navigateToAddEditKit({String? kitId}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditKitScreen(kitId: kitId),
      ),
    );

    // If true is returned, it means changes were made, and the list needs to be updated
    if (result == true) {
      _loadKits();
    }
  }

  // Opens the kit contents screen
  Future<void> _navigateToKitContents(FirstAidKitListDto kit) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => KitContentsScreen(
          kitId: kit.id,
        ),
      ),
    );
    // After returning from KitContentsScreen, you might want to refresh the list
    // to reflect updated status (critical, expired counts) if contents were changed.
    if (result == true) { // Assume KitContentsScreen returns true if changes occurred
      _loadKits();
    }
  }

  // Dialog to confirm kit deletion
  Future<bool> _confirmDelete(String kitId, String kitName) async {
    final l10n = AppLocalizations.of(context)!;
    // --- НОВА ЛОГІКА ПЕРЕВІРКИ МЕДИКАМЕНТІВ ТУТ ---
    try {
      // *** ЗМІНА ТУТ: ВИКОРИСТОВУЄМО _kitRepository ЗАМІСТЬ _apiService ***
      final medications = await _kitRepository.getMedicationsForKit(kitId);
      if (medications.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.cannotDeleteKitBecauseIsNotEmpty(kitName,medications.length), style: GoogleFonts.notoSans()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        return false; // Заборонити видалення
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.errorCheckingMedicationsForKit}: ${e.toString().replaceAll('Exception: ', '')}', style: GoogleFonts.notoSans()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      return false; // Заборонити видалення через помилку
    }
    // --- КІНЕЦЬ НОВОЇ ЛОГІКИ ---

    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.deleteFirstAidKit, style: GoogleFonts.notoSans(fontWeight: FontWeight.bold)),
          content: Text(l10n.deleteKitAlert(kitName), style: GoogleFonts.notoSans()),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: Text(l10n.cancel, style: GoogleFonts.notoSans(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Виклик методу deleteKit з _apiService залишається без змін,
                  // бо ви використовуєте _apiService для API-операцій.
                  await _apiService.deleteKit(kitId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.kitDeleteSuccessfully(kitName), style: GoogleFonts.notoSans())),
                  );
                  Navigator.of(context).pop(true); // Confirm deletion
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${l10n.deletionError}: ${e.toString().replaceAll('Exception: ', '')}', style: GoogleFonts.notoSans())),
                  );
                  Navigator.of(context).pop(false); // Cancel
                }
              },
              child: Text(l10n.delete, style: GoogleFonts.notoSans(color: Colors.red)),
            ),
          ],
        );
      },
    ) ?? false;
  }

 @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Світлий фон
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.initialStatusFilter == l10n.needsAttention ? l10n.kitsNeedingAttention : l10n.manageKits,
          style: GoogleFonts.notoSans(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Панель пошуку та фільтрів на білому фоні
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                // === Пошук ===
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
                      fillColor: Colors.grey.shade100, // М'який фон замість рамки
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),

                // === Фільтри ===
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

          // Тінь під верхньою панеллю
          Container(
            height: 1,
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
            ),
          ),

          // === Список аптечок ===
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 16)))
                    : _kits.isEmpty
                        ? Center(
                            child: Text(
                              l10n.noKitsFoundMatchingYourCriteria,
                              style: GoogleFonts.notoSans(fontSize: 15, color: Colors.grey.shade500),
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
        backgroundColor: const Color.fromARGB(255, 143, 88, 225),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  // --- ВІДЖЕТИ ДЛЯ СУЧАСНОГО UI ---

  Widget _buildKitListItemCard(FirstAidKitListDto kit, AppLocalizations l10n) {
    // Визначаємо колір статусу для бічної смужки
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
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
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
                // Заголовок і статус
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kit.name,
                            style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'ID: ${kit.uniqueNumber}',
                            style: GoogleFonts.notoSans(fontSize: 12, color: Colors.grey.shade500),
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

                // Локація і відповідальний (згруповано)
                _buildCompactInfoRow(Icons.domain, '${kit.departmentName} • ${kit.roomName}'),
                const SizedBox(height: 6),
                _buildCompactInfoRow(Icons.person_outline, '${kit.responsibleUserFirstName} ${kit.responsibleUserLastName}'),
                
                const SizedBox(height: 16),

                // Міні-дашборд проблем замість великих чіпів
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniCounter(Icons.error_outline, 'Critical', kit.criticalItemsCount, Colors.redAccent),
                      _buildMiniCounter(Icons.calendar_today_outlined, 'Expired', kit.expiredItemsCount, Colors.orangeAccent),
                      _buildMiniCounter(Icons.inventory_2_outlined, 'Low', kit.lowQuantityItemsCount, Colors.amber.shade600),
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

  // Сучасний софт-бедж для статусу
  Widget _buildSoftBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.notoSans(fontSize: 12, color: color, fontWeight: FontWeight.w700),
      ),
    );
  }

  // Компактний рядок інформації
  Widget _buildCompactInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Мікро-лічильник для дашборда
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
          style: GoogleFonts.notoSans(
            fontSize: 12,
            color: textColor,
            fontWeight: hasIssues ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Сучасний "Pill" для фільтрів замість Dropdown із рамкою
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
        color: isActive ? const Color.fromARGB(255, 143, 88, 225).withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? const Color.fromARGB(255, 143, 88, 225) : Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue ?? options.first.value,
          icon: const Padding(
            padding: EdgeInsets.only(left: 4.0),
            child: Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          ),
          iconEnabledColor: isActive ? const Color.fromARGB(255, 143, 88, 225) : Colors.grey.shade600,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          style: GoogleFonts.notoSans(
            fontSize: 13, 
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? const Color.fromARGB(255, 143, 88, 225) : Colors.black87,
          ),
          onChanged: onChanged,
          items: options,
        ),
      ),
    );
  }

  // Фон для свайпу
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