import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants.dart';
import 'package:frontend/data/dtos/user_dto.dart';
import 'package:frontend/domain/repositories/user_repository.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final UserRepository _userRepository = UserRepository();
  final ImagePicker _picker = ImagePicker();
  static final String _baseUrl = Constants.baseUrl.replaceAll('/api', '');

  UserDto? _userProfile;
  bool _isLoading = true;
  String _errorMessage = '';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  bool _isEditing = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final user = await _userRepository.getMyProfile();
      if (!mounted) return;
      setState(() {
        _userProfile = user;
        _firstNameController.text = user.firstName;
        _lastNameController.text = user.lastName;
        _emailController.text = user.email;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Failed to load profile: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserProfile() async {
    final l10n = AppLocalizations.of(context)!;
    if (_userProfile == null) return;

    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text.isNotEmpty &&
        _newPasswordController.text != _confirmNewPasswordController.text) {
      setState(() {
        _errorMessage = l10n.newPassAndConfirmPassDoNotMatch;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final updatedUser = await _userRepository.updateMyProfile(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        oldPassword: _oldPasswordController.text.isNotEmpty ? _oldPasswordController.text : null,
        newPassword: _newPasswordController.text.isNotEmpty ? _newPasswordController.text : null,
      );

      if (!mounted) return;
      setState(() {
        if (updatedUser != null) {
          _userProfile = updatedUser;
        } else {
          _userProfile = _userProfile?.copyWith(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            email: _emailController.text,
          );
        }

        _isEditing = false;
        _isLoading = false;

        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmNewPasswordController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

      Navigator.of(context).pop(_firstNameController.text);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Failed to update profile: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      try {
        final avatarUrl = await _userRepository.uploadMyAvatar(imageFile);
        if (!mounted) return;
        setState(() {
          if (avatarUrl != null) {
            _userProfile = _userProfile?.copyWith(avatarUrl: avatarUrl);
          } else {
            _errorMessage = l10n.failedToGetAvatar;
          }
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar uploaded successfully!')),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _errorMessage = e.toString().contains('Exception:')
              ? e.toString().replaceAll('Exception: ', '')
              : 'Failed to upload avatar: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteAvatar() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      await _userRepository.deleteMyAvatar();
      if (!mounted) return;
      setState(() {
        _userProfile = _userProfile?.copyWith(avatarUrl: null);
        if (mounted) {
          ImageCache().clear();
          ImageCache().clearLiveImages();
        }
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avatar deleted successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception: ', '')
            : 'Failed to delete avatar: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _showImagePickerOptions() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: Colors.black87),
                  title: Text(l10n.photoLibrary, style: GoogleFonts.notoSans(fontWeight: FontWeight.w500)),
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined, color: Colors.black87),
                  title: Text(l10n.camera, style: GoogleFonts.notoSans(fontWeight: FontWeight.w500)),
                  onTap: () {
                    _pickImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
                if (_userProfile?.avatarUrl != null)
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    title: Text(l10n.removeAvatar, style: GoogleFonts.notoSans(color: Colors.redAccent, fontWeight: FontWeight.w500)),
                    onTap: () {
                      _deleteAvatar();
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          l10n.myProfile,
          style: GoogleFonts.notoSans(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(
                _isEditing ? Icons.close_rounded : Icons.edit_outlined,
                color: Colors.black87,
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                  _errorMessage = '';
                });
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 24.0, top: 16.0),
            child: Center(
              child: GestureDetector(
                onTap: _isEditing ? _showImagePickerOptions : null,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color.fromARGB(255, 143, 88, 225).withOpacity(0.2), width: 4),
                      ),
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: Colors.grey.shade100,
                        backgroundImage: _userProfile?.avatarUrl != null
                            ? NetworkImage('$_baseUrl${_userProfile!.avatarUrl!}') as ImageProvider<Object>?
                            : null,
                        child: _userProfile?.avatarUrl == null
                            ? Icon(Icons.person_rounded, size: 56, color: Colors.grey.shade400)
                            : null,
                      ),
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 143, 88, 225),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 1,
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
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
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.shade100),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline_rounded, color: Colors.red.shade400),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage,
                                    style: GoogleFonts.notoSans(color: Colors.red.shade700, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        _isEditing ? _buildEditProfileForm(l10n) : _buildProfileDetails(l10n),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileInfoRow(label: l10n.firstName, value: _userProfile?.firstName ?? 'N/A', icon: Icons.badge_outlined),
          const Divider(height: 24, thickness: 1),
          _buildProfileInfoRow(label: l10n.lastName, value: _userProfile?.lastName ?? 'N/A', icon: Icons.badge_outlined),
          const Divider(height: 24, thickness: 1),
          _buildProfileInfoRow(label: 'Email', value: _userProfile?.email ?? 'N/A', icon: Icons.email_outlined),
          const Divider(height: 24, thickness: 1),
          _buildProfileInfoRow(
            label: l10n.role,
            value: _userProfile?.role ?? 'N/A',
            icon: Icons.verified_user_outlined,
            isRole: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoRow({required String label, required String value, required IconData icon, bool isRole = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.grey.shade600, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.notoSans(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              isRole
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 143, 88, 225).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        value,
                        style: GoogleFonts.notoSans(fontSize: 13, color: const Color.fromARGB(255, 143, 88, 225), fontWeight: FontWeight.bold),
                      ),
                    )
                  : Text(
                      value,
                      style: GoogleFonts.notoSans(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w600),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditProfileForm(AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _firstNameController,
                  label: l10n.firstName,
                  icon: Icons.person_outline,
                  validator: (value) => value!.isEmpty ? l10n.firstNameCannotBeEmpty : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _lastNameController,
                  label: l10n.lastName,
                  icon: Icons.person_outline,
                  validator: (value) => value!.isEmpty ? l10n.lastNameCannotBeEmpty : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) return l10n.emailCannotBeEmpty;
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return l10n.enterValidEmail;
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lock_outline, color: Colors.black87, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.changePassword,
                      style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _oldPasswordController,
                  label: l10n.oldPassword,
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _newPasswordController,
                  label: l10n.newPassword,
                  icon: Icons.lock_reset_outlined,
                  isPassword: true,
                  validator: (value) {
                    if (value!.isNotEmpty && value.length < 6) {
                      return l10n.passwordLenghtHint;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _confirmNewPasswordController,
                  label: l10n.confirmNewPassword,
                  icon: Icons.lock_reset_outlined,
                  isPassword: true,
                  validator: (value) {
                    if (_newPasswordController.text.isNotEmpty && value != _newPasswordController.text) {
                      return l10n.passwordDoNotMatch;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 163, 108, 245), 
                  Color.fromARGB(255, 123, 68, 205)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 143, 88, 225).withOpacity(0.35),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isLoading ? null : _updateUserProfile,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Text(
                    'Save Changes', 
                    style: GoogleFonts.notoSans(
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
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
            style: GoogleFonts.notoSans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !_isPasswordVisible,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.notoSans(fontSize: 15, color: Colors.black87),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey.shade500),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
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
              borderSide: const BorderSide(color: Color.fromARGB(255, 143, 88, 225), width: 1.5),
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
}