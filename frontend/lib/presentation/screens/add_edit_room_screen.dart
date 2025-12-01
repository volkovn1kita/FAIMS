import 'package:flutter/material.dart';
import 'package:frontend/data/dtos/department_dto.dart'; // Для вибору департаменту
import 'package:frontend/data/dtos/room_create_dto.dart';
import 'package:frontend/data/dtos/room_update_dto.dart';
import 'package:frontend/domain/repositories/department_repository.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/l10n/app_localizations.dart';

class AddEditRoomScreen extends StatefulWidget {
  final String? roomId; // Null for add, not null for edit
  final String? initialName; // Initial name for editing
  final String? initialDepartmentId; // Initial department for editing
  final String? currentDepartmentId; // Department ID if adding a room to a specific department

  const AddEditRoomScreen({
    super.key,
    this.roomId,
    this.initialName,
    this.initialDepartmentId,
    this.currentDepartmentId,
  });

  @override
  State<AddEditRoomScreen> createState() => _AddEditRoomScreenState();
}

class _AddEditRoomScreenState extends State<AddEditRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final DepartmentRepository _departmentRepository = DepartmentRepository();
  bool _isLoading = false;
  String _errorMessage = '';
  List<DepartmentDto> _departments = [];
  DepartmentDto? _selectedDepartment;

  bool get isEditing => widget.roomId != null;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
    if (isEditing) {
      _nameController.text = widget.initialName ?? '';
    }
  }

  Future<void> _loadDepartments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final departments = await _departmentRepository.getAllDepartments();
      if (!mounted) return;
      setState(() {
        _departments = departments;
        if (isEditing) {
          _selectedDepartment = _departments.firstWhere(
            (dept) => dept.id == widget.initialDepartmentId,
            orElse: () => _departments.first, // Fallback if not found
          );
        } else if (widget.currentDepartmentId != null) {
          // If adding a room to a specific department, pre-select it
          _selectedDepartment = _departments.firstWhere(
            (dept) => dept.id == widget.currentDepartmentId,
            orElse: () => _departments.first,
          );
        } else {
          _selectedDepartment = _departments.first; // Default to first department
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().contains('Exception:')
              ? e.toString().replaceAll('Exception: ', '')
              : 'Failed to load departments: ${e.toString()}';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage, style: GoogleFonts.notoSans()),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveRoom() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedDepartment == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.selectDepartment, style: GoogleFonts.notoSans()),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (isEditing) {
        final updateDto = RoomUpdateDto(
          id: widget.roomId!,
          name: _nameController.text.trim(),
          departmentId: _selectedDepartment!.id,
        );
        await _departmentRepository.updateRoom(widget.roomId!, updateDto);
        if (mounted) {
          Navigator.of(context).pop(true); // Indicate success
        }
      } else {
        final createDto = RoomCreateDto(
          name: _nameController.text.trim(),
          departmentId: _selectedDepartment!.id,
        );
        await _departmentRepository.addRoom(createDto);
        if (mounted) {
          Navigator.of(context).pop(true); // Indicate success
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? l10n.roomUpdatedSuccessfully : l10n.roomAddedSuccessfully,
              style: GoogleFonts.notoSans(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().contains('Exception:')
              ? e.toString().replaceAll('Exception: ', '')
              : 'Failed to save room: ${e.toString()}';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage, style: GoogleFonts.notoSans()),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? l10n.editRoom : l10n.addRoom,
          style: GoogleFonts.notoSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading && _departments.isEmpty // Show loading indicator if departments are still loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.roomName,
                        hintText: l10n.roomNameHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.meeting_room),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.roomNameMissError;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<DepartmentDto>(
                      initialValue: _selectedDepartment,
                      decoration: InputDecoration(
                        labelText: l10n.department,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.business),
                      ),
                      items: _departments.map((department) {
                        return DropdownMenuItem(
                          value: department,
                          child: Text(
                            department.name,
                            style: GoogleFonts.notoSans(),
                          ),
                        );
                      }).toList(),
                      onChanged: (DepartmentDto? newValue) {
                        setState(() {
                          _selectedDepartment = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return l10n.selectDepartment;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            onPressed: _saveRoom,
                            icon: Icon(isEditing ? Icons.save : Icons.add, color: Colors.white),
                            label: Text(
                              isEditing ? l10n.saveChanges : l10n.addRoom,
                              style: GoogleFonts.notoSans(fontSize: 16, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 173, 128, 245),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}