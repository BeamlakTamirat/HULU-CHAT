import 'package:chat_app/components/my_drawer.dart';
import 'package:chat_app/components/user_tile.dart';
import 'package:chat_app/services/chat/chat_services.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/services/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/auth/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final ChatServices _chatService = ChatServices();
  final AuthService _authService = AuthService();

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  // Removed _floatingActionButtonController and search-related controllers/variables

  // Used to trigger rebuilds
  bool _forceRefresh = false;

  // Scroll controller for list animations
  final ScrollController _scrollController = ScrollController();

  // For floating bubble animations
  final List<_FloatingBubble> _floatingBubbles = [];

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    // Removed _floatingActionButtonController initialization

    // Generate floating bubbles for background effect
    _generateFloatingBubbles();

    // Removed search controller listener
  }

  void _generateFloatingBubbles() {
    final random = math.Random();
    for (int i = 0; i < 15; i++) {
      _floatingBubbles.add(
        _FloatingBubble(
          position: Offset(
            random.nextDouble() * 400,
            random.nextDouble() * 800,
          ),
          size: 8 + random.nextDouble() * 20,
          speed: 0.3 + random.nextDouble() * 1.0,
          opacity: 0.05 + random.nextDouble() * 0.15,
          color: _getRandomGreyColor(random),
        ),
      );
    }
  }

  Color _getRandomGreyColor(math.Random random) {
    final List<Color> blueShades = [
      Color(0xFFBBDEFB), // Light Blue
      Color(0xFF90CAF9), // Pale Blue
      Color(0xFF64B5F6), // Sky Blue
      Color(0xFF42A5F5), // Medium Blue
      Color(0xFF2196F3), // Standard Blue
      Color(0xFF1E88E5), // Slightly Darker Blue
      Color(0xFF1976D2), // Dark Blue
    ];
    return blueShades[random.nextInt(blueShades.length)];
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    // Removed _floatingActionButtonController disposal
    // Removed _searchController disposal
    _scrollController.dispose();
    super.dispose();
  }

  // Removed _toggleSearch method

  // Navigate to chat page
  void goToChatPage(String receiverID, String receiverEmail, String? userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          recieverID: receiverID,
          recieverEmail: receiverEmail,
          recieverName: userName,
        ),
      ),
    ).then((messagesRead) {
      // If returning with value 'true', messages were read, refresh to update unread count
      if (messagesRead == true) {
        setState(() {
          // Force refresh to update any UI elements that depend on unread messages
          _forceRefresh = !_forceRefresh;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get theme provider to access dark mode state
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      // Optimize drawer performance
      drawerEdgeDragWidth: 100, // Wider area to open drawer
      drawerEnableOpenDragGesture: true,
      backgroundColor: isDarkMode
          ? Color(0xFF121212)
          : Color(0xFFBBDEFB), // Dynamic background based on theme

      // Define drawer directly here for better performance
      drawer: const MyDrawer(),

      // Optimize body rendering
      body: Stack(
        children: [
          // Animated background bubbles
          ...List.generate(_floatingBubbles.length, (index) {
            final bubble = _floatingBubbles[index];
            return AnimatedBuilder(
              animation: _fadeController,
              builder: (context, child) {
                bubble.position = Offset(
                  bubble.position.dx,
                  bubble.position.dy - bubble.speed,
                );

                if (bubble.position.dy < -bubble.size) {
                  bubble.position = Offset(
                    bubble.position.dx,
                    MediaQuery.of(context).size.height + bubble.size,
                  );
                }

                return Positioned(
                  left: bubble.position.dx,
                  top: bubble.position.dy,
                  child: Opacity(
                    opacity: bubble.opacity * _fadeController.value,
                    child: Container(
                      width: bubble.size,
                      height: bubble.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDarkMode
                            ? bubble.color.withOpacity(0.3)
                            : bubble.color,
                        boxShadow: [
                          BoxShadow(
                            color: bubble.color.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Main content with SafeArea
          SafeArea(
            child: Column(
              children: [
                // Custom app bar with glass effect
                Container(
                  height: 80, // Fixed height
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Color(0xFF1A237E)
                                  .withOpacity(0.7) // Dark indigo for dark mode
                              : Color(0xFF1565C0)
                                  .withOpacity(0.7), // Blue for light mode
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode
                                  ? Colors.black.withOpacity(0.3)
                                  : Color(0xFF0D47A1).withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // App bar content
                            SizedBox(
                              height: 80,
                              child: Row(
                                children: [
                                  // Menu button - fixed to ensure drawer opens correctly
                                  Builder(
                                    builder: (context) => InkWell(
                                      onTap: () {
                                        Scaffold.of(context).openDrawer();
                                      },
                                      customBorder: CircleBorder(),
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isDarkMode
                                              ? Color(0xFF303F9F).withOpacity(
                                                  0.5) // Indigo for dark mode
                                              : Color(0xFF1565C0).withOpacity(
                                                  0.5), // Blue for light mode
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.menu,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 16),

                                  // Title with app logo
                                  Row(
                                    children: [
                                      Container(
                                        width: 35,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          gradient: RadialGradient(
                                            colors: isDarkMode
                                                ? [
                                                    Color(
                                                        0xFF5C6BC0), // Lighter indigo for dark mode
                                                    Color(
                                                        0xFF303F9F), // Indigo for dark mode
                                                  ]
                                                : [
                                                    Color(
                                                        0xFF42A5F5), // Light blue for light mode
                                                    Color(
                                                        0xFF0D47A1), // Dark blue for light mode
                                                  ],
                                            radius: 0.8,
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: isDarkMode
                                                  ? Color(0xFF303F9F)
                                                      .withOpacity(0.6)
                                                  : Color(0xFF0D47A1)
                                                      .withOpacity(0.6),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.chat_bubble_outline,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        "HuluChat",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),

                                  Spacer(),

                                  // Theme toggle button in top right corner
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Color(0xFF303F9F).withOpacity(
                                              0.5) // Indigo for dark mode
                                          : Color(0xFF1565C0).withOpacity(
                                              0.5), // Blue for light mode
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: isDarkMode
                                              ? Color(0xFF303F9F)
                                                  .withOpacity(0.3)
                                              : Color(0xFF0D47A1)
                                                  .withOpacity(0.3),
                                          blurRadius: 5,
                                          spreadRadius: 1,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        customBorder: CircleBorder(),
                                        onTap: () {
                                          // Toggle theme using provider
                                          Provider.of<ThemeProvider>(context,
                                                  listen: false)
                                              .toggleTheme();
                                        },
                                        child: Center(
                                          child: AnimatedSwitcher(
                                            duration:
                                                Duration(milliseconds: 300),
                                            child: Icon(
                                              isDarkMode
                                                  ? Icons
                                                      .wb_sunny // Sun icon for dark mode
                                                  : Icons
                                                      .nightlight_round, // Moon icon for light mode
                                              key: ValueKey(isDarkMode),
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // User list
                Expanded(
                  child: _buildUserList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    final currentUserID = _authService.getCurrentUser()!.uid;

    // First, get the blocked users stream
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserID)
          .collection('blocked_users')
          .snapshots(),
      builder: (context, blockedSnapshot) {
        // Get blocked user IDs
        List<String> blockedUserIds = [];

        if (blockedSnapshot.hasData && blockedSnapshot.data != null) {
          blockedUserIds =
              blockedSnapshot.data!.docs.map((doc) => doc.id).toList();
        }

        // Now get users and filter out blocked ones
        return StreamBuilder(
          stream: _chatService.getUsersStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Something went wrong!",
                  style: TextStyle(
                    color: Color(0xFF0D47A1), // Darker blue
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF0D47A1), // Darker blue
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      color: Color(0xFF64B5F6),
                      size: 80,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No contacts found",
                      style: TextStyle(
                        color: Color(0xFF0D47A1), // Darker blue
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Start a new conversation",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF0D47A1)
                            .withOpacity(0.7), // Darker blue with opacity
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Filter out blocked users and current user
            final currentUserEmail = _authService.getCurrentUser()?.email;
            final filteredUsers = snapshot.data!.where((userData) {
              return userData["email"] != currentUserEmail &&
                  !blockedUserIds.contains(userData["uid"]);
            }).toList();

            if (filteredUsers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.block,
                      color: Color(0xFF64B5F6),
                      size: 80,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No available contacts",
                      style: TextStyle(
                        color: Color(0xFF1976D2),
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "All contacts are blocked or unavailable",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF1976D2).withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            return FadeTransition(
              opacity: _fadeController,
              child: ListView.builder(
                controller: _scrollController,
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  return _buildUserListItem(
                      filteredUsers[index], context, index);
                },
              ),
            );
          },
        );
      },
    );
  }

  // Build individual user list item
  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context, int index) {
    // Get current user's email
    final currentUserEmail = _authService.getCurrentUser()?.email;
    final currentUserID = _authService.getCurrentUser()?.uid;

    // Only show the tile if this is not the current user
    if (userData["email"] != currentUserEmail) {
      // Use display name if available, otherwise use email
      final String displayText = userData["displayName"] ?? userData["email"];
      final String? subtitleText =
          userData["displayName"] != null ? userData["email"] : null;
      final String otherUserID = userData["uid"];

      // Calculate animation delay based on index
      final animationDelay = index * 0.1;

      return AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) {
          // Only animate after a delay based on index
          final animationValue =
              (_scaleController.value - animationDelay) * 1.5;
          final visible = animationValue > 0;
          final opacity = visible ? math.min(1.0, animationValue) : 0.0;
          final scale = visible ? math.min(1.0, animationValue * 2) : 0.0;

          return Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          );
        },
        child: StreamBuilder<QuerySnapshot>(
          stream: _chatService.getUnseenMessages(currentUserID!, otherUserID),
          builder: (context, snapshot) {
            int unreadCount = 0;

            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              unreadCount = snapshot.data!.docs.length;
            }

            return UserTile(
              text: displayText,
              subtitle: subtitleText,
              unreadCount: unreadCount,
              onTap: () {
                // Navigate to chat page using the common method
                goToChatPage(
                  userData["uid"],
                  userData["email"],
                  userData["displayName"],
                );
              },
            );
          },
        ),
      );
    } else {
      // Return an empty container for the current user (effectively hiding it)
      return Container();
    }
  }
}

// Floating bubble class for background effect
class _FloatingBubble {
  Offset position;
  final double size;
  final double speed;
  final double opacity;
  final Color color;

  _FloatingBubble({
    required this.position,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.color,
  });
}

//35
