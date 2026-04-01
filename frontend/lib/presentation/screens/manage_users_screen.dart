import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:frontend/core/constants.dart';
import 'package:frontend/data/dtos/user_dto.dart';
import 'package:frontend/data/dtos/user_role_dto.dart';
import 'package:frontend/domain/repositories/user_repository.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/presentation/screens/add_edit_user_screen.dart';
import 'package:frontend/core/app_theme.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  static final String _baseUrl = Constants.baseUrl.replaceAll('/api', '');
  final UserRepository _userRepository = UserRepository();
  List<UserDto> _allUsers = [];
  List<UserDto> _filteredUsers = [];
  bool _isLoading = true;
  String _errorMessage = '';

  final TextEditingController _searchController = TextEditingController();
  UserRoleDto? _selectedRoleFilter;
  List<UserRoleDto> _availableRoles = [];
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final loadedUsers = await _userRepository.getUsers();
      final loadedRoles = await _userRepository.getAvailableRoles();
      if (!mounted) return;
      setState(() {
        _allUsers = loadedUsers;
        _availableRoles = loadedRoles;
      });
      _applyFiltersAndSort();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Failed to load data: ${e.toString()}';
      });
      developer.log('Error loading users or roles: $e', name: 'ManageUsersScreen');
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFiltersAndSort() {
    List<UserDto> tempUsers = List.from(_allUsers);

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      tempUsers = tempUsers.where((user) {
        return user.firstName.toLowerCase().contains(query) ||
            user.lastName.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query);
      }).toList();
    }

    if (_selectedRoleFilter != null) {
      tempUsers = tempUsers.where((user) {
        return user.role == _selectedRoleFilter!.name;
      }).toList();
    }

    tempUsers.sort((a, b) {
      final comparison = a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase());
      return _sortAscending ? comparison : -comparison;
    });

    setState(() {
      _filteredUsers = tempUsers;
    });
  }

  Future<void> _navigateToAddEditUser({String? userId}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditUserScreen(userId: userId),
      ),
    );
    if (result == true) {
      _loadData(); 
    }
  }

  Future<void> _deleteUser(String userId) async {
    final l10n = AppLocalizations.of(context)!;
    final bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.confirmDeletion),
          content: Text(l10n.deleteUserAlert),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(l10n.delete, style: const TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      if (!mounted) return;
      setState(() {
        _isLoading = true; 
        _errorMessage = '';
      });
      try {
        await _userRepository.deleteUser(userId); 
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully!')),
        );
        _loadData(); 
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _errorMessage = e.toString().contains('Exception:')
              ? e.toString().replaceAll('Exception: ', '')
              : 'Failed to delete user: ${e.toString()}';
        });
        developer.log('Error deleting user: $e', name: 'ManageUsersScreen');
      }
      
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
      backgroundColor: Colors.grey.shade100, 
      appBar: AppBar(
        title: Text(
          l10n.manageUsers,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.black87),
        ),
        centerTitle: false,
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.searchByNameOrEmail,
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50, 
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                    onChanged: (value) => _applyFiltersAndSort(),
                  ),
                ),
                
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      _buildActionPill(
                        icon: _sortAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        label: l10n.sortByLastName, 
                        isActive: true,
                        onTap: () {
                          setState(() => _sortAscending = !_sortAscending);
                          _applyFiltersAndSort();
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildRoleFilterPill(l10n),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            height: 1,
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)),
                        ),
                      )
                    : _filteredUsers.isEmpty
                        ? Center(
                            child: Text(
                              l10n.noUsersFoundMatchingYourCriteria,
                              style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16.0).copyWith(bottom: 80),
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Dismissible(
                                  key: Key(user.id),
                                  direction: DismissDirection.horizontal,
                                  background: _buildSwipeBackground(Icons.edit_outlined, Colors.blue.shade400, Alignment.centerLeft),
                                  secondaryBackground: _buildSwipeBackground(Icons.delete_outline, Colors.redAccent, Alignment.centerRight),
                                  confirmDismiss: (direction) async {
                                    if (direction == DismissDirection.endToStart) {
                                      await _deleteUser(user.id);
                                      return false; 
                                    } else if (direction == DismissDirection.startToEnd) {
                                      await _navigateToAddEditUser(userId: user.id);
                                      return false; 
                                    }
                                    return false;
                                  },
                                  child: _buildUserCard(user),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditUser(),
        backgroundColor: AppTheme.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildUserCard(UserDto user) {
    final isAdmin = user.role == 'Administrator';
    final roleColor = isAdmin ? AppTheme.primary : Colors.blue.shade600;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToAddEditUser(userId: user.id), 
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: user.avatarUrl != null ? Colors.transparent : roleColor.withValues(alpha: 0.15),
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage('$_baseUrl${user.avatarUrl!}') as ImageProvider<Object>?
                      : null,
                  child: user.avatarUrl == null
                      ? Text(
                          user.firstName[0].toUpperCase(),
                          style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 18),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.role,
                    style: TextStyle(fontSize: 12, color: roleColor, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleFilterPill(AppLocalizations l10n) {
    bool isActive = _selectedRoleFilter != null;
    
    return Container(
      height: 38,
      constraints: const BoxConstraints(maxWidth: 140),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary.withValues(alpha: 0.1) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? AppTheme.primary : Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<UserRoleDto?>(
          isExpanded: true,
          value: _selectedRoleFilter,
          icon: const Padding(
            padding: EdgeInsets.only(left: 4.0),
            child: Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          ),
          iconEnabledColor: isActive ? AppTheme.primary : Colors.grey.shade600,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          hint: Text(
            l10n.filterByRole, 
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
            overflow: TextOverflow.ellipsis,
          ),
          style: TextStyle(
            fontSize: 14, 
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? AppTheme.primary : Colors.black87,
          ),
          items: [
            const DropdownMenuItem<UserRoleDto?>(
              value: null,
              child: Text("All Roles", overflow: TextOverflow.ellipsis),
            ),
            ..._availableRoles.map((role) {
              return DropdownMenuItem<UserRoleDto>(
                value: role,
                child: Text(role.name),
              );
            }),
          ],
          onChanged: (newValue) {
            setState(() => _selectedRoleFilter = newValue);
            _applyFiltersAndSort();
          },
        ),
      ),
    );
  }

  Widget _buildActionPill({required IconData icon, required String label, required bool isActive, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isActive ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.black87),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ],
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