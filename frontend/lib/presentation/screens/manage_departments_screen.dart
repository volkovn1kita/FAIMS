import 'package:flutter/material.dart';
import 'package:frontend/data/dtos/department_dto.dart';
import 'package:frontend/domain/repositories/department_repository.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/presentation/screens/add_edit_department_screen.dart';
import 'package:frontend/presentation/screens/department_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageDepartmentsScreen extends StatefulWidget {
  const ManageDepartmentsScreen({super.key});

  @override
  State<ManageDepartmentsScreen> createState() => _ManageDepartmentsScreenState();
}

class _ManageDepartmentsScreenState extends State<ManageDepartmentsScreen> {
  final DepartmentRepository _departmentRepository = DepartmentRepository();
  List<DepartmentDto> _departments = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDepartments();
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

  Future<void> _addDepartment() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditDepartmentScreen(),
      ),
    );
    if (result == true) {
      _loadDepartments(); // Refresh list if department was added
    }
  }

  Future<void> _editDepartment(DepartmentDto department) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditDepartmentScreen(
          departmentId: department.id,
          initialName: department.name,
        ),
      ),
    );
    if (result == true) {
      _loadDepartments(); // Refresh list if department was edited
    }
  }

  Future<void> _deleteDepartment(String departmentId) async {
    final l10n = AppLocalizations.of(context)!;
    // ---- Початок нової логіки перевірки наявності кімнат ----
    setState(() {
      _isLoading = true; // Показуємо індикатор завантаження під час перевірки
      _errorMessage = '';
    });
    try {
      final departmentDetail = await _departmentRepository.getDepartmentById(departmentId);
      if (departmentDetail.rooms.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.cannotDeleteDepartmentWithExistingRooms,
                  style: GoogleFonts.notoSans()),
              backgroundColor: Colors.orange, // Попереджувальний колір
            ),
          );
        }
        return; // Виходимо, якщо є кімнати
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().contains('Exception:')
              ? e.toString().replaceAll('Exception: ', '')
              : 'Failed to check department rooms: ${e.toString()}';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage, style: GoogleFonts.notoSans()),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
      return; // Виходимо у випадку помилки перевірки
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Приховуємо індикатор
        });
      }
    }
    // ---- Кінець нової логіки перевірки ----
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDeletion, style: GoogleFonts.notoSans(fontWeight: FontWeight.bold)),
        content: Text(
          l10n.deleteDepartmentAlert,
          style: GoogleFonts.notoSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel, style: GoogleFonts.notoSans(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete, style: GoogleFonts.notoSans(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      try {
        await _departmentRepository.deleteDepartment(departmentId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.departmentDeletedSuccessfully, style: GoogleFonts.notoSans()),
              backgroundColor: Colors.green,
            ),
          );
          _loadDepartments(); // Refresh the list
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = e.toString().contains('Exception:')
                ? e.toString().replaceAll('Exception: ', '')
                : 'Failed to delete department: ${e.toString()}';
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
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.manageDepartments,
          style: GoogleFonts.notoSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black87),
            onPressed: _addDepartment,
            tooltip: l10n.addNewDepartment,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: GoogleFonts.notoSans(color: Colors.red, fontSize: 16)))
              : _departments.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noDepartmentsFound,
                        style: GoogleFonts.notoSans(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _departments.length,
                      itemBuilder: (context, index) {
                        final department = _departments[index];
                        return Dismissible(
                          key: Key(department.id), // Унікальний ключ для Dismissible
                          direction: DismissDirection.horizontal,
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              // Свайп вліво (видалення)
                              await _deleteDepartment(department.id);
                              return false; // Запобігаємо автоматичному видаленню елемента
                            } else if (direction == DismissDirection.startToEnd) {
                              // Свайп вправо (редагування)
                              await _editDepartment(department);
                              return false; // Запобігаємо автоматичному видаленню елемента
                            }
                            return false;
                          },
                          // --- Змінений background ---
                          background: Card( // Обгортаємо в Card
                            margin: const EdgeInsets.only(bottom: 12), // Те ж маргін, що і у дочірнього Card
                            elevation: 2, // Можете поставити 0, якщо не хочете тіні на фоні
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Заокруглені кути
                            color: Colors.blue.shade600, // Колір при свайпі вправо (редагування)
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: const Icon(Icons.edit, color: Colors.white),
                              ),
                            ),
                          ),
                          // --- Змінений secondaryBackground ---
                          secondaryBackground: Card( // Обгортаємо в Card
                            margin: const EdgeInsets.only(bottom: 12), // Те ж маргін
                            elevation: 2, // Можете поставити 0
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Заокруглені кути
                            color: Colors.red, // Колір при свайпі вліво (видалення)
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                            ),
                          ),
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              title: Text(
                                department.name,
                                style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              leading: Icon(Icons.business, color: Colors.deepPurple.shade300),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.grey.shade600),
                                    onPressed: () => _editDepartment(department),
                                    tooltip: l10n.editDepartment,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteDepartment(department.id),
                                    tooltip: l10n.deleteDepartment,
                                  ),
                                ],
                              ),
                              onTap: () async {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => DepartmentDetailScreen(
                                      departmentId: department.id,
                                      departmentName: department.name,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  _loadDepartments(); // Refresh if rooms were changed in detail screen
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}