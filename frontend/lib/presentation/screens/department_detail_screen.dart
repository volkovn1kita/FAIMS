import 'package:flutter/material.dart';
import 'package:frontend/data/dtos/department_detail_dto.dart';
import 'package:frontend/data/dtos/room_list_dto.dart';
import 'package:frontend/domain/repositories/department_repository.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/presentation/screens/add_edit_room_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class DepartmentDetailScreen extends StatefulWidget {
  final String departmentId;
  final String departmentName;

  const DepartmentDetailScreen({
    super.key,
    required this.departmentId,
    required this.departmentName,
  });

  @override
  State<DepartmentDetailScreen> createState() => _DepartmentDetailScreenState();
}

class _DepartmentDetailScreenState extends State<DepartmentDetailScreen> {
  final DepartmentRepository _departmentRepository = DepartmentRepository();
  DepartmentDetailDto? _departmentDetail;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDepartmentDetails();
  }

  Future<void> _loadDepartmentDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final details = await _departmentRepository.getDepartmentById(widget.departmentId);
      if (!mounted) return;
      setState(() {
        _departmentDetail = details;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().contains('Exception:')
              ? e.toString().replaceAll('Exception: ', '')
              : 'Failed to load department details: ${e.toString()}';
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

  Future<void> _addRoom() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditRoomScreen(
          currentDepartmentId: widget.departmentId,
        ),
      ),
    );
    if (result == true) {
      _loadDepartmentDetails(); // Refresh list if room was added/edited
    }
  }

  Future<void> _editRoom(RoomListDto room) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditRoomScreen(
          roomId: room.id,
          initialName: room.name,
          initialDepartmentId: widget.departmentId, // Pass current department ID for editing
        ),
      ),
    );
    if (result == true) {
      _loadDepartmentDetails(); // Refresh list if room was added/edited
    }
  }

  Future<void> _deleteRoom(String roomId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion', style: GoogleFonts.notoSans(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to delete this room? This action cannot be undone.',
          style: GoogleFonts.notoSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: GoogleFonts.notoSans(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.notoSans(color: Colors.white)),
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
        await _departmentRepository.deleteRoom(roomId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Room deleted successfully!', style: GoogleFonts.notoSans()),
              backgroundColor: Colors.green,
            ),
          );
          _loadDepartmentDetails(); // Refresh the list
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = e.toString().contains('Exception:')
                ? e.toString().replaceAll('Exception: ', '')
                : 'Failed to delete room: ${e.toString()}';
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
          l10n.departmentRooms(widget.departmentName),
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
            onPressed: _addRoom,
            tooltip: l10n.addNewRoom,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: GoogleFonts.notoSans(color: Colors.red, fontSize: 16)))
              : _departmentDetail == null || _departmentDetail!.rooms.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noRoomsFound,
                        style: GoogleFonts.notoSans(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _departmentDetail!.rooms.length,
                      itemBuilder: (context, index) {
                        final room = _departmentDetail!.rooms[index];
                        return Dismissible(
                          key: Key(room.id), // Унікальний ключ для Dismissible
                          direction: DismissDirection.horizontal,
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              // Свайп вліво (видалення)
                              await _deleteRoom(room.id);
                              return false; // Запобігаємо автоматичному видаленню елемента
                            } else if (direction == DismissDirection.startToEnd) {
                              // Свайп вправо (редагування)
                              await _editRoom(room);
                              return false; // Запобігаємо автоматичному видаленню елемента
                            }
                            return false;
                          },
                          // --- Змінений background ---
                          background: Card( // Обгортаємо в Card
                            margin: const EdgeInsets.only(bottom: 12), // Те ж маргін
                            elevation: 2, // Можете поставити 0
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Заокруглені кути
                            color: Colors.blue.shade600, // Колір при свайпі вправо (редагування)
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Icon(Icons.edit, color: Colors.white),
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
                                room.name,
                                style: GoogleFonts.notoSans(fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              leading: Icon(Icons.meeting_room, color: Colors.deepPurple.shade300),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.grey.shade600),
                                    onPressed: () => _editRoom(room),
                                    tooltip: l10n.editRoom,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteRoom(room.id),
                                    tooltip: l10n.deleteRoom,
                                  ),
                                ],
                              ),
                              onTap: () {
                                _editRoom(room);
                              },
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}