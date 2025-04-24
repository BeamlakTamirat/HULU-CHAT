import 'dart:ui';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/pages/settings_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/pages/about_page.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Menu items with their properties
  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Home',
      'icon': Icons.home_rounded,
      'color': Color(0xFF2196F3),
      'route': null, // Just pop for home
    },
    {
      'title': 'Settings',
      'icon': Icons.settings_rounded,
      'color': Color(0xFF64B5F6),
      'route': '/settings',
    },
    {
      'title': 'Profile',
      'icon': Icons.person_rounded,
      'color': Color(0xFF1976D2),
      'route': '/profile',
    },
    {
      'title': 'Archived Chats',
      'icon': Icons.archive_rounded,
      'color': Color(0xFF90CAF9),
      'route': '/archived',
    },
    {
      'title': 'Notifications',
      'icon': Icons.notifications_rounded,
      'color': Color(0xFF0D47A1),
      'route': '/notifications',
    },
    {
      'title': 'Help & Feedback',
      'icon': Icons.help_outline_rounded,
      'color': Color(0xFF3949AB),
      'route': '/help',
    },
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Create animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: Offset(-0.5, 0.0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Start animations when drawer opens
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void logout() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: AlertDialog(
          backgroundColor: Color(0xFF1A237E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Log Out",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to log out?",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Color(0xFF90CAF9),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                final auth = AuthService();
                auth.signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1976D2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Log Out"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Theme(
      // Optimize drawer animation speed
      data: Theme.of(context).copyWith(
        drawerTheme: DrawerThemeData(
          // Reduce animation duration for faster opening
          scrimColor: Colors.black54,
        ),
      ),
      child: Drawer(
        // Optimized performance by reducing shadows and effects
        elevation: 8,
        child: Container(
          color: isDarkMode
              ? Color(0xFF0A1929) // Dark blue background to match chat page
              : Color(0xFFBBDEFB), // Dynamic background based on theme
          child: Column(
            children: [
              // User account section
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(_authService.getCurrentUser()?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  String firstName = '';
                  String lastName = '';

                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!.exists) {
                    var userData =
                        snapshot.data!.data() as Map<String, dynamic>?;
                    if (userData != null) {
                      firstName = userData['firstName'] ?? '';
                      lastName = userData['lastName'] ?? '';
                    }
                  }

                  return Container(
                    padding: EdgeInsets.all(16),
                    height: 200,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Color(0xFF0A1929) : Color(0xFFBBDEFB),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: isDarkMode
                              ? Color(0xFF303F9F)
                              : Color(0xFF0D47A1),
                          child: firstName.isNotEmpty && lastName.isNotEmpty
                              ? Text(
                                  "${firstName[0].toUpperCase()}${lastName[0].toUpperCase()}",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 40,
                                ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          firstName.isNotEmpty || lastName.isNotEmpty
                              ? "$firstName $lastName"
                              : "User",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                isDarkMode ? Colors.white : Color(0xFF0D47A1),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          _authService.getCurrentUser()?.email ?? "",
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.8)
                                : Color(0xFF0D47A1).withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Menu Items - optimized for faster rendering
              _buildDrawerItem(
                context,
                icon: Icons.chat,
                title: "Chats",
                isSelected: true,
                onTap: () {
                  // Close drawer quickly
                  Navigator.pop(context);
                },
              ),
              _buildDrawerItem(
                context,
                icon: Icons.settings,
                title: "Settings",
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to settings page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsPage(),
                    ),
                  );
                },
              ),
              _buildDrawerItem(
                context,
                icon: Icons.info_outline,
                title: "About",
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to about page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AboutPage(),
                    ),
                  );
                },
              ),

              Spacer(),

              // Sign Out Button
              _buildDrawerItem(
                context,
                icon: Icons.logout,
                title: "Sign Out",
                onTap: () {
                  Navigator.pop(context);
                  AuthService().signOut();
                },
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Optimized drawer item implementation
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    // Get theme provider
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDarkMode
                    ? Color(0xFF303F9F).withOpacity(0.3)
                    : Color(0xFF1565C0).withOpacity(0.3))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDarkMode ? Color(0xFF90CAF9) : Color(0xFF0D47A1),
                size: 24,
              ),
              SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Color(0xFF0D47A1),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
