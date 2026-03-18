import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart'; // <--- ДОДАНО ІМПОРТ
import 'package:google_fonts/google_fonts.dart';
import '../../data/dtos/register_organization_dto.dart';
import '../../domain/repositories/auth_repository.dart';
import 'home_screen.dart';

class RegisterOrganizationScreen extends StatefulWidget {
  const RegisterOrganizationScreen({super.key});

  @override
  State<RegisterOrganizationScreen> createState() => _RegisterOrganizationScreenState();
}

class _RegisterOrganizationScreenState extends State<RegisterOrganizationScreen> {
  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _orgAddressController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = false;
  String _errorMessage = '';
  bool _isPasswordVisible = false;

  Future<void> _handleRegistration() async {
    // Отримуємо l10n для використання в повідомленнях про помилки
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final orgName = _orgNameController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final address = _orgAddressController.text.trim();

    if (orgName.isEmpty || firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = l10n.fillAllRequiredFields;
        _isLoading = false;
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorMessage = l10n.passwordMinLength;
        _isLoading = false;
      });
      return;
    }

    try {
      final dto = RegisterOrganizationDto(
        organizationName: orgName,
        organizationAddress: address.isEmpty ? null : address,
        adminFirstName: firstName,
        adminLastName: lastName,
        adminEmail: email,
        adminPassword: password,
      );

      final authResult = await _authRepository.registerOrganization(dto);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              userName: authResult.name ?? authResult.email.split('@')[0],
              userRole: authResult.role,
            ),
          ),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().replaceAll('Exception: ', '')
            : l10n.registrationError;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Отримуємо l10n для UI
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.registerClinicTitle,
                  style: GoogleFonts.notoSans(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.registerClinicSubtitle,
                  style: GoogleFonts.notoSans(
                    fontSize: 15,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                Text(
                  l10n.organizationDataLabel,
                  style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 143, 88, 225)),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _orgNameController,
                  label: l10n.clinicNameLabel,
                  hintText: l10n.clinicNameHint,
                  icon: Icons.local_hospital_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _orgAddressController,
                  label: l10n.addressOptionalLabel,
                  hintText: l10n.addressHint,
                  icon: Icons.location_on_outlined,
                ),
                
                const SizedBox(height: 32),
                
                Text(
                  l10n.adminDataLabel,
                  style: GoogleFonts.notoSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 143, 88, 225)),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _firstNameController,
                        label: l10n.firstNameLabel,
                        hintText: l10n.firstNameHint,
                        icon: Icons.person_outline,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _lastNameController,
                        label: l10n.lastNameLabel,
                        hintText: l10n.lastNameHint,
                        icon: Icons.person_outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: l10n.emailLoginLabel,
                  hintText: l10n.emailAdminHint,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  label: l10n.passwordRequiredLabel,
                  hintText: l10n.passwordHint,
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                ),
                
                const SizedBox(height: 40),
                
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 143, 88, 225),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : Text(
                            l10n.createClinicButton,
                            style: GoogleFonts.notoSans(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 20),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _errorMessage,
                              style: GoogleFonts.notoSans(color: Colors.red.shade700, fontWeight: FontWeight.w600, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
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
        TextField(
          controller: controller,
          obscureText: isPassword && !_isPasswordVisible,
          keyboardType: keyboardType,
          style: GoogleFonts.notoSans(fontSize: 15, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
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
          ),
        ),
      ],
    );
  }
}