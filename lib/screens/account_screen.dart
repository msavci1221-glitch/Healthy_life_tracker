import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _age = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();

  XFile? _avatar;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadStoredProfile();
    _loadFirebaseEmail();
    _loadFirebasePassword();
  }

  void _loadFirebaseEmail() {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email != null) {
      _email.text = user!.email!;
    }
  }

  void _loadFirebasePassword() {
    _password.text = '********';
  }

  Future<void> _pickAvatar() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (!mounted) return;
    if (file != null) setState(() => _avatar = file);
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', _firstName.text);
    await prefs.setString('lastName', _lastName.text);
    await prefs.setString('age', _age.text);
    await prefs.setString('email', _email.text);
    await prefs.setString('height', _height.text);
    await prefs.setString('weight', _weight.text);

    if (_avatar != null) {
      await prefs.setString('avatarPath', _avatar!.path);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved (local)')),
    );

    setState(() {});
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _loadStoredProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final fn = prefs.getString('firstName');
    final ln = prefs.getString('lastName');
    final age = prefs.getString('age');
    final email = prefs.getString('email');
    final height = prefs.getString('height');
    final weight = prefs.getString('weight');
    final avatarPath = prefs.getString('avatarPath');

    if (!mounted) return;
    setState(() {
      if (fn != null) _firstName.text = fn;
      if (ln != null) _lastName.text = ln;
      if (age != null) _age.text = age;
      if (email != null && _email.text.isEmpty) _email.text = email;
      if (height != null) _height.text = height;
      if (weight != null) _weight.text = weight;
      if (avatarPath != null && avatarPath.isNotEmpty) {
        _avatar = XFile(avatarPath);
      }
    });
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _age.dispose();
    _email.dispose();
    _password.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        '${_firstName.text.isEmpty ? 'User' : _firstName.text} ${_lastName.text}'
            .trim();

    const green = Color(0xFF22BFA2);
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: false,
            delegate: _ProfileHeaderDelegate(
              // ✅ sadece overflow fix için arttır
              minExtent: 120,
              maxExtent: 120,
              avatar: _avatar,
              displayName: displayName,
              onTap: _pickAvatar,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Personal Info
                  Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: green.withOpacity(0.13),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.info_outline,
                                    color: green, size: 18),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Personal Info',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _LabeledField(
                            controller: _firstName,
                            label: 'First Name',
                            icon: Icons.person,
                            iconColor: green,
                          ),
                          _LabeledField(
                            controller: _lastName,
                            label: 'Last Name',
                            icon: Icons.person_outline,
                            iconColor: green,
                          ),
                          _LabeledField(
                            controller: _age,
                            label: 'Age',
                            keyboardType: TextInputType.number,
                            icon: Icons.cake,
                            iconColor: green,
                          ),
                          _LabeledField(
                            controller: _height,
                            label: 'Height (cm)',
                            keyboardType: TextInputType.number,
                            icon: Icons.height,
                            iconColor: green,
                          ),
                          _LabeledField(
                            controller: _weight,
                            label: 'Weight (kg)',
                            keyboardType: TextInputType.number,
                            icon: Icons.monitor_weight,
                            iconColor: green,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Account
                  Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: green.withOpacity(0.13),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.account_box,
                                    color: green, size: 18),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Account',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _LabeledField(
                            controller: _email,
                            label: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            enabled: false,
                            icon: Icons.email,
                            iconColor: green,
                          ),
                          _LabeledField(
                            controller: _password,
                            label: 'Password',
                            enabled: false,
                            obscureText: true,
                            icon: Icons.lock,
                            iconColor: green,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _saveProfile,
                              icon: const Icon(Icons.save, color: Colors.white),
                              label: const Text('Save Profile',
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: green,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Card(
                    color: const Color(0xFFF5F5F5),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading:
                          Icon(Icons.settings, color: Colors.blue.shade200),
                      title: const Text('Settings',
                          style: TextStyle(color: Colors.blue)),
                      subtitle: const Text(
                        'Notification, language, theme',
                        style: TextStyle(color: Colors.black54),
                      ),
                      onTap: () {},
                    ),
                  ),

                  const SizedBox(height: 8),

                  Card(
                    color: const Color(0xFFF5F5F5),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Log Out',
                          style: TextStyle(color: Colors.red)),
                      onTap: _logout,
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
}

class _ProfileHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  final double minExtent;
  @override
  final double maxExtent;

  final XFile? avatar;
  final String displayName;
  final VoidCallback onTap;

  _ProfileHeaderDelegate({
    required this.minExtent,
    required this.maxExtent,
    required this.avatar,
    required this.displayName,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      avatar == null ? null : FileImage(File(avatar!.path)),
                  child: avatar == null
                      ? const Icon(Icons.account_circle,
                          size: 40, color: Color(0xFF1976D2))
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'My profile',
                        style: TextStyle(fontSize: 14, color: Colors.black45),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: Colors.black26, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _ProfileHeaderDelegate oldDelegate) {
    return avatar?.path != oldDelegate.avatar?.path ||
        displayName != oldDelegate.displayName ||
        minExtent != oldDelegate.minExtent ||
        maxExtent != oldDelegate.maxExtent;
  }
}

class _LabeledField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool enabled;
  final bool obscureText;
  final IconData? icon;
  final Color? iconColor;

  const _LabeledField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.enabled = true,
    this.obscureText = false,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          prefixIcon: icon != null
              ? Icon(icon, color: iconColor ?? Color(0xFF22BFA2))
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF22BFA2), width: 2),
          ),
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
        ),
      ),
    );
  }
}
