import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:faims/core/app_theme.dart';
import 'package:faims/l10n/app_localizations.dart';
import 'package:faims/presentation/screens/register_organization_screen.dart';
import 'package:go_router/go_router.dart';
import '../../data/dtos/login_dto.dart';
import '../../domain/repositories/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = true;
  String _errorMessage = '';
  bool _isPasswordVisible = false;
  double _contentOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) setState(() => _contentOpacity = 1.0);
    });
  }

  Map<String, dynamic> _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};
      final payload = parts[1];
      final String normalized = base64Url.normalize(payload);
      final String resp = utf8.decode(base64Url.decode(normalized));
      return json.decode(resp);
    } catch (e) {
      return {};
    }
  }

  /// Returns true if the JWT access token is expired (or unparseable).
  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final normalized = base64Url.normalize(parts[1]);
      final payload = json.decode(
        String.fromCharCodes(base64Url.decode(normalized)),
      );
      final exp = payload['exp'];
      if (exp == null) return false;
      final expiry = DateTime.fromMillisecondsSinceEpoch((exp as int) * 1000);
      // Add a 30-second buffer so we don't navigate with an about-to-expire token.
      return DateTime.now().isAfter(expiry.subtract(const Duration(seconds: 30)));
    } catch (_) {
      return true;
    }
  }

  /// Navigates to the correct home screen using [token] and [name].
  void _navigateHome(String token, String name) {
    final payload = _decodeJwt(token);
    final role = payload['role'] ??
        payload['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];
    if (role == 'Administrator') {
      context.go('/home', extra: {'userName': name, 'userRole': role});
    } else {
      context.go('/user-home', extra: name);
    }
  }

  Future<void> _checkAutoLogin() async {
    try {
      final token = await _authRepository.getToken();

      // No token stored → show login form.
      if (token == null || token.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      String activeToken = token;

      // If the access token is expired, try to silently refresh it.
      if (_isTokenExpired(token)) {
        final refreshed = await _authRepository.tryRefreshToken();
        if (refreshed == null) {
          // Refresh failed (backend restarted with wiped DB, or token too old).
          // Clear stored credentials and show login form.
          await _authRepository.logout();
          if (mounted) setState(() => _isLoading = false);
          return;
        }
        activeToken = refreshed.token;
      }

      // Token is valid — decode and navigate.
      final payload = _decodeJwt(activeToken);
      final role = payload['role'] ??
          payload['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];

      if (role == null) {
        // Token present but no role claim — treat as invalid.
        await _authRepository.logout();
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final savedName = await _authRepository.getName();
      String name = savedName ?? '';
      if (name.isEmpty) {
        final email = payload['email'] ??
            payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'] ??
            '';
        name = email.isNotEmpty ? email.split('@')[0] : 'User';
      }

      if (!mounted) return;
      _navigateHome(activeToken, name);
    } catch (_) {
      // Any unexpected error → fall back to login form safely.
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogin() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Client-side validation — catches the most common cases before
    // hitting the network, and ensures all error messages are localized.
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = l10n.enterEmailAndPassword;
        _isLoading = false;
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorMessage = l10n.passwordLenghtHint;
        _isLoading = false;
      });
      return;
    }

    try {
      final dto = LoginDto(email: email, password: password);
      final authResult = await _authRepository.login(dto);

      if (!mounted) return;

      if (authResult.role == 'Administrator') {
        context.go('/home', extra: {
          'userName': authResult.name ?? authResult.email.split('@')[0],
          'userRole': authResult.role,
        });
      } else {
        context.go('/user-home', extra: authResult.name ?? authResult.email.split('@')[0]);
      }
    } catch (e) {
      if (!mounted) return;
      final raw = e.toString();
      setState(() {
        if (raw.contains('AUTH_INVALID_CREDENTIALS')) {
          _errorMessage = l10n.invalidCredentials;
        } else if (raw.contains('AUTH_CONNECTION_ERROR')) {
          _errorMessage = l10n.connectionError;
        } else {
          // Fallback for anything unexpected (network plugin errors, etc.)
          _errorMessage = l10n.connectionError;
        }
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final theme = Theme.of(context);

    if (_isLoading && _errorMessage.isEmpty) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: AnimatedOpacity(
              opacity: _contentOpacity,
              duration: const Duration(milliseconds: 400),
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(14),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'FAIMS',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primary,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  l10n.welcomeBack,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.signInLabel,
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  hintText: 'name@hospital.org',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _passwordController,
                  label: l10n.password,
                  hintText: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
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
                            l10n.login,
                            style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
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
                              style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.newClinicQuestion,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterOrganizationScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        l10n.register,
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: isPassword && !_isPasswordVisible,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 15, color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 15),
            prefixIcon: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  )
                : null,
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
        ),
      ],
    );
  }
}
