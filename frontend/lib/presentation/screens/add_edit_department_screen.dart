import 'package:flutter/material.dart';
import 'package:frontend/data/dtos/department_create_dto.dart';
import 'package:frontend/domain/repositories/department_repository.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

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
        if (mounted) Navigator.of(context).pop(true);
      } else {
        final createDto = DepartmentCreateDto(name: _nameController.text.trim());
        await _departmentRepository.addDepartment(createDto);
        if (mounted) Navigator.of(context).pop(true);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? l10n.departmentUpdatedSuccess : l10n.departmentAddedSuccess,
              style: GoogleFonts.notoSans(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = l10n.failedToSaveDepartment(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage, style: GoogleFonts.notoSans()),
            backgroundColor: Colors.red,
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
      appBar: AppBar(
        title: Text(
          isEditing ? l10n.editDepartment : l10n.addDepartment,
          style: GoogleFonts.notoSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.departmentName,
                  hintText: l10n.enterDepartmentNameHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.departmentNameValidator;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _saveDepartment,
                      icon: Icon(isEditing ? Icons.save : Icons.add, color: Colors.white),
                      label: Text(
                        isEditing ? l10n.saveChanges : l10n.addDepartment,
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
