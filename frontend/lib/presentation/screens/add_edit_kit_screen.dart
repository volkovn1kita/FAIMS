import 'package:flutter/material.dart';
import 'package:frontend/data/dtos/create_kit_dto.dart';
import 'package:frontend/data/services/first_aid_kit_api_service.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:frontend/data/dtos/user_dto.dart';
import 'package:frontend/data/dtos/department_dto.dart';
import 'package:frontend/data/dtos/room_dto.dart';
import 'package:frontend/data/dtos/update_kit_dto.dart';
import 'package:frontend/domain/repositories/first_aid_kit_repository.dart';

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
  final TextEditingController _auditDateController = TextEditingController();
  

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
  String _roomsErrorMessage = '';
  DateTime? _lastAuditDate;
  

  @override
  void initState() {
    super.initState();
    _loadScreenData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _uniqueNumberController.dispose();
    _auditDateController.dispose();
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
        _selectedDepartment = _departments.firstWhere(
          (dep) => dep.id == kitToEdit.departmentId,
          orElse: () => throw Exception('Department not found for kit: ${kitToEdit.departmentId}'),
        );
        await _loadRoomsForDepartment(_selectedDepartment!.id);
        _selectedRoom = _roomsInSelectedDepartment.firstWhere(
          (room) => room.id == kitToEdit.roomId,
          orElse: () => throw Exception('Room not found for kit: ${kitToEdit.roomId}'),
        );
        _selectedResponsibleUser = _responsibleUsers.firstWhere(
          (user) => user.id == kitToEdit.responsibleUserId,
          orElse: () => throw Exception('Responsible user not found for kit: ${kitToEdit.responsibleUserId}'),
        );
        _lastAuditDate = kitToEdit.lastAuditDate;
        if (_lastAuditDate != null) {
          _auditDateController.text = DateFormat('yyyy-MM-dd').format(_lastAuditDate!);
        }
      } else {
        _generateUniqueNumber();
        _lastAuditDate = DateTime.now();
        _auditDateController.text = DateFormat('yyyy-MM-dd').format(_lastAuditDate!);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Failed to load initial data: ${e.toString()}';
        print('Error loading initial data: $e');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRoomsForDepartment(String departmentId) async {
    setState(() {
      _isRoomsLoading = true;
      _roomsErrorMessage = '';
      _roomsInSelectedDepartment = [];
      _selectedRoom = null;
    });
    try {
      final allRoomsInDepartment = await _firstAidKitApiService.getRoomsByDepartmentId(departmentId);
      setState(() {
        _roomsInSelectedDepartment = allRoomsInDepartment.where((room) {
          if (widget.kitId == null) return !_occupiedRoomIds.contains(room.id);
          return !_occupiedRoomIds.contains(room.id) || room.id == _selectedRoom?.id;
        }).toList();

        if (_selectedRoom != null && !_roomsInSelectedDepartment.any((room) => room.id == _selectedRoom!.id)) {
          _selectedRoom = null;
        }
      });
    } catch (e) {
      setState(() {
        _roomsErrorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Failed to load rooms for department: ${e.toString()}';
        print('Error loading rooms: $e');
      });
    } finally {
      setState(() {
        _isRoomsLoading = false;
      });
    }
  }

  void _generateUniqueNumber() {
    String newUniqueNumber = 'KIT-${_uuid.v4().substring(0, 7).toUpperCase()}';
    _uniqueNumberController.text = newUniqueNumber;
  }

  Future<void> _saveKit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDepartment == null || _selectedRoom == null || _selectedResponsibleUser == null) {
      setState(() {
        _errorMessage = l10n.fillAllFieldsError;
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = '';
    });

    try {
      if (widget.kitId == null) {
        final createKitData = CreateKitDto(
          uniqueNumber: _uniqueNumberController.text,
          name: _nameController.text,
          roomId: _selectedRoom!.id,
          responsibleUserId: _selectedResponsibleUser!.id,
        );
        await _firstAidKitApiService.createKit(createKitData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.kitAddedSuccess)),
        );
      } else {
        final updateKitData = UpdateKitDto(
          id: widget.kitId!,
          name: _nameController.text,
          roomId: _selectedRoom!.id,
          responsibleUserId: _selectedResponsibleUser!.id,
        );
        await _firstAidKitApiService.updateKit(widget.kitId!, updateKitData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('First aid kit successfully updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Error saving first aid kit: ${e.toString()}';
        print('Error saving kit: $e');
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _deleteKit() async {
    final texts = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Kit'),
          content: Text(texts.deleteKitConfirmation(_nameController.text,_uniqueNumberController.text)),
          actions: <Widget>[
            TextButton(
              child: Text(texts.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(texts.delete),
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  _isSaving = true;
                  _errorMessage = '';
                });
                try {
                  await _firstAidKitApiService.deleteKit(widget.kitId!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(texts.kitDeleteSuccess)),
                  );
                  Navigator.of(context).pop(true);
                } catch (e) {
                  setState(() {
                    _errorMessage = e.toString().contains('Exception:')
                        ? e.toString().replaceAll('Exception: ', '')
                        : 'Error deleting kit: ${e.toString()}';
                    print('Error deleting kit: $e');
                  });
                } finally {
                  setState(() {
                    _isSaving = false;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          widget.kitId == null ?  l10n.addKitTitle : l10n.editKitTitle,
          style: GoogleFonts. notoSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 16)))
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(context, l10n.kitDetails),
                        _buildRequiredLabel(context, l10n.kitName),
                        _buildTextFormField(
                          controller: _nameController,
                          hintText: l10n.kitNameHint,
                          maxLength: 50,
                          validator: (value) {
                            if (value == null || value.isEmpty) return l10n.kitNameRequired;
                            if (value.length < 3) return l10n.kitNameMinChars;
                            return null;
                          },
                        ),
                        _buildHelperText(l10n.kitNameHelper),
                        const SizedBox(height: 16),
                        _buildTextWithRequiredLabel(context, l10n.uniqueNumber, isRequired: false),
                        _buildUniqueNumberField(),
                        _buildHelperText(l10n.uniqueNumberHelper),
                        const SizedBox(height: 32),
                        _buildSectionHeader(context, l10n.ownershipAndLocation),
                        _buildRequiredLabel(context, l10n.department),
                        _buildDropdownButtonFormField<DepartmentDto>(
                          value: _selectedDepartment,
                          hintText: l10n.selectDepartmentHint,
                          items: _departments.map((dep) => DropdownMenuItem(value: dep, child: Text(dep.name))).toList(),
                          onChanged: (newValue) async {
                            setState(() {
                              _selectedDepartment = newValue;
                              _selectedRoom = null;
                              _roomsInSelectedDepartment = [];
                            });
                            if (newValue != null) await _loadRoomsForDepartment(newValue.id);
                          },
                          validator: (value) => value == null ? l10n.departmentRequired : null,
                        ),
                        const SizedBox(height: 16),
                        _buildRequiredLabel(context, l10n.roomLocation),
                        _buildDropdownButtonFormField<RoomDto>(
                          value: _selectedRoom,
                          hintText: _selectedDepartment == null ? l10n.roomHintPreselect : l10n.roomHintSelect,
                          items: _roomsInSelectedDepartment.map((room) => DropdownMenuItem(value: room, child: Text(room.name))).toList(),
                          onChanged: _selectedDepartment == null || _isRoomsLoading ? null : (newValue) => setState(() => _selectedRoom = newValue),
                          validator: (value) => value == null && _selectedDepartment != null ? l10n.roomRequired : null,
                        ),
                        if (_isRoomsLoading) const Padding(padding: EdgeInsets.only(top: 8.0), child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                        if (_roomsErrorMessage.isNotEmpty)
                          Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(_roomsErrorMessage, style: const TextStyle(color: Colors.red, fontSize: 14))),
                        _buildHelperText(_selectedDepartment == null ? l10n.roomHelperPreselect : l10n.roomHelperOptions),
                        const SizedBox(height: 16),
                        _buildRequiredLabel(context, l10n.responsiblePerson),
                        _buildDropdownButtonFormField<UserDto>(
                          value: _selectedResponsibleUser,
                          hintText: l10n.responsiblePersonHint,
                          items: _responsibleUsers
                              .where((user) => widget.kitId == null ? !_occupiedUserIds.contains(user.id) : !_occupiedUserIds.contains(user.id) || user.id == _selectedResponsibleUser?.id)
                              .map((user) => DropdownMenuItem(value: user, child: Text(user.fullName)))
                              .toList(),
                          onChanged: (newValue) => setState(() => _selectedResponsibleUser = newValue),
                          validator: (value) => value == null ? l10n.responsiblePersonRequired : null,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: _isLoading || _isSaving
          ? null
          : BottomAppBar(
              elevation: 8.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.kitId != null)
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: _isSaving ? null : _deleteKit,
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n.delete, style: GoogleFonts. notoSans(color: Colors.red, fontWeight: FontWeight.bold))),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ),
                    if (widget.kitId != null) const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveKit,
                          icon: _isSaving
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.save, color: Colors.white),
                          label: FittedBox(fit: BoxFit.scaleDown, child: Text(widget.kitId == null ? l10n.save : l10n.update, style: GoogleFonts. notoSans(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold))),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 173, 128, 245),
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(title, style: GoogleFonts. notoSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildRequiredLabel(BuildContext context, String label) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Text(label, style: GoogleFonts. notoSans(fontSize: 14, color: Colors.black87)),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(4)),
            child: Text(l10n.fieldRequired, style: GoogleFonts. notoSans(fontSize: 10, color: Colors.red.shade700, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextWithRequiredLabel(BuildContext context, String label, {bool isRequired = true}) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Text(label, style: GoogleFonts. notoSans(fontSize: 14, color: Colors.black87)),
          if (isRequired) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(4)),
              child: Text(l10n.fieldRequired, style: GoogleFonts. notoSans(fontSize: 10, color: Colors.red.shade700, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextFormField({required TextEditingController controller, String? hintText, int? maxLength, FormFieldValidator<String>? validator}) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      decoration: InputDecoration(hintText: hintText, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), counterText: ''),
      validator: validator,
    );
  }

  Widget _buildUniqueNumberField() {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: _uniqueNumberController,
      readOnly: true,
      decoration: InputDecoration(
        hintText: 'KIT-000123',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.purple.shade100, borderRadius: BorderRadius.circular(8)),
              child: Text(l10n.autoGenerated, style: GoogleFonts. notoSans(fontSize: 12, color: Colors.purple.shade700)),
            ),
            IconButton(icon: const Icon(Icons.refresh), onPressed: () {
              _generateUniqueNumber();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Unique Number regenerated!")));
            }),
          ],
        ),
      ),
      validator: (value) => (value == null || value.isEmpty) ? "Unique Number regenerated!" : null,
    );
  }

  Widget _buildDropdownButtonFormField<T>({required T? value, required String hintText, required List<DropdownMenuItem<T>> items, required ValueChanged<T?>? onChanged, FormFieldValidator<T>? validator}) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(hintText: hintText, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16)),
      items: items,
      onChanged: onChanged,
      validator: validator,
      icon: const Icon(Icons.keyboard_arrow_down),
      isExpanded: true,
    );
  }

  Widget _buildHelperText(String text) {
    return Padding(padding: const EdgeInsets.only(top: 4.0, left: 12.0), child: Text(text, style: GoogleFonts. notoSans(fontSize: 12, color: Colors.grey.shade600)));
  }
}
