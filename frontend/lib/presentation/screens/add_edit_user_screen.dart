
import 'package:flutter/material.dart';
import 'package:frontend/data/dtos/create_user_request_dto.dart';
import 'package:frontend/data/dtos/update_user_request_dto.dart';
import 'package:frontend/data/dtos/user_role_dto.dart';
import 'package:frontend/domain/repositories/user_repository.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class AddEditUserScreen extends StatefulWidget {
  final String? userId; // Якщо userId надано, це режим редагування

  const AddEditUserScreen({super.key, this.userId});

  @override
  State<AddEditUserScreen> createState() => _AddEditUserScreenState();
}

class _AddEditUserScreenState extends State<AddEditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserRepository _userRepository = UserRepository();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  UserRoleDto? _selectedRole;
  List<UserRoleDto> _availableRoles = [];

  bool _isLoading = true;
  bool _isSaving = false;
  String _errorMessage = '';

  bool get _isEditing => widget.userId != null; // Допоміжний геттер

  @override
  void initState() {
    super.initState();
    _loadRolesAndUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadRolesAndUserData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final roles = await _userRepository.getAvailableRoles();
      if (!mounted) return;
      setState(() {
        _availableRoles = roles;
      });

      if (_isEditing) {
        // Режим редагування: завантажити дані користувача
        final userToEdit = await _userRepository.getUserDetails(widget.userId!); // ВИКОРИСТОВУЄМО НОВИЙ МЕТОД
        if (!mounted) return;
        setState(() {
          _firstNameController.text = userToEdit.firstName;
          _lastNameController.text = userToEdit.lastName;
          _emailController.text = userToEdit.email;
          _selectedRole = _availableRoles.firstWhere((role) => role.name == userToEdit.role);
        });
      } else {
        // Для нового користувача можемо встановити роль за замовчуванням 'User'
        _selectedRole = _availableRoles.firstWhere((role) => role.name == 'User', orElse: () => _availableRoles.first);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Failed to load data: ${e.toString()}';
        print('Error loading user data or roles: $e');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Додаткова валідація для паролів
    if (!_isEditing && _passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Password and Confirm Password do not match.';
      });
      return;
    }
    // Для редагування, якщо ввели новий пароль, то він повинен співпадати
    if (_isEditing && _passwordController.text.isNotEmpty && _passwordController.text != _confirmPasswordController.text) {
       setState(() {
        _errorMessage = 'New Password and Confirm New Password do not match.';
      });
      return;
    }


    if (!mounted) return;
    setState(() {
      _isSaving = true;
      _errorMessage = '';
    });

    try {
      if (!_isEditing) {
        // Створення нового користувача
        final newUser = CreateUserRequestDto(
          email: _emailController.text,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          password: _passwordController.text,
          role: _selectedRole!.name,
        );
        await _userRepository.createUser(newUser);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User created successfully!')),
        );
      } else {
        // Редагування існуючого користувача
        final updatedUser = UpdateUserRequestDto( // ВИКОРИСТОВУЄМО НОВИЙ DTO
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          role: _selectedRole!.name,
          password: _passwordController.text.isNotEmpty ? _passwordController.text : null, // Пароль опціональний для оновлення
        );
        await _userRepository.updateUser(widget.userId!, updatedUser); // ВИКОРИСТОВУЄМО НОВИЙ МЕТОД
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User updated successfully!'), backgroundColor: Colors.green,),
        );
      }
      // Повертаємо true, щоб ManageUsersScreen перезавантажив список
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Failed to save user: ${e.toString()}';
        print('Error saving user: $e');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? l10n.editUser : l10n.addNewUser,
          style: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
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
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(labelText: l10n.firstName),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.enterFirstName;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(labelText: l10n.lastName),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.enterLastName;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(labelText: l10n.email),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.enterEmail;
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return l10n.enterValidEmail;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Пароль для створення, або опціональна зміна для редагування
                        Column(
                          children: [
                            Text(
                              _isEditing ? l10n.changePassword : l10n.password,
                              style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(labelText: l10n.newPassword),
                              obscureText: true,
                              validator: (value) {
                                if (!_isEditing && (value == null || value.isEmpty)) {
                                  return l10n.enterPassword;
                                }
                                if (value!.isNotEmpty && value.length < 6) {
                                  return l10n.passwordLenghtHint;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              decoration: InputDecoration(labelText: l10n.confirmNewPassword),
                              obscureText: true,
                              validator: (value) {
                                if (!_isEditing && (value == null || value.isEmpty)) {
                                  return l10n.confirmPassword;
                                }
                                if (value!.isNotEmpty && value != _passwordController.text) {
                                  return l10n.passwordDoNotMatch;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                        DropdownButtonFormField<UserRoleDto>(
                          initialValue: _selectedRole,
                          decoration:  InputDecoration(labelText: l10n.role),
                          items: _availableRoles.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role.name),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedRole = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return l10n.selectRole;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        Center(
                          child: _isSaving
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: _saveUser,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 173, 128, 245),
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(
                                    _isEditing ? l10n.saveChanges : l10n.createUser,
                                    style: GoogleFonts.notoSans(color: Colors.white, fontSize: 16),
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