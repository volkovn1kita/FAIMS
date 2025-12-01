import 'package:flutter/material.dart';
import 'package:frontend/core/constants.dart';
import 'package:frontend/data/dtos/user_dto.dart';
import 'package:frontend/data/dtos/user_role_dto.dart';
import 'package:frontend/domain/repositories/user_repository.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/presentation/screens/add_edit_user_screen.dart';
import 'package:google_fonts/google_fonts.dart';

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
        print('Error loading users or roles: $e');
      });
    } finally {
      if (!mounted) return;
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
      _loadData(); // Перезавантажити дані, якщо була зміна
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
              child: Text(l10n.delete, style: TextStyle(color: Colors.white)),
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
        _isLoading = true; // Можна створити окремий стан _isDeleting для більш гранульованого контролю
        _errorMessage = '';
      });
      try {
        await _userRepository.deleteUser(userId); // ВИКОРИСТОВУЄМО НОВИЙ МЕТОД
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully!')),
        );
        _loadData(); // Перезавантажити список
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _errorMessage = e.toString().contains('Exception:')
              ? e.toString().replaceAll('Exception: ', '')
              : 'Failed to delete user: ${e.toString()}';
          _isLoading = false; // Повернути isLoading до false у випадку помилки
        });
        print('Error deleting user: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.manageUsers,
          style: GoogleFonts.notoSans(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                )
              : Column(
                  children: [
                    // --- Блок пошуку, фільтрації та сортування ---
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.group_outlined, color: Colors.black87),
                              const SizedBox(width: 8),
                              Text(
                                l10n.users,
                                style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              labelText: l10n.searchByNameOrEmail,
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            onChanged: (value) {
                              _applyFiltersAndSort();
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<UserRoleDto?>(
                            initialValue: _selectedRoleFilter,
                            decoration: InputDecoration(
                              labelText: l10n.filterByRole,
                              prefixIcon: const Icon(Icons.assignment_ind_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            items: [
                              const DropdownMenuItem<UserRoleDto?>(
                                value: null,
                                child: Text("Any"),
                              ),
                              ..._availableRoles.map((role) {
                                return DropdownMenuItem<UserRoleDto>(
                                  value: role,
                                  child: Text(role.name),
                                );
                              }),
                            ],
                            onChanged: (newValue) {
                              setState(() {
                                _selectedRoleFilter = newValue;
                              });
                              _applyFiltersAndSort();
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _navigateToAddEditUser(),
                                icon: const Icon(Icons.add, color: Colors.white),
                                label: Text(
                                  l10n.addUser,
                                  style: GoogleFonts.notoSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 173, 128, 245),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _sortAscending = !_sortAscending;
                                  });
                                  _applyFiltersAndSort();
                                },
                                icon: Icon(
                                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                  size: 18,
                                  color: Colors.black87,
                                ),
                                label: Text(
                                  l10n.sortByLastName,
                                  style: GoogleFonts.notoSans(color: Colors.black87, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _filteredUsers.isEmpty && (_searchController.text.isNotEmpty || _selectedRoleFilter != null)
                          ? Center(
                              child: Text(
                                l10n.noUsersFoundMatchingYourCriteria,
                                style: GoogleFonts.notoSans(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              itemCount: _filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = _filteredUsers[index];
                                return Dismissible( // <-- Додаємо Dismissible тут
                                  key: Key(user.id), // Унікальний ключ
                                  direction: DismissDirection.horizontal,
                                  confirmDismiss: (direction) async {
                                    if (direction == DismissDirection.endToStart) {
                                      // Свайп вліво (видалення)
                                      await _deleteUser(user.id);
                                      return false; // Не дозволяємо Dismissible видаляти елемент
                                    } else if (direction == DismissDirection.startToEnd) {
                                      // Свайп вправо (редагування)
                                      await _navigateToAddEditUser(userId: user.id);
                                      return false; // Не дозволяємо Dismissible видаляти елемент
                                    }
                                    return false;
                                  },
                                  background: Card( // Обгортаємо в Card для закруглених кутів
                                    margin: const EdgeInsets.only(bottom: 12), // Те ж маргін
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    color: Colors.blue.shade600, // Колір для свайпу вправо (редагування)
                                    child: const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 20),
                                        child: Icon(Icons.edit, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  secondaryBackground: Card( // Обгортаємо в Card для закруглених кутів
                                    margin: const EdgeInsets.only(bottom: 12), // Те ж маргін
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    color: Colors.red, // Колір для свайпу вліво (видалення)
                                    child: const Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 20),
                                        child: Icon(Icons.delete, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  child: Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: InkWell(
                                      onTap: () => _navigateToAddEditUser(userId: user.id),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor: user.avatarUrl != null ? Colors.transparent : const Color.fromARGB(255, 173, 128, 245),
                                                  backgroundImage: user.avatarUrl != null
                                                      ? NetworkImage('$_baseUrl${user.avatarUrl!}') as ImageProvider<Object>?
                                                      : null,
                                                  child: user.avatarUrl == null
                                                      ? Text(
                                                          user.firstName[0].toUpperCase(),
                                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                        )
                                                      : null,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    user.fullName,
                                                    style: GoogleFonts.notoSans(fontWeight: FontWeight.bold, fontSize: 16),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Chip(
                                                  label: Text(
                                                    user.role,
                                                    style: GoogleFonts.notoSans(fontSize: 12, color: Colors.white),
                                                  ),
                                                  backgroundColor: user.role == 'Administrator'
                                                      ? Colors.deepPurpleAccent
                                                      : Colors.blueGrey,
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    user.email,
                                                    style: GoogleFonts.notoSans(color: Colors.grey.shade600, fontSize: 13),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                                      onPressed: () => _navigateToAddEditUser(userId: user.id),
                                                      tooltip: l10n.editUser,
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                                      onPressed: () => _deleteUser(user.id),
                                                      tooltip: l10n.deleteUser,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: null, // Зберігаємо як null, оскільки кнопка "Add User" переміщена
    );
  }
}