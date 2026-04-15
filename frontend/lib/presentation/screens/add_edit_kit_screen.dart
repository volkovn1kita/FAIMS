import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:faims/data/dtos/create_kit_dto.dart';
import 'package:faims/data/services/first_aid_kit_api_service.dart';
import 'package:faims/l10n/app_localizations.dart';
import 'package:faims/core/app_theme.dart';
import 'package:uuid/uuid.dart';
import 'package:faims/data/dtos/user_dto.dart';
import 'package:faims/data/dtos/department_dto.dart';
import 'package:faims/data/dtos/room_dto.dart';
import 'package:faims/data/dtos/update_kit_dto.dart';
import 'package:faims/domain/repositories/first_aid_kit_repository.dart';

class AddEditKitScreen extends StatefulWidget {
  final String? kitId;
  const AddEditKitScreen({super.key, this.kitId});

  @override
  State<AddEditKitScreen> createState() => _AddEditKitScreenState();
}

class _AddEditKitScreenState extends State<AddEditKitScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirstAidKitRepository _kitRepository = FirstAidKitRepository();
  final FirstAidKitApiService _firstAidKitApiService = FirstAidKitApiService();
  final Uuid _uuid = const Uuid();

  final Set<String> _occupiedUserIds = {};
  final Set<String> _occupiedRoomIds = {};

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _uniqueNumberController = TextEditingController();

  DepartmentDto? _selectedDepartment;
  RoomDto? _selectedRoom;
  UserDto? _selectedResponsibleUser;

  List<DepartmentDto> _departments = [];
  List<RoomDto> _roomsInSelectedDepartment = [];
  List<UserDto> _responsibleUsers = [];

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isRoomsLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadScreenData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _uniqueNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadScreenData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final loadedUsers = await _kitRepository.getResponsibleUsers();
      final loadedDepartments = await _kitRepository.getDepartments();
      final allKits = await _kitRepository.getFirstAidKits();

      _occupiedUserIds.clear();
      _occupiedRoomIds.clear();

      for (var kit in allKits) {
        if (widget.kitId != null && kit.id == widget.kitId) continue;
        _occupiedUserIds.add(kit.responsibleUserId);
        _occupiedRoomIds.add(kit.roomId);
      }

      setState(() {
        _responsibleUsers = loadedUsers;
        _departments = loadedDepartments;
      });

      if (widget.kitId != null) {
        final kitToEdit = await _kitRepository.getFirstAidKitById(widget.kitId!);
        _nameController.text = kitToEdit.name;
        _uniqueNumberController.text = kitToEdit.uniqueNumber;

        // Defensive lookups: any of these may legitimately miss if the
        // referenced entity was deleted, hidden by filters, or truncated by
        // pagination. Fall back to null and let the user pick again instead
        // of crashing the whole screen with "Bad state: No element".
        _selectedDepartment = _firstOrNull(
          _departments,
          (dep) => dep.id == kitToEdit.departmentId,
        );

        if (_selectedDepartment != null) {
          await _loadRoomsForDepartment(_selectedDepartment!.id);
          _selectedRoom = _firstOrNull(
            _roomsInSelectedDepartment,
            (room) => room.id == kitToEdit.roomId,
          );
        } else {
          developer.log(
            'Department ${kitToEdit.departmentId} not found when editing kit ${kitToEdit.id}',
            name: 'AddEditKitScreen',
          );
        }

        _selectedResponsibleUser = _firstOrNull(
          _responsibleUsers,
          (user) => user.id == kitToEdit.responsibleUserId,
        );

        if (_selectedResponsibleUser == null) {
          developer.log(
            'Responsible user ${kitToEdit.responsibleUserId} not found when editing kit ${kitToEdit.id}',
            name: 'AddEditKitScreen',
          );
        }
      } else {
        _generateUniqueNumber();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Failed to load data: ${e.toString()}';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Safe replacement for `firstWhere` — returns `null` instead of throwing
  /// `Bad state: No element` when no match is found.
  T? _firstOrNull<T>(Iterable<T> items, bool Function(T) test) {
    for (final item in items) {
      if (test(item)) return item;
    }
    return null;
  }

  Future<void> _loadRoomsForDepartment(String departmentId) async {
    setState(() {
      _isRoomsLoading = true;
      _roomsInSelectedDepartment = [];
      _selectedRoom = null;
    });
    try {
      final allRooms = await _firstAidKitApiService.getRoomsByDepartmentId(departmentId);
      setState(() {
        _roomsInSelectedDepartment = allRooms.where((room) {
          if (widget.kitId == null) return !_occupiedRoomIds.contains(room.id);
          return !_occupiedRoomIds.contains(room.id) || room.id == _selectedRoom?.id;
        }).toList();
      });
    } catch (e) {
      developer.log('Error loading rooms: $e', name: 'AddEditKitScreen');
    } finally {
      if (mounted) setState(() => _isRoomsLoading = false);
    }
  }

  void _generateUniqueNumber() {
    setState(() {
      _uniqueNumberController.text = 'KIT-${_uuid.v4().substring(0, 7).toUpperCase()}';
    });
  }

  Future<void> _saveKit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDepartment == null || _selectedRoom == null || _selectedResponsibleUser == null) {
      setState(() => _errorMessage = l10n.fillAllFieldsError);
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (widget.kitId == null) {
        final dto = CreateKitDto(
          uniqueNumber: _uniqueNumberController.text,
          name: _nameController.text,
          roomId: _selectedRoom!.id,
          responsibleUserId: _selectedResponsibleUser!.id,
        );
        await _firstAidKitApiService.createKit(dto);
      } else {
        final dto = UpdateKitDto(
          id: widget.kitId!,
          name: _nameController.text,
          roomId: _selectedRoom!.id,
          responsibleUserId: _selectedResponsibleUser!.id,
        );
        await _firstAidKitApiService.updateKit(widget.kitId!, dto);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteKit() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(l10n.deleteKitConfirmation(_nameController.text, _uniqueNumberController.text)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isSaving = true);
      try {
        await _firstAidKitApiService.deleteKit(widget.kitId!);
        if (mounted) Navigator.of(context).pop(true);
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.kitId == null ? l10n.addKitTitle : l10n.editKitTitle,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface, letterSpacing: -0.3),
        ),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(height: 1, decoration: BoxDecoration(boxShadow: [BoxShadow(color: theme.shadowColor.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))])),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_errorMessage.isNotEmpty) _buildErrorBanner(_errorMessage),
                          _buildSectionTitle(l10n.kitDetails),
                          _buildCard([
                            _buildTextField(
                              controller: _nameController,
                              label: l10n.kitName,
                              hint: l10n.kitNameHint,
                              icon: Icons.medication_rounded,
                              validator: (v) => (v == null || v.isEmpty) ? l10n.kitNameRequired : null,
                            ),
                            const SizedBox(height: 20),
                            _buildUniqueField(l10n),
                          ]),
                          const SizedBox(height: 24),
                          _buildSectionTitle(l10n.ownershipAndLocation),
                          _buildCard([
                            _buildDropdown<DepartmentDto>(
                              label: l10n.department,
                              value: _selectedDepartment,
                              items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d.name))).toList(),
                              icon: Icons.business_rounded,
                              onChanged: (val) {
                                setState(() => _selectedDepartment = val);
                                if (val != null) _loadRoomsForDepartment(val.id);
                              },
                            ),
                            const SizedBox(height: 20),
                            _buildDropdown<RoomDto>(
                              label: l10n.roomLocation,
                              value: _selectedRoom,
                              items: _roomsInSelectedDepartment.map((r) => DropdownMenuItem(value: r, child: Text(r.name))).toList(),
                              icon: Icons.meeting_room_rounded,
                              isLoading: _isRoomsLoading,
                              onChanged: _selectedDepartment == null ? null : (val) => setState(() => _selectedRoom = val),
                            ),
                            const SizedBox(height: 20),
                            _buildDropdown<UserDto>(
                              label: l10n.responsiblePerson,
                              value: _selectedResponsibleUser,
                              items: _responsibleUsers
                                  .where((u) => widget.kitId == null ? !_occupiedUserIds.contains(u.id) : !_occupiedUserIds.contains(u.id) || u.id == _selectedResponsibleUser?.id)
                                  .map((u) => DropdownMenuItem(value: u, child: Text(u.fullName)))
                                  .toList(),
                              icon: Icons.person_search_rounded,
                              onChanged: (val) => setState(() => _selectedResponsibleUser = val),
                            ),
                          ]),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            if (widget.kitId != null) ...[
              IconButton.filled(
                onPressed: _isSaving ? null : _deleteKit,
                icon: const Icon(Icons.delete_outline_rounded),
                style: IconButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red, fixedSize: const Size(56, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.primaryLight, AppTheme.primaryDark]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.35), blurRadius: 15, offset: const Offset(0, 8))],
                ),
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveKit,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: _isSaving
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text(widget.kitId == null ? l10n.save : l10n.update, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurfaceVariant, letterSpacing: 0.5)),
    );
  }

  Widget _buildCard(List<Widget> children) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: theme.shadowColor.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 8))]),
      child: Column(children: children),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required String hint, required IconData icon, String? Function(String?)? validator}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 22),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildUniqueField(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.uniqueNumber, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _uniqueNumberController,
          readOnly: true,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.fingerprint_rounded, color: theme.colorScheme.onSurfaceVariant, size: 22),
            suffixIcon: widget.kitId == null ? IconButton(icon: const Icon(Icons.refresh_rounded, color: AppTheme.primary), onPressed: _generateUniqueNumber) : null,
            filled: true,
            fillColor: AppTheme.primary.withValues(alpha: 0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({required String label, required T? value, required List<DropdownMenuItem<T>> items, required IconData icon, required void Function(T?)? onChanged, bool isLoading = false}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
          icon: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.expand_more_rounded),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 22),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade100)),
      child: Row(children: [const Icon(Icons.error_outline_rounded, color: Colors.red), const SizedBox(width: 8), Expanded(child: Text(message, style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w500)))]),
    );
  }
}