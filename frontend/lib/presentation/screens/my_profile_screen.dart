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

  // Controllers для редагування профілю
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  bool _isEditing = false; // Режим редагування профілю

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
      print('Error loading user profile: $e');
    }
  }

  Future<void> _updateUserProfile() async {
    final l10n = AppLocalizations.of(context)!;
    if (_userProfile == null) return;

    if (_newPasswordController.text.isNotEmpty &&
        _newPasswordController.text != _confirmNewPasswordController.text) {
      setState(() {
        _errorMessage = l10n.newPassAndConfirmPassDoNotMatch;
      });
      return;
    }

    if (!mounted) return;
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

        // Очистка полів паролів
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
      print('Error updating user profile: $e');
    }
  }


  Future<void> _pickImage(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 70); // Зменшуємо якість для швидшого завантаження
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
        print('Error uploading avatar: $e');
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
      print('Error deleting avatar: $e');
    }
  }

  void _showImagePickerOptions() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(l10n.photoLibrary),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(l10n.camera),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              if (_userProfile?.avatarUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: Text(l10n.removeAvatar, style: TextStyle(color: Colors.red)),
                  onTap: () {
                    _deleteAvatar();
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.myProfile,
          style: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(_isEditing ? Icons.check : Icons.edit),
              onPressed: () {
                if (_isEditing) {
                  _updateUserProfile();
                }
                setState(() {
                  _isEditing = !_isEditing;
                  _errorMessage = ''; // Очищаємо помилки при переключенні режиму
                });
              },
            ),
        ],
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _showImagePickerOptions,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _userProfile?.avatarUrl != null
                              ? NetworkImage('$_baseUrl${_userProfile!.avatarUrl!}') as ImageProvider<Object>?
                              : null,
                          child: _userProfile?.avatarUrl == null
                              ? Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey.shade600,
                                )
                              : null,
                        ),
                      ),
                      TextButton(
                        onPressed: _showImagePickerOptions,
                        child: Text(
                          _userProfile?.avatarUrl == null ? l10n.addAvatar : l10n.changeAvatar,
                          style: GoogleFonts.notoSans(color: Colors.blueAccent),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _isEditing
                          ? _buildEditProfileForm()
                          : _buildProfileDetails(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileDetails() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileInfoRow(
          label: l10n.firstName,
          value: _userProfile?.firstName ?? 'N/A',
          icon: Icons.person_outline,
        ),
        _buildProfileInfoRow(
          label: l10n.lastName,
          value: _userProfile?.lastName ?? 'N/A',
          icon: Icons.person_outline,
        ),
        _buildProfileInfoRow(
          label: 'Email',
          value: _userProfile?.email ?? 'N/A',
          icon: Icons.email_outlined,
        ),
        _buildProfileInfoRow(
          label: l10n.role,
          value: _userProfile?.role ?? 'N/A',
          icon: Icons.assignment_ind_outlined,
        ),
        // Інші поля, які ви хочете відобразити
      ],
    );
  }

  Widget _buildProfileInfoRow({required String label, required String value, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade700, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileForm() {
    final texts = AppLocalizations.of(context)!;
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: _firstNameController,
            decoration: InputDecoration(labelText: texts.firstName),
            validator: (value) => value!.isEmpty ? texts.firstNameCannotBeEmpty : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _lastNameController,
            decoration: InputDecoration(labelText: texts.lastName),
            validator: (value) => value!.isEmpty ? texts.lastNameCannotBeEmpty : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value!.isEmpty) return texts.emailCannotBeEmpty;
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return texts.enterValidEmail;
              return null;
            },
          ),
          const SizedBox(height: 24),
          Text(
            texts.changePassword,
            style: GoogleFonts.notoSans(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _oldPasswordController,
            decoration: InputDecoration(labelText: texts.oldPassword),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _newPasswordController,
            decoration: InputDecoration(labelText: texts.newPassword),
            obscureText: true,
            validator: (value) {
              if (value!.isNotEmpty && value.length < 6) {
                return texts.passwordLenghtHint;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmNewPasswordController,
            decoration: InputDecoration(labelText: texts.confirmNewPassword),
            obscureText: true,
            validator: (value) {
              if (_newPasswordController.text.isNotEmpty && value != _newPasswordController.text) {
                return texts.passwordDoNotMatch;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}