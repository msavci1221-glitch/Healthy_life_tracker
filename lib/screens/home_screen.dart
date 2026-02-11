import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nutrition_category_screen.dart';
import 'workout_screen.dart';
import 'community_screen.dart';

// ✅ YENİ SCREENLER
import 'food_history_screen.dart';
import 'workout_plan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _name = 'User';
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _loadMiniProfile();
  }

  Future<void> _loadMiniProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final fn = (prefs.getString('firstName') ?? '').trim();
    final ln = (prefs.getString('lastName') ?? '').trim();
    final ap = (prefs.getString('avatarPath') ?? '').trim();

    final fullName = ('$fn $ln').trim();
    if (!mounted) return;

    setState(() {
      _name = fullName.isEmpty ? 'User' : fullName;
      _avatarPath = ap.isEmpty ? null : ap;
    });
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              _TopProfileCard(
                name: _name,
                subtitle: 'My profile',
                avatarPath: _avatarPath,
                onTap: () {
                  // sadece süs olsun: boş
                  // istersen AccountScreen'e yönlendiririz.
                },
              ),
              const SizedBox(height: 14),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _SectionCard(
                      title: 'Nutrition & Diet Tracking',
                      color: Colors.green.shade400,
                      icon: Icons.local_dining, // daha modern
                      onTap: () =>
                          _open(context, const NutritionCategoryScreen()),
                    ),
                    _SectionCard(
                      title: 'Workout & Exercise Log',
                      color: const Color.fromRGBO(239, 83, 80, 1),
                      icon: Icons.sports_gymnastics, // daha dinamik
                      onTap: () => _open(context, const WorkoutScreen()),
                    ),
                    _SectionCard(
                      title: 'Community & Social Hub',
                      color: Colors.blue.shade400,
                      icon: Icons.groups, // daha topluluk odaklı
                      onTap: () => _open(context, const CommunityScreen()),
                    ),
                    _SectionCard(
                      title: 'Personal Workout Plan',
                      color: Colors.orange.shade400, // turuncu
                      icon: Icons.calendar_month, // planı vurgulayan
                      onTap: () => _open(context, const WorkoutPlanScreen()),
                    ),
                    _SectionCard(
                      title: 'Food History & Meal Log',
                      color: Colors.deepPurple.shade400, // mor
                      icon: Icons.fastfood, // daha modern
                      onTap: () => _open(context, const FoodHistoryScreen()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopProfileCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String? avatarPath;
  final VoidCallback? onTap;

  const _TopProfileCard({
    required this.name,
    required this.subtitle,
    required this.avatarPath,
    this.onTap,
  });

  bool _hasValidAvatar(String? path) {
    if (path == null || path.trim().isEmpty) return false;
    try {
      return File(path).existsSync();
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAvatar = _hasValidAvatar(avatarPath);

    return Material(
      color: Colors.transparent,
      child: Container(
        height: 82,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              blurRadius: 10,
              spreadRadius: 0,
              offset: Offset(0, 2),
              color: Color(0x14000000),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFEDEDED),
                  backgroundImage:
                      hasAvatar ? FileImage(File(avatarPath!)) : null,
                  child: hasAvatar
                      ? null
                      : const Icon(Icons.person,
                          color: Color(0xFF1976D2), size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: Colors.black26, size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _SectionCard({
    required this.title,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(minHeight: 38),
                alignment: Alignment.center,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.5,
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
