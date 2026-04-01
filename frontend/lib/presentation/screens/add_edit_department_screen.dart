import 'package:flutter/material.dart';
import 'package:frontend/data/dtos/department_create_dto.dart';
import 'package:frontend/domain/repositories/department_repository.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/core/app_theme.dart';

class AddEditDepartmentScreen extends StatefulWidget {
  final String? departmentId;
  final String? initialName;

  const AddEditDepartmentScreen({
    super.key,
    this.departmentId,
    this.initialName,
  });

  @override
  State<AddEditDepartmentScreen> createState() => _AddEditDepartmentScreenState();
}

class _AddEditDepartmentScreenState extends State<AddEditDepartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final DepartmentRepository _departmentRepository = DepartmentRepository();
  bool _isLoading = false;

  bool get isEditing => widget.departmentId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.initialName ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveDepartment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final l10n = AppLocalizations.of(context)!;

    try {
      if (isEditing) {
        await _departmentRepository.updateDepartment(widget.departmentId!, _nameController.text.trim());
      } else {
        final createDto = DepartmentCreateDto(name: _nameController.text.trim());
        await _departmentRepository.addDepartment(createDto);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? l10n.departmentUpdatedSuccess : l10n.departmentAddedSuccess,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToSaveDepartment(e.toString())),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          isEditing ? l10n.editDepartment : l10n.addDepartment,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: -0.3,
          ),
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
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.business_rounded,
                        size: 60,
                        color: AppTheme.primary.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.departmentName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _nameController,
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: l10n.enterDepartmentNameHint,
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              prefixIcon: Icon(Icons.edit_note_rounded, color: AppTheme.primary),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.redAccent, width: 1),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.departmentNameValidator;
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    _isLoading 
                      ? const CircularProgressIndicator()
                      : Container(
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
                              onTap: _isLoading ? null : _saveDepartment,
                              borderRadius: BorderRadius.circular(16),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(isEditing ? Icons.check_circle_outline : Icons.add_circle_outline, color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      isEditing ? l10n.saveChanges : l10n.addDepartment,
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
          ),
        ],
      ),
    );
  }
}