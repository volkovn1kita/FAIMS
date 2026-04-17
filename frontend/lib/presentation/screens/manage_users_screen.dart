import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:faims/core/constants.dart';
import 'package:faims/core/error_mapper.dart';
import 'package:faims/data/dtos/user_dto.dart';
import 'package:faims/data/dtos/user_role_dto.dart';
import 'package:faims/domain/repositories/user_repository.dart';
import 'package:faims/l10n/app_localizations.dart';
import 'package:faims/presentation/screens/add_edit_user_screen.dart';
import 'package:faims/core/app_theme.dart';

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
          SnackBar(content: Text(l10n.userDeletedSuccessfully)),
        );
        _loadData(); 
      } catch (e) {
        if (!mounted) return;
        developer.log('Error deleting user: $e', name: 'ManageUsersScreen');
        final msg = ErrorMapper.map(e, AppLocalizations.of(context)!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
        setState(() { _isLoading = false; });
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.manageUsers,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: theme.colorScheme.onSurface),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.searchByNameOrEmail,
                      hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 15),
                      prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.brightness == Brightness.light
                          ? Colors.grey.shade100
                          : theme.colorScheme.surfaceContainerHighest,
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
              boxShadow: [BoxShadow(color: theme.shadowColor.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))],
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
                              style: TextStyle(fontSize: 15, color: theme.colorScheme.onSurfaceVariant),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16.0).copyWith(bottom: 80),
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
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
        color: Theme.of(context).cardColor,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToAddEditUser(userId: user.id),
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
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
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
      constraints: const BoxConstraints(maxWidth: 170),
      padding: const EdgeInsets.only(left: 10, right: 4),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary.withValues(alpha: 0.1) : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? AppTheme.primary : Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.badge_outlined,
            size: 16,
            color: isActive ? AppTheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: DropdownButtonHideUnderline(
        child: DropdownButton<UserRoleDto?>(
          isExpanded: true,
          value: _selectedRoleFilter,
          icon: const Padding(
            padding: EdgeInsets.only(left: 2.0),
            child: Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          ),
          iconEnabledColor: isActive ? AppTheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
          dropdownColor: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          hint: Text(
            l10n.filterByRole,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurfaceVariant),
            overflow: TextOverflow.ellipsis,
          ),
          style: TextStyle(
            fontSize: 14, 
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? AppTheme.primary : Theme.of(context).colorScheme.onSurface,
          ),
          items: [
            DropdownMenuItem<UserRoleDto?>(
              value: null,
              child: Text(l10n.any, overflow: TextOverflow.ellipsis),
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
          ),
        ],
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
          color: isActive ? Theme.of(context).colorScheme.surfaceContainerHighest : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurface),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(IconData icon, Color color, Alignment alignment) {
    return Container(
      color: color,
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