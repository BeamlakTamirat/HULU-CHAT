import 'package:flutter/material.dart';
import 'package:chat_app/services/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final Timestamp timestamp;
  final String messageId;
  final bool isSelected;
  final Function(String)? onLongPress;
  final bool isRead;
  final String? imageUrl;
  final String messageType;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.timestamp,
    required this.messageId,
    this.isSelected = false,
    this.onLongPress,
    required this.isRead,
    this.imageUrl,
    this.messageType = 'text',
  });

  @override
  Widget build(BuildContext context) {
    // Get theme mode
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // Calculate max width based on screen size
    double maxWidth = MediaQuery.of(context).size.width * 0.7;

    // Format the timestamp
    DateTime dateTime = timestamp.toDate();
    String formattedTime =
        "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";

    return GestureDetector(
      onLongPress: onLongPress != null
          ? () {
              onLongPress!(messageId);
            }
          : null,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        child: Row(
          mainAxisAlignment:
              isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            // Message container with animation
            AnimatedScale(
              scale: isSelected ? 0.95 : 1.0,
              duration: Duration(milliseconds: 200),
              child: Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                padding: EdgeInsets.all(messageType == 'image' ? 6 : 12),
                decoration: BoxDecoration(
                  color: isCurrentUser
                      ? isDarkMode
                          ? Color(
                              0xFF1E88E5) // Brighter blue for sender in dark mode
                          : Color(0xFF2196F3).withOpacity(
                              0.8) // Original blue color in light mode
                      : isDarkMode
                          ? Color(
                              0xFF102A43) // Dark blue for recipient in dark mode
                          : Color(0xFFBBDEFB).withOpacity(
                              0.9), // Light blueish color for recipient in light mode
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? isDarkMode
                              ? Color(0xFF1565C0).withOpacity(0.4)
                              : Color(0xFF1976D2).withOpacity(0.3)
                          : isDarkMode
                              ? Colors.black.withOpacity(0.15)
                              : Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                  border: isSelected
                      ? Border.all(
                          color: isDarkMode
                              ? Color(0xFF90CAF9)
                              : Color(0xFF1976D2),
                          width: 2,
                        )
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Message content - text or image
                    if (messageType == 'text')
                      Text(
                        message,
                        style: TextStyle(
                          color: isCurrentUser
                              ? Colors.white
                              : isDarkMode
                                  ? Colors.white
                                  : Color(0xFF212121),
                          fontSize: 16,
                        ),
                      )
                    else if (messageType == 'image')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image with loading indicator
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: GestureDetector(
                              onTap: () {
                                // Show full image when tapped
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Scaffold(
                                      backgroundColor: Colors.black,
                                      appBar: AppBar(
                                        backgroundColor: Colors.black,
                                        iconTheme:
                                            IconThemeData(color: Colors.white),
                                      ),
                                      body: Center(
                                        child: InteractiveViewer(
                                          panEnabled: true,
                                          boundaryMargin: EdgeInsets.all(20),
                                          minScale: 0.5,
                                          maxScale: 4,
                                          child: CachedNetworkImage(
                                            imageUrl: imageUrl!,
                                            fit: BoxFit.contain,
                                            placeholder: (context, url) =>
                                                Center(
                                              child: CircularProgressIndicator(
                                                color: Color(0xFF1976D2),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) => Icon(
                                              Icons.error,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: CachedNetworkImage(
                                imageUrl: imageUrl!,
                                fit: BoxFit.cover,
                                width: maxWidth - 24,
                                height: 200,
                                placeholder: (context, url) => SizedBox(
                                  height: 200,
                                  width: maxWidth - 24,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: isCurrentUser
                                          ? Colors.white
                                          : Color(0xFF1976D2),
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: 200,
                                  width: maxWidth - 24,
                                  color: Colors.grey.withOpacity(0.3),
                                  child: Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Caption for the image if any
                          if (message.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 8.0, left: 4.0, right: 4.0),
                              child: Text(
                                message,
                                style: TextStyle(
                                  color: isCurrentUser
                                      ? Colors.white
                                      : isDarkMode
                                          ? Colors.white
                                          : Color(0xFF212121),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    SizedBox(height: 4),
                    // Time and read status
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          formattedTime,
                          style: TextStyle(
                            color: isCurrentUser
                                ? Colors.white.withOpacity(0.8)
                                : isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                            fontSize: 10,
                          ),
                        ),
                        // Show read status only for current user's messages
                        if (isCurrentUser) ...[
                          SizedBox(width: 4),
                          Icon(
                            isRead ? Icons.done_all : Icons.done,
                            size: 14,
                            color: isRead
                                ? isDarkMode
                                    ? Colors.white
                                    : Color(0xFF64B5F6)
                                : Colors.white.withOpacity(0.8),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
