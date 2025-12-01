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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          // Змінюємо заголовок залежно від фільтра
          widget.initialStatusFilter == l10n.needsAttention ? l10n.kitsNeedingAttention : l10n.manageKits,
          style: GoogleFonts.notoSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // === Search Panel ===
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchKitsByNameOrID,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          // =====================

          // === Filter Panel ===
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterDropdown(
                    context: context,
                    label: l10n.status,
                    icon: Icons.filter_list,
                    options: _statusOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    selectedValue: _selectedStatusFilter,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedStatusFilter = newValue;
                      });
                      _loadKits();
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterDropdown(
                    context: context,
                    label: l10n.responsible,
                    icon: Icons.person_outline,
                    options: [
                      const DropdownMenuItem(value: 'All', child: Text('All')),
                      ..._responsibleUsers.map((user) => DropdownMenuItem(
                            value: user.id,
                            child: Text(user.fullName),
                          )),
                    ],
                    selectedValue: _selectedResponsibleIdFilter,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedResponsibleIdFilter = newValue;
                      });
                      _loadKits();
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterDropdown(
                    context: context,
                    label: l10n.department,
                    icon: Icons.business_outlined,
                    options: [
                      const DropdownMenuItem(value: 'All', child: Text('All')),
                      ..._departments.map((department) => DropdownMenuItem(
                            value: department.id,
                            child: Text(department.name),
                          )),
                    ],
                    selectedValue: _selectedDepartmentIdFilter,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedDepartmentIdFilter = newValue;
                      });
                      _loadKits();
                    },
                  ),
                ],
              ),
            ),
          ),
          // ============================================

          const SizedBox(height: 16),

          // === Kits List ===
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 16)),
                      )
                    : _kits.isEmpty
                        ? Center(
                            child: Text(
                              l10n.noKitsFoundMatchingYourCriteria,
                              style: GoogleFonts.notoSans(fontSize: 16, color: Colors.grey.shade500),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: _kits.length,
                            itemBuilder: (context, index) {
                              final kit = _kits[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Dismissible(
                                  key: Key(kit.id),
                                  direction: DismissDirection.horizontal, // Allow horizontal swipes

                                  // Background for swipe to right (edit)
                                  background: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade600,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: const Icon(Icons.edit, color: Colors.white, size: 30),
                                  ),
                                  // Background for swipe to left (delete)
                                  secondaryBackground: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade600,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: const Icon(Icons.delete, color: Colors.white, size: 30),
                                  ),

                                  // Method called when the swipe is completed
                                  confirmDismiss: (direction) async {
                                    if (direction == DismissDirection.startToEnd) { // Swipe to right (edit)
                                      _navigateToAddEditKit(kitId: kit.id);
                                      return false; // Don't remove the item from the list, just navigate
                                    } else if (direction == DismissDirection.endToStart) { // Swipe to left (delete)
                                      // Викликаємо _confirmDelete, який тепер містить перевірку медикаментів
                                      return await _confirmDelete(kit.id, kit.name);
                                    }
                                    return false;
                                  },

                                  // onDismissed викликається ТІЛЬКИ якщо confirmDismiss повернув true
                                  // і елемент дійсно був відхилений
                                  onDismissed: (direction) {
                                    if (direction == DismissDirection.endToStart) {
                                      setState(() {
                                        _kits.removeWhere((item) => item.id == kit.id);
                                      });
                                    }
                                  },

                                  // Wrap the kit card in a GestureDetector for tap handling
                                  child: GestureDetector(
                                    onTap: () => _navigateToKitContents(kit), // <--- Tap opens kit contents
                                    child: _buildKitListItemCard(kit), // Your original kit display widget
                                  ),
                                ),
                              );
                            },
                          ),
          ),
          // ===================================================================
        ],
      ),
      // === Floating Action Button for adding a new kit ===
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditKit(), // <--- Call for adding
        backgroundColor: const Color.fromARGB(255, 173, 128, 245),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Renamed to avoid confusion with the item builder
  Widget _buildKitListItemCard(FirstAidKitListDto kit) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero, // Keep zero margin here as Dismissible's Padding handles spacing
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    kit.name,
                    style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusBadge(kit.statusBadge), // Display status
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.numbers, '${l10n.uniqueID}:', kit.uniqueNumber),
            _buildInfoRow(Icons.business, '${l10n.department}:', kit.departmentName),
            _buildInfoRow(Icons.meeting_room, '${l10n.room}:', kit.roomName),
            _buildInfoRow(Icons.person, '${l10n.responsible}:', '${kit.responsibleUserFirstName} ${kit.responsibleUserLastName}'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildKitInfoChip(
                  Icons.error_outline,
                  'Critical: ${kit.criticalItemsCount}',
                  kit.criticalItemsCount,
                  defaultColor: Colors.grey.shade200,
                  activeColor: Colors.red.shade600,
                ),
                _buildKitInfoChip(
                  Icons.calendar_today,
                  'Expired: ${kit.expiredItemsCount}',
                  kit.expiredItemsCount,
                  defaultColor: Colors.grey.shade200,
                  activeColor: Colors.deepOrange.shade600,
                ),
                _buildKitInfoChip(
                  Icons.low_priority,
                  'Low: ${kit.lowQuantityItemsCount}',
                  kit.lowQuantityItemsCount,
                  defaultColor: Colors.grey.shade200,
                  activeColor: Colors.amber.shade600,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    switch (status.toLowerCase()) {
      case 'good':
        badgeColor = Colors.green.shade400;
        break;
      case 'needs attention':
        badgeColor = Colors.orange.shade400;
        break;
      // case 'low stock':
      //   badgeColor = Colors.amber.shade400;
      //   break;
      default:
        badgeColor = Colors.grey.shade400;
    }
    return Chip(
      label: Text(
        status,
        style: GoogleFonts.notoSans(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: badgeColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildKitInfoChip(IconData icon, String labelText, int count, {required Color defaultColor, required Color activeColor}) {
    Color chipBackgroundColor = count > 0 ? activeColor : defaultColor;
    Color iconColor = count > 0 ? Colors.white : Colors.black87;
    Color textColor = count > 0 ? Colors.white : Colors.black87;

    return Chip(
      avatar: Icon(icon, size: 18, color: iconColor),
      label: Text(labelText, style: GoogleFonts.notoSans(fontSize: 12, color: textColor)),
      backgroundColor: chipBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Text(
            '$label ',
            style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.notoSans(fontSize: 14, color: Colors.grey.shade800),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required BuildContext context,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<String>> options,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue ?? options.first.value,
          icon: Icon(icon, color: Colors.grey.shade700),
          style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87),
          onChanged: (String? newValue) {
            onChanged(newValue);
          },
          items: options,
        ),
      ),
    );
  }
}