import 'package:flutter/material.dart';
import 'package:faims/data/dtos/department_detail_dto.dart';
import 'package:faims/data/dtos/room_list_dto.dart';
import 'package:faims/domain/repositories/department_repository.dart';
import 'package:faims/l10n/app_localizations.dart';
import 'package:faims/presentation/screens/add_edit_room_screen.dart';
import 'package:faims/core/app_theme.dart';

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
              content: Text(_errorMessage, style: TextStyle()),
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDeletion, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(l10n.confirmDeleteRoom),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.deleteRoom, style: const TextStyle(color: Colors.white)),
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
              content: Text(l10n.roomDeletedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
          _loadDepartmentDetails();
        }
      } catch (e) {
        if (mounted) {
          final msg = e.toString().replaceAll('Exception: ', '');
          setState(() { _errorMessage = msg; });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg), backgroundColor: Colors.red),
          );
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.departmentRooms(widget.departmentName),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(_errorMessage, textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontSize: 16)),
                  ),
                )
              : _departmentDetail == null || _departmentDetail!.rooms.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noRoomsFound,
                        style: TextStyle(fontSize: 15, color: theme.colorScheme.onSurfaceVariant),
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
        backgroundColor: AppTheme.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildRoomCard(RoomListDto room) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: theme.shadowColor.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
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
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant, size: 28),
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
