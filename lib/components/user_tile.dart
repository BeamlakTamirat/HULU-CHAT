import 'package:flutter/material.dart';

class UserTile extends StatefulWidget {
  final String text;
  final String? subtitle;
  final void Function()? onTap;
  final int? unreadCount;

  const UserTile({
    super.key,
    required this.text,
    this.subtitle,
    required this.onTap,
    this.unreadCount,
  });

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getAvatarColor() {
    // Generate a consistent color based on the user's name
    if (widget.text.isEmpty) return Color(0xFF1976D2);

    // Use the ASCII sum of the name to generate a hue value
    int sum = 0;
    for (int i = 0; i < widget.text.length; i++) {
      sum += widget.text.codeUnitAt(i);
    }

    // Generate a blue-based color using the sum as a seed
    final List<Color> blueShades = [
      Color(0xFF0D47A1), // Deep Blue
      Color(0xFF1976D2), // Blue
      Color(0xFF2196F3), // Light Blue
      Color(0xFF3F51B5), // Indigo
      Color(0xFF303F9F), // Dark Indigo
    ];

    return blueShades[sum % blueShades.length];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        _controller.reverse();
        setState(() {
          _isPressed = false;
        });
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      onTapCancel: () {
        _controller.reverse();
        setState(() {
          _isPressed = false;
        });
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF1A237E).withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isPressed
                  ? Color(0xFF2196F3).withOpacity(0.8)
                  : Color(0xFF1976D2).withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? Color(0xFF1976D2).withOpacity(0.3)
                    : Color(0xFF1976D2).withOpacity(0.1),
                blurRadius: _isPressed ? 15 : 8,
                spreadRadius: _isPressed ? 1 : 0,
                offset: Offset(0, _isPressed ? 2 : 1),
              ),
            ],
          ),
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            children: [
              // Avatar with glowing effect
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _getAvatarColor().withOpacity(0.8),
                      _getAvatarColor(),
                    ],
                    radius: 0.85,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getAvatarColor().withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.text.isNotEmpty ? widget.text[0].toUpperCase() : "?",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),

              // Name and email with enhanced styling
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    if (widget.subtitle != null)
                      Text(
                        widget.subtitle!,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // Unread count badge with enhanced styling
              if (widget.unreadCount != null && widget.unreadCount! > 0)
                Container(
                  margin: EdgeInsets.only(right: 8),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1976D2),
                        Color(0xFF2196F3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF1976D2).withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  constraints: BoxConstraints(
                    minWidth: 25,
                    minHeight: 25,
                  ),
                  child: Center(
                    child: Text(
                      widget.unreadCount! > 99
                          ? "99+"
                          : widget.unreadCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // Arrow icon with enhanced styling
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Color(0xFF1976D2).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.white.withOpacity(0.8),
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
