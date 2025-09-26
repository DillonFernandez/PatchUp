//
// EditProfilePage: User interface for updating profile information and password.
//

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../components/appbar.dart' show UserSession;
import '../localization/app_localizations.dart';

class EditProfilePage extends StatefulWidget {
  final String name;
  final String email;
  const EditProfilePage({super.key, required this.name, required this.email});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Form field controllers and state
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  bool _loading = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  /// Handles saving profile changes and password update
  Future<void> _saveProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    // Password validation logic
    final current = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();
    if (current.isNotEmpty || newPass.isNotEmpty || confirm.isNotEmpty) {
      if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
        setState(() {
          _error = 'All password fields required';
          _loading = false;
        });
        return;
      }
      if (newPass != confirm) {
        setState(() {
          _error = 'Passwords do not match';
          _loading = false;
        });
        return;
      }
    }

    // Send profile update request
    final url = 'http://192.168.8.187/patchup_app/lib/api/update_user_info.php';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "OldEmail": widget.email,
          "Name": _nameController.text.trim(),
          "Email": _emailController.text.trim(),
        }),
      );
      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        // Update local cache and session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'cached_user_name_${_emailController.text}',
          _nameController.text,
        );
        await prefs.setString(
          'cached_user_email_${_emailController.text}',
          _emailController.text,
        );
        UserSession.email = _emailController.text.trim();
        await prefs.setString('user_email', UserSession.email);

        // Handle password change if requested
        if (current.isNotEmpty && newPass.isNotEmpty && confirm.isNotEmpty) {
          final passUrl =
              'http://192.168.8.187/patchup_app/lib/api/change_password.php';
          final passResponse = await http.post(
            Uri.parse(passUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "Email": _emailController.text.trim(),
              "CurrentPassword": current,
              "NewPassword": newPass,
            }),
          );
          final passResult = jsonDecode(passResponse.body);
          if (passResult['success'] != true) {
            setState(() {
              _error = passResult['message'] ?? 'Failed to change password';
              _loading = false;
            });
            return;
          }
        }

        Navigator.pop(context, true);
      } else {
        setState(() {
          _error = result['message'] ?? 'Failed to update profile';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLoc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(appLoc),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(appLoc),
              const SizedBox(height: 24),
              _buildProfileForm(appLoc),
            ],
          ),
        ),
      ),
    );
  }

  // AppBar section
  AppBar _buildAppBar(AppLocalizations appLoc) {
    return AppBar(
      toolbarHeight: 72,
      title: Text(
        appLoc.translate('Edit Profile'),
        softWrap: true,
        maxLines: 2,
        overflow: TextOverflow.visible,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      backgroundColor: const Color(0xFF04274B),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    );
  }

  // Header section with gradient and icon
  Widget _buildHeader(AppLocalizations appLoc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF04274B), Color(0xFF1e40af)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF04274B).withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.manage_accounts_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appLoc.translate('Update Your Profile'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                Text(
                  appLoc.translate('Keep your information up to date'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Main profile form section
  Widget _buildProfileForm(AppLocalizations appLoc) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(appLoc.translate('Personal Information')),
          const SizedBox(height: 20),
          _buildBasicInfoSection(appLoc),
          const SizedBox(height: 32),
          _buildSectionTitle(appLoc.translate('Change Password')),
          const SizedBox(height: 8),
          Text(
            appLoc.translate('Leave blank to keep current password'),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
          _buildPasswordSection(appLoc),
          const SizedBox(height: 32),
          _buildActionButtons(appLoc),
        ],
      ),
    );
  }

  // Section title widget
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF04274B),
      ),
    );
  }

  // Personal info fields section
  Widget _buildBasicInfoSection(AppLocalizations appLoc) {
    return Column(
      children: [
        _CustomTextField(
          label: appLoc.translate('Name'),
          controller: _nameController,
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 20),
        _CustomTextField(
          label: appLoc.translate('Email Login'),
          controller: _emailController,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  // Password fields section
  Widget _buildPasswordSection(AppLocalizations appLoc) {
    return Column(
      children: [
        _CustomTextField(
          label: appLoc.translate('Current Password'),
          controller: _currentPasswordController,
          icon: Icons.lock_outline,
          isPassword: true,
          showPassword: _showCurrent,
          onTogglePassword: () => setState(() => _showCurrent = !_showCurrent),
        ),
        const SizedBox(height: 20),
        _CustomTextField(
          label: appLoc.translate('New Password'),
          controller: _newPasswordController,
          icon: Icons.lock_outline,
          isPassword: true,
          showPassword: _showNew,
          onTogglePassword: () => setState(() => _showNew = !_showNew),
        ),
        const SizedBox(height: 20),
        _CustomTextField(
          label: appLoc.translate('Confirm New Password'),
          controller: _confirmPasswordController,
          icon: Icons.lock_outline,
          isPassword: true,
          showPassword: _showConfirm,
          onTogglePassword: () => setState(() => _showConfirm = !_showConfirm),
        ),
      ],
    );
  }

  // Save button and error display section
  Widget _buildActionButtons(AppLocalizations appLoc) {
    return Column(
      children: [
        if (_error != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    appLoc.translate(_error!),
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF04274B),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadowColor: const Color(0xFF04274B).withOpacity(0.3),
            ),
            onPressed: _loading ? null : _saveProfile,
            child:
                _loading
                    ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.save_outlined, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          appLoc.translate('Save Changes'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ],
    );
  }
}

// Custom text field widget for form inputs
class _CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool isPassword;
  final bool showPassword;
  final VoidCallback? onTogglePassword;
  final TextInputType? keyboardType;

  const _CustomTextField({
    required this.label,
    required this.controller,
    required this.icon,
    this.isPassword = false,
    this.showPassword = false,
    this.onTogglePassword,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 8),
        Focus(
          child: Builder(
            builder: (context) {
              final hasFocus = Focus.of(context).hasFocus;
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow:
                      hasFocus
                          ? [
                            BoxShadow(
                              color: const Color(0xFF04274B).withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: TextField(
                  controller: controller,
                  obscureText: isPassword && !showPassword,
                  keyboardType: keyboardType,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1E293B),
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      icon,
                      color:
                          hasFocus
                              ? const Color(0xFF04274B)
                              : const Color(0xFF94A3B8),
                      size: 20,
                    ),
                    suffixIcon:
                        isPassword
                            ? IconButton(
                              icon: Icon(
                                showPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: const Color(0xFF94A3B8),
                                size: 20,
                              ),
                              onPressed: onTogglePassword,
                            )
                            : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF04274B),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
