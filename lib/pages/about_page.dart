import 'package:flutter/material.dart';
import 'package:chat_app/services/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF121212) : Color(0xFFBBDEFB),
      appBar: AppBar(
        title: Text(
          "About",
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Developer Profile Section
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Color(0xFF1E2746)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.3)
                        : Colors.blue.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Developer Avatar
                  CircleAvatar(
                    radius: 60,
                    backgroundColor:
                        isDarkMode ? Color(0xFF3949AB) : Color(0xFF1976D2),
                    child: Text(
                      "BT",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Developer Name
                  Text(
                    "Beamlak Tamirat",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Color(0xFF1565C0),
                    ),
                  ),
                  SizedBox(height: 8),

                  // Developer Title
                  Text(
                    "Mobile App Developer",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.blue[200] : Color(0xFF1976D2),
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 24),

                  // Developer Bio
                  Text(
                    "I'm a passionate mobile app developer specializing in Flutter and cross-platform development. With a strong foundation in UI/UX design principles, I create beautiful, functional, and highly performant applications.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 24),

                  // Social Links as simple badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialBadge(
                        context,
                        icon: Icons.code,
                        label: "GitHub",
                        isDarkMode: isDarkMode,
                      ),
                      SizedBox(width: 16),
                      _buildSocialBadge(
                        context,
                        icon: Icons.person,
                        label: "Portfolio",
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // App Information Section
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Color(0xFF1E2746)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.3)
                        : Colors.blue.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // App Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Color(0xFF1A237E) : Color(0xFF1565C0),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black.withOpacity(0.3)
                              : Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),

                  // App Name
                  Text(
                    "HuluChat",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Color(0xFF1565C0),
                    ),
                  ),
                  SizedBox(height: 8),

                  // App Version
                  Text(
                    "Version 1.0.0",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  SizedBox(height: 24),

                  // App Description
                  Text(
                    "HuluChat is a modern messaging application designed with simplicity and performance in mind. With real-time messaging, beautiful UI, and enhanced privacy features, staying connected has never been easier.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),

                  SizedBox(height: 24),

                  // Features
                  _buildFeatureItem(
                    isDarkMode,
                    icon: Icons.chat,
                    title: "Real-time Messaging",
                    description: "Send and receive messages instantly",
                  ),
                  SizedBox(height: 12),
                  _buildFeatureItem(
                    isDarkMode,
                    icon: Icons.dark_mode,
                    title: "Dark Mode Support",
                    description: "Comfortable chatting day and night",
                  ),
                  SizedBox(height: 12),
                  _buildFeatureItem(
                    isDarkMode,
                    icon: Icons.security,
                    title: "Enhanced Privacy",
                    description: "Block users and control your experience",
                  ),
                  SizedBox(height: 12),
                  _buildFeatureItem(
                    isDarkMode,
                    icon: Icons.notifications,
                    title: "Smart Notifications",
                    description: "Stay updated without disturbance",
                  ),
                ],
              ),
            ),

            // Copyright
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "© 2025 Beamlak Tamirat. All rights reserved.",
                style: TextStyle(
                  color: isDarkMode ? Colors.white60 : Colors.black54,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isDarkMode,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Color(0xFF3949AB).withOpacity(0.4)
            : Color(0xFF1976D2).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode
              ? Color(0xFF3949AB).withOpacity(0.6)
              : Color(0xFF1976D2).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDarkMode ? Colors.white70 : Color(0xFF1976D2),
          ),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Color(0xFF1976D2),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    bool isDarkMode, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Color(0xFF3949AB).withOpacity(0.2)
                : Color(0xFF1976D2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDarkMode ? Colors.blue[200] : Color(0xFF1976D2),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Color(0xFF1565C0),
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
