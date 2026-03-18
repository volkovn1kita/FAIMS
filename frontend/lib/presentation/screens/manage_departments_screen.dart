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
      _loadDepartments();
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
      _loadDepartments();
    }
  }

  Future<void> _deleteDepartment(String departmentId) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
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
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
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
      return;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
    
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
          _loadDepartments();
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          l10n.manageDepartments,
          style: GoogleFonts.notoSans(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(_errorMessage, textAlign: TextAlign.center, style: GoogleFonts.notoSans(color: Colors.red, fontSize: 16)),
                  ),
                )
              : _departments.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noDepartmentsFound,
                        style: GoogleFonts.notoSans(fontSize: 15, color: Colors.grey.shade500),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0).copyWith(bottom: 80),
                      itemCount: _departments.length,
                      itemBuilder: (context, index) {
                        final department = _departments[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Dismissible(
                            key: Key(department.id),
                            direction: DismissDirection.horizontal,
                            background: _buildSwipeBackground(Icons.edit_outlined, Colors.blue.shade400, Alignment.centerLeft),
                            secondaryBackground: _buildSwipeBackground(Icons.delete_outline, Colors.redAccent, Alignment.centerRight),
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.endToStart) {
                                await _deleteDepartment(department.id);
                                return false;
                              } else if (direction == DismissDirection.startToEnd) {
                                await _editDepartment(department);
                                return false;
                              }
                              return false;
                            },
                            child: _buildDepartmentCard(department),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDepartment,
        backgroundColor: const Color.fromARGB(255, 143, 88, 225),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildDepartmentCard(DepartmentDto department) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
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
              _loadDepartments();
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.business_rounded, color: Colors.deepPurple.shade300, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    department.name,
                    style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 28),
              ],
            ),
          ),
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