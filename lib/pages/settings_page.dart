import 'package:flutter/material.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  bool _isSaving = false;

  // Track expanded sections
  final Map<String, bool> _expandedSections = {
    'Profile': true,
    'Display Settings': false,
    'Blocked Users': false,
    'Account Actions': false,
  };

  @override
  void initState() {
    super.initState();
    // Load current user profile data
    _loadUserProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  // Load user profile data
  Future<void> _loadUserProfile() async {
    final currentUserID = _authService.getCurrentUser()!.uid;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserID)
        .get();

    if (userDoc.exists && userDoc.data() != null) {
      final userData = userDoc.data()!;
      setState(() {
        _firstNameController.text = userData['firstName'] ?? '';
        _lastNameController.text = userData['lastName'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF0A1929) : Color(0xFFBBDEFB),
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? Color(0xFF1A237E) : Color(0xFF1565C0),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          // Profile Edit Section
          _buildSection(
            title: "Profile",
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile picture (placeholder for now)
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: isDarkMode
                                ? Color(0xFF1A237E)
                                : Color(0xFF1565C0),
                            child: Text(
                              _firstNameController.text.isNotEmpty &&
                                      _lastNameController.text.isNotEmpty
                                  ? '${_firstNameController.text[0].toUpperCase()}${_lastNameController.text[0].toUpperCase()}'
                                  : _authService
                                          .getCurrentUser()
                                          ?.email?[0]
                                          .toUpperCase() ??
                                      'U',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // First Name field
                    Text(
                      "First Name",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Color(0xFF0D47A1),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _firstNameController,
                      style: TextStyle(
                          color: isDarkMode ? Colors.white : Color(0xFF0D47A1)),
                      decoration: InputDecoration(
                        hintText: "Enter first name",
                        hintStyle: TextStyle(
                            color: isDarkMode
                                ? Colors.white60
                                : Color(0xFF1976D2).withOpacity(0.5)),
                        filled: true,
                        fillColor: isDarkMode
                            ? Color(0xFF102A43).withOpacity(0.7)
                            : Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: isDarkMode
                                  ? Color(0xFF1E88E5).withOpacity(0.3)
                                  : Color(0xFF1976D2).withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: isDarkMode
                                  ? Color(0xFF1E88E5).withOpacity(0.3)
                                  : Color(0xFF1976D2).withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Color(0xFF1565C0), width: 2),
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color:
                              isDarkMode ? Colors.white70 : Color(0xFF1976D2),
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Last Name field
                    Text(
                      "Last Name",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Color(0xFF0D47A1),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _lastNameController,
                      style: TextStyle(
                          color: isDarkMode ? Colors.white : Color(0xFF0D47A1)),
                      decoration: InputDecoration(
                        hintText: "Enter last name",
                        hintStyle: TextStyle(
                            color: isDarkMode
                                ? Colors.white60
                                : Color(0xFF1976D2).withOpacity(0.5)),
                        filled: true,
                        fillColor: isDarkMode
                            ? Color(0xFF102A43).withOpacity(0.7)
                            : Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: isDarkMode
                                  ? Color(0xFF1E88E5).withOpacity(0.3)
                                  : Color(0xFF1976D2).withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: isDarkMode
                                  ? Color(0xFF1E88E5).withOpacity(0.3)
                                  : Color(0xFF1976D2).withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Color(0xFF1565C0), width: 2),
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color:
                              isDarkMode ? Colors.white70 : Color(0xFF1976D2),
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Save button with modern styling
                    Center(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: 220, // Slightly wider for better proportion
                        height: 48, // Fixed height for consistency
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDarkMode
                                ? Color(
                                    0xFF1A237E) // Dark indigo to match app bar
                                : Color(0xFF2196F3), // Brighter blue color
                            foregroundColor: Colors.white,
                            padding: EdgeInsets
                                .zero, // Use container for sizing instead
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  24), // More rounded corners
                            ),
                            elevation: isDarkMode
                                ? 8
                                : 4, // Different elevation based on theme
                            shadowColor: isDarkMode
                                ? Color(0xFF1A237E).withOpacity(0.6)
                                : Color(0xFF1976D2).withOpacity(0.4),
                          ),
                          child: _isSaving
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons
                                          .save_rounded, // Rounded icon variant
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 12), // Consistent spacing
                                    Text(
                                      "SAVE PROFILE",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight
                                            .w600, // Slightly less bold
                                        color: Colors.white,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Display Settings
          _buildSection(
            title: "Display Settings",
            children: [
              _buildToggleSwitch(
                title: "Dark Mode",
                subtitle: "Switch to dark theme for better night viewing",
                value: isDarkMode,
                onChanged: (value) {
                  // Use theme provider to update app-wide theme
                  themeProvider.setDarkMode(value);

                  // Show notification about theme change
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value ? "Dark mode enabled" : "Light mode enabled",
                      ),
                      backgroundColor: Color(0xFF1565C0),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),

          // Blocked Users Section
          _buildSection(
            title: "Blocked Users",
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(_authService.getCurrentUser()!.uid)
                    .collection('blocked_users')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.block_outlined,
                              size: 48,
                              color: Color(0xFF1976D2).withOpacity(0.5),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "No blocked users",
                              style: TextStyle(
                                color: Color(0xFF1976D2),
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Users you block will appear here",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF1976D2).withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      var userData = doc.data() as Map<String, dynamic>;
                      var userEmail = userData['email'] ?? 'Unknown User';
                      var userName = userData['name'] ?? userEmail;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(0xFF1565C0),
                          child: Text(
                            userName.toString().isNotEmpty
                                ? userName.toString()[0].toUpperCase()
                                : "?",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          userName.toString(),
                          style: TextStyle(
                            color: Color(0xFF1565C0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          userEmail.toString(),
                          style: TextStyle(
                            color: Color(0xFF1976D2).withOpacity(0.7),
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            _unblockUser(doc.id);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),

          // Account Actions Section
          _buildSection(
            title: "Account Actions",
            children: [
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                ),
                title: Text(
                  "Delete Account",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "Permanently delete your account and all data",
                  style: TextStyle(
                    color: Color(0xFF1976D2).withOpacity(0.7),
                  ),
                ),
                onTap: () {
                  _showDeleteAccountConfirmation();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Save user profile changes
  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final currentUserID = _authService.getCurrentUser()!.uid;

      // Update the user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserID)
          .update({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'displayName':
            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Color(0xFF1565C0),
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  // Show delete account confirmation dialog
  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF102A43),
        title: Text(
          "Delete Account",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "This action cannot be undone. All your data, messages, and profile information will be permanently deleted.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteAccount();
            },
            child: Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // Final confirmation for account deletion
  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF102A43),
        title: Text(
          "Final Confirmation",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Please type DELETE to confirm account deletion:",
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 16),
            TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Type DELETE here",
                hintStyle: TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Color(0xFF0A1929),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                // Enable/disable delete button based on input
                setState(() {
                  _canDeleteAccount = value.trim() == "DELETE";
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          StatefulBuilder(
            builder: (context, setState) {
              return TextButton(
                onPressed: _canDeleteAccount ? _deleteAccount : null,
                child: Text(
                  "PERMANENTLY DELETE",
                  style: TextStyle(
                    color: _canDeleteAccount
                        ? Colors.red
                        : Colors.red.withOpacity(0.5),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Delete account implementation
  bool _canDeleteAccount = false;

  Future<void> _deleteAccount() async {
    try {
      // Close the dialog
      Navigator.pop(context);

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );

      final currentUserID = _authService.getCurrentUser()!.uid;

      // Delete user data from Firestore
      // 1. Delete blocked users subcollection
      final blockedUsersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserID)
          .collection('blocked_users')
          .get();

      for (var doc in blockedUsersSnapshot.docs) {
        await doc.reference.delete();
      }

      // 2. Delete user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserID)
          .delete();

      // 3. Delete user authentication
      await _authService.getCurrentUser()!.delete();

      // Close loading dialog
      Navigator.pop(context);

      // Sign out and navigate to auth screen
      await _authService.signOut();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Account deleted successfully"),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to the auth screen
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      // Close loading dialog if open
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting account: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Build a section with an expandable header
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    final bool isExpanded = _expandedSections[title] ?? false;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF102A43) : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Color(0xFF1976D2).withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with tap to expand/collapse
          InkWell(
            onTap: () {
              setState(() {
                _expandedSections[title] = !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Color(0xFF0D47A1),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: isDarkMode ? Colors.white70 : Color(0xFF0D47A1),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            color: isDarkMode
                ? Colors.white24
                : Color(0xFF90CAF9).withOpacity(0.5),
            thickness: 1,
            height: 1,
          ),
          // Conditionally show children only if expanded
          if (isExpanded) ...children,
        ],
      ),
    );
  }

  // Build a toggle switch with a title
  Widget _buildToggleSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final bool isDarkMode = themeProvider.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Icon and text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Color(0xFF1565C0),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode
                        ? Colors.white70
                        : Color(0xFF1976D2).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Switch
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Color(0xFF2196F3), // Match primary color from theme
            activeTrackColor: isDarkMode
                ? Color(0xFF1A237E).withOpacity(0.6)
                : Color(0xFF90CAF9),
            inactiveThumbColor: isDarkMode ? Colors.grey : Colors.white,
            inactiveTrackColor:
                isDarkMode ? Color(0xFF102A43) : Colors.grey[300],
          ),
        ],
      ),
    );
  }

  // Unblock user implementation
  Future<void> _unblockUser(String userId) async {
    try {
      final currentUserID = _authService.getCurrentUser()!.uid;

      // Remove the user from the blocked_users subcollection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserID)
          .collection('blocked_users')
          .doc(userId)
          .delete();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("User unblocked successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error unblocking user: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
