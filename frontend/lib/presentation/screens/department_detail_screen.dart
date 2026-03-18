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
      _loadDepartmentDetails();
    }
  }

  Future<void> _editRoom(RoomListDto room) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditRoomScreen(
          roomId: room.id,
          initialName: room.name,
          initialDepartmentId: widget.departmentId,
        ),
      ),
    );
    if (result == true) {
      _loadDepartmentDetails();
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
          _loadDepartmentDetails();
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          l10n.departmentRooms(widget.departmentName),
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
              : _departmentDetail == null || _departmentDetail!.rooms.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noRoomsFound,
                        style: GoogleFonts.notoSans(fontSize: 15, color: Colors.grey.shade500),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0).copyWith(bottom: 80),
                      itemCount: _departmentDetail!.rooms.length,
                      itemBuilder: (context, index) {
                        final room = _departmentDetail!.rooms[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Dismissible(
                            key: Key(room.id),
                            direction: DismissDirection.horizontal,
                            background: _buildSwipeBackground(Icons.edit_outlined, Colors.blue.shade400, Alignment.centerLeft),
                            secondaryBackground: _buildSwipeBackground(Icons.delete_outline, Colors.redAccent, Alignment.centerRight),
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.endToStart) {
                                await _deleteRoom(room.id);
                                return false;
                              } else if (direction == DismissDirection.startToEnd) {
                                await _editRoom(room);
                                return false;
                              }
                              return false;
                            },
                            child: _buildRoomCard(room),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRoom,
        backgroundColor: const Color.fromARGB(255, 143, 88, 225),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildRoomCard(RoomListDto room) {
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
          onTap: () => _editRoom(room),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.meeting_room_rounded, color: Colors.teal.shade400, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    room.name,
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