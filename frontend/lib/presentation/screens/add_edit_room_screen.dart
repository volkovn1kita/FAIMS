import 'package:flutter/material.dart';
import 'package:frontend/data/dtos/department_dto.dart';
import 'package:frontend/data/dtos/room_create_dto.dart';
import 'package:frontend/data/dtos/room_update_dto.dart';
import 'package:frontend/domain/repositories/department_repository.dart';
import 'package:frontend/core/app_theme.dart';
import 'package:frontend/l10n/app_localizations.dart';

class AddEditRoomScreen extends StatefulWidget {
  final String? roomId; 
  final String? initialName; 
  final String? initialDepartmentId; 
  final String? currentDepartmentId; 

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
  
  bool _isSaving = false;

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
            orElse: () => _departments.first, 
          );
        } else if (widget.currentDepartmentId != null) {
          _selectedDepartment = _departments.firstWhere(
            (dept) => dept.id == widget.currentDepartmentId,
            orElse: () => _departments.first,
          );
        } else {
          _selectedDepartment = _departments.first; 
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().contains('Exception:')
              ? e.toString().replaceAll('Exception: ', '')
              : 'Failed to load departments: ${e.toString()}';
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
            content: Text(l10n.selectDepartment, style: TextStyle()),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() {
      _isSaving = true;
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
      } else {
        final createDto = RoomCreateDto(
          name: _nameController.text.trim(),
          departmentId: _selectedDepartment!.id,
        );
        await _departmentRepository.addRoom(createDto);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? l10n.roomUpdatedSuccessfully : l10n.roomAddedSuccessfully,
              style: TextStyle(),
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().contains('Exception:')
              ? e.toString().replaceAll('Exception: ', '')
              : 'Failed to save room: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          isEditing ? l10n.editRoom : l10n.addRoom,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black87, letterSpacing: -0.3),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 1,
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))],
            ),
          ),
          Expanded(
            child: _isLoading && _departments.isEmpty 
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0).copyWith(bottom: 40),
                    child: Column(
                      children: [
                        if (_errorMessage.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.red.shade100),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline_rounded, color: Colors.red.shade400),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage,
                                    style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 8)),
                            ],
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTextField(
                                  controller: _nameController,
                                  label: l10n.roomName,
                                  hintText: l10n.roomNameHint,
                                  icon: Icons.meeting_room_rounded,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return l10n.roomNameMissError;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                
                                _buildDropdown(l10n),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.primaryDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.35),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isSaving ? null : _saveRoom,
                              borderRadius: BorderRadius.circular(16),
                              child: Center(
                                child: _isSaving
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(isEditing ? Icons.save_rounded : Icons.add_rounded, color: Colors.white, size: 22),
                                          const SizedBox(width: 8),
                                          Text(
                                            isEditing ? l10n.saveChanges : l10n.addRoom,
                                            style: TextStyle(
                                              fontSize: 16, 
                                              color: Colors.white, 
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.1,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
          ),
        ),
        TextFormField(
          controller: controller,
          validator: validator,
          style: TextStyle(fontSize: 15, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
            prefixIcon: Icon(icon, color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            l10n.department,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
          ),
        ),
        DropdownButtonFormField<DepartmentDto>(
          initialValue: _selectedDepartment,
          icon: Icon(Icons.expand_more_rounded, color: Colors.grey.shade600),
          style: TextStyle(fontSize: 15, color: Colors.black87),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.business_rounded, color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
          ),
          items: _departments.map((department) {
            return DropdownMenuItem(
              value: department,
              child: Text(
                department.name,
                style: TextStyle(),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (DepartmentDto? newValue) {
            setState(() {
              _selectedDepartment = newValue;
            });
          },
          validator: (value) => value == null ? l10n.selectDepartment : null,
        ),
      ],
    );
  }
}