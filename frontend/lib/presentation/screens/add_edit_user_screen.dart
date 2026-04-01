import 'package:flutter/material.dart';
import 'package:frontend/data/dtos/create_user_request_dto.dart';
import 'package:frontend/data/dtos/update_user_request_dto.dart';
import 'package:frontend/data/dtos/user_role_dto.dart';
import 'package:frontend/domain/repositories/user_repository.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/core/app_theme.dart';

class AddEditUserScreen extends StatefulWidget {
  final String? userId; 

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
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool get _isEditing => widget.userId != null;

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
        final userToEdit = await _userRepository.getUserDetails(widget.userId!); 
        if (!mounted) return;
        setState(() {
          _firstNameController.text = userToEdit.firstName;
          _lastNameController.text = userToEdit.lastName;
          _emailController.text = userToEdit.email;
          _selectedRole = _availableRoles.firstWhere((role) => role.name == userToEdit.role);
        });
      } else {
        _selectedRole = _availableRoles.firstWhere((role) => role.name == 'User', orElse: () => _availableRoles.first);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Failed to load data: ${e.toString()}';
      });
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isEditing && _passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Password and Confirm Password do not match.';
      });
      return;
    }
    
    if (_isEditing && _passwordController.text.isNotEmpty && _passwordController.text != _confirmPasswordController.text) {
       setState(() {
        _errorMessage = 'New Password and Confirm New Password do not match.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = '';
    });

    try {
      if (!_isEditing) {
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
          SnackBar(
            content: const Text('User created successfully!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        final updatedUser = UpdateUserRequestDto( 
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          role: _selectedRole!.name,
          password: _passwordController.text.isNotEmpty ? _passwordController.text : null, 
        );
        await _userRepository.updateUser(widget.userId!, updatedUser); 
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('User updated successfully!'), 
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Failed to save user: ${e.toString()}';
      });
    }
    
    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          _isEditing ? l10n.editUser : l10n.addNewUser,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.black87, letterSpacing: -0.3),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 1,
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0).copyWith(bottom: 40),
                    child: Column(
                      children: [
                        if (_errorMessage.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.red.shade100),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline_rounded, color: Colors.red.shade400),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage,
                                    style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 8)),
                            ],
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTextField(
                                  controller: _firstNameController,
                                  label: l10n.firstName,
                                  icon: Icons.person_outline_rounded,
                                  validator: (value) => (value == null || value.isEmpty) ? l10n.enterFirstName : null,
                                ),
                                const SizedBox(height: 20),
                                
                                _buildTextField(
                                  controller: _lastNameController,
                                  label: l10n.lastName,
                                  icon: Icons.person_outline_rounded,
                                  validator: (value) => (value == null || value.isEmpty) ? l10n.enterLastName : null,
                                ),
                                const SizedBox(height: 20),
                                
                                _buildTextField(
                                  controller: _emailController,
                                  label: l10n.email,
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return l10n.enterEmail;
                                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return l10n.enterValidEmail;
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                
                                _buildDropdown(l10n),
                                const SizedBox(height: 32),
                                
                                const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                                const SizedBox(height: 24),
                                
                                Text(
                                  _isEditing ? l10n.changePassword : l10n.password,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
                                ),
                                const SizedBox(height: 16),
                                
                                _buildTextField(
                                  controller: _passwordController,
                                  label: _isEditing ? l10n.newPassword : l10n.password,
                                  icon: Icons.lock_outline_rounded,
                                  isPassword: true,
                                  isPasswordVisible: _isPasswordVisible,
                                  onVisibilityToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                  validator: (value) {
                                    if (!_isEditing && (value == null || value.isEmpty)) return l10n.enterPassword;
                                    if (value != null && value.isNotEmpty && value.length < 6) return l10n.passwordLenghtHint;
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                
                                _buildTextField(
                                  controller: _confirmPasswordController,
                                  label: l10n.confirmNewPassword,
                                  icon: Icons.lock_reset_rounded,
                                  isPassword: true,
                                  isPasswordVisible: _isConfirmPasswordVisible,
                                  onVisibilityToggle: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                                  validator: (value) {
                                    if (!_isEditing && (value == null || value.isEmpty)) return l10n.confirmPassword;
                                    if (value != null && value.isNotEmpty && value != _passwordController.text) return l10n.passwordDoNotMatch;
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.primaryDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.35),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isSaving ? null : _saveUser,
                              borderRadius: BorderRadius.circular(16),
                              child: Center(
                                child: _isSaving
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                      )
                                    : Text(
                                        _isEditing ? l10n.saveChanges : l10n.createUser,
                                        style: TextStyle(
                                          fontSize: 16, 
                                          color: Colors.white, 
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onVisibilityToggle,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !isPasswordVisible,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(fontSize: 15, color: Colors.black87),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey.shade500),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
                    onPressed: onVisibilityToggle,
                  )
                : null,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            l10n.role,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
          ),
        ),
        DropdownButtonFormField<UserRoleDto>(
          initialValue: _selectedRole,
          icon: Icon(Icons.expand_more_rounded, color: Colors.grey.shade600),
          style: TextStyle(fontSize: 15, color: Colors.black87),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.badge_outlined, color: Colors.grey.shade500),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
          ),
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
          validator: (value) => value == null ? l10n.selectRole : null,
        ),
      ],
    );
  }
}