import 'dart:io';
import 'package:chat_app/components/chat_bubble.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/services/chat/chat_services.dart';
import 'package:chat_app/services/storage/storage_service.dart';
import 'package:chat_app/services/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  final String recieverEmail;
  final String recieverID;
  final String? recieverName;

  const ChatPage({
    super.key,
    required this.recieverEmail,
    required this.recieverID,
    this.recieverName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();

  //chat and auth service
  final ChatServices _chatService = ChatServices();
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();

  //for textfield focus node
  FocusNode myFocusNode = FocusNode();

  // Selection mode state
  bool _isInSelectionMode = false;
  final Set<String> _selectedMessageIds = {};

  // Image upload state
  bool _isUploading = false;
  File? _imageFile;

  // Animation controller for deletion effects
  late AnimationController _deleteAnimationController;

  // Track message count to detect new messages
  int? _previousMessageCount;

  // Flag to force scroll to bottom on next message load
  bool _forceScrollToBottom = true;

  @override
  void initState() {
    super.initState();

    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
      }
    });

    // Mark messages as read when the chat opens
    final String currentUserID = _authService.getCurrentUser()!.uid;
    _chatService.markMessagesAsRead(widget.recieverID, currentUserID);

    // Scroll to bottom (most recent messages) after the chat page loads
    // Use a slightly longer delay to ensure messages are loaded
    Future.delayed(const Duration(milliseconds: 800), () => scrollDown());

    // Initialize animation controller
    _deleteAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Don't check permissions on startup - only when user tries to upload
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    _deleteAnimationController.dispose();
    super.dispose();
  }

  //scroll controllr
  final ScrollController _scrollController = ScrollController();

  void scrollDown() {
    // Only scroll if controller is attached and list has been rendered
    if (_scrollController.hasClients) {
      try {
        _scrollController.animateTo(
          _scrollController.position
              .maxScrollExtent, // Scroll to bottom since we're not using reverse anymore
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } catch (e) {
        print("Error scrolling: $e");
      }
    }
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      // Set flag to force scroll to bottom when the message appears
      _forceScrollToBottom = true;

      await _chatService.sendMessage(
          widget.recieverID, _messageController.text);

      _messageController.clear();

      // Added delay to ensure the message appears in the list before scrolling
      Future.delayed(const Duration(milliseconds: 500), () {
        scrollDown();
      });
    }
  }

  // Toggle selection mode
  void _toggleSelectionMode() {
    setState(() {
      _isInSelectionMode = !_isInSelectionMode;
      if (!_isInSelectionMode) {
        _selectedMessageIds.clear();
      }
    });
  }

  // Toggle selection of a message
  void _toggleMessageSelection(String messageId) {
    setState(() {
      if (_selectedMessageIds.contains(messageId)) {
        _selectedMessageIds.remove(messageId);
        // If no messages are selected, exit selection mode
        if (_selectedMessageIds.isEmpty && _isInSelectionMode) {
          _isInSelectionMode = false;
        }
      } else {
        _selectedMessageIds.add(messageId);
      }
    });
  }

  // Select all messages
  void _selectAllMessages(List<DocumentSnapshot> documents) {
    setState(() {
      if (_selectedMessageIds.length == documents.length) {
        // If all are selected, unselect all
        _selectedMessageIds.clear();
      } else {
        // Otherwise select all
        _selectedMessageIds.clear();
        for (var doc in documents) {
          _selectedMessageIds.add(doc.id);
        }
      }
    });
  }

  // Delete selected messages
  Future<void> _deleteSelectedMessages() async {
    if (_selectedMessageIds.isEmpty) return;

    try {
      // Create fade-out animation effect
      _deleteAnimationController.forward();

      // Get current user ID
      final String currentUserID = _authService.getCurrentUser()!.uid;

      // Generate chatroom ID
      List<String> ids = [currentUserID, widget.recieverID];
      ids.sort();
      String chatRoomID = ids.join('_');

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

      // Delete each selected message
      for (String messageId in _selectedMessageIds) {
        await FirebaseFirestore.instance
            .collection("chat_rooms")
            .doc(chatRoomID)
            .collection("messages")
            .doc(messageId)
            .delete();
      }

      // Close loading dialog
      Navigator.pop(context);

      // Exit selection mode and clear selection
      setState(() {
        int deletedCount = _selectedMessageIds.length;
        _selectedMessageIds.clear();
        _isInSelectionMode = false;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("$deletedCount messages deleted"),
          backgroundColor: Colors.green,
        ));
      });

      // Reset animation
      _deleteAnimationController.reset();
    } catch (e) {
      // Close loading dialog if open
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error deleting messages: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get theme provider to access dark mode state
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // Re-mark messages as read on every build to ensure they're updated
    final String currentUserID = _authService.getCurrentUser()!.uid;
    _chatService.markMessagesAsRead(widget.recieverID, currentUserID);

    return WillPopScope(
      // Handle hardware back button press
      onWillPop: () async {
        // Mark messages as read before navigating back
        await _chatService.markMessagesAsRead(widget.recieverID, currentUserID);

        // Return true to allow the pop
        Navigator.of(context).pop(true);
        return false; // We handled the pop ourselves
      },
      child: Scaffold(
        backgroundColor: isDarkMode
            ? Color(0xFF0A1929) // Dark blue background
            : Color(0xFFE3F2FD), // Light blue background
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: _isInSelectionMode
              ? Text(
                  "${_selectedMessageIds.length} selected",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : _buildReceiverInfo(),
          backgroundColor:
              _isInSelectionMode ? Color(0xFFE53935) : Colors.transparent,
          elevation: 0,
          flexibleSpace: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: _isInSelectionMode
                      ? Color(0xFFE53935).withOpacity(0.8)
                      : isDarkMode
                          ? Color(0xFF1A237E)
                              .withOpacity(0.7) // Dark indigo for dark mode
                          : Color(0xFF1976D2)
                              .withOpacity(0.5), // Blue for light mode
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode
                          ? Colors.black.withOpacity(0.2)
                          : Color(0xFF1976D2).withOpacity(0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
          leading: _isInSelectionMode
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: _toggleSelectionMode,
                )
              : IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    try {
                      // Mark messages as read before navigating back
                      await _chatService.markMessagesAsRead(
                          widget.recieverID, currentUserID);

                      // Pop and send true to indicate messages were read
                      // This will force HomePage to refresh
                      Navigator.of(context).pop(true);
                    } catch (e) {
                      print("Error navigating back: $e");
                      // Fallback navigation if there's an error
                      Navigator.of(context).pop();
                    }
                  },
                ),
          actions: [
            // Selection mode actions
            if (_isInSelectionMode) ...[
              IconButton(
                icon: Icon(
                  Icons.select_all,
                  color: Colors.white,
                ),
                onPressed: () {
                  // Use the stream snapshot directly from the message list builder
                  final messagesStream = _chatService.getMessages(
                    widget.recieverID,
                    _authService.getCurrentUser()!.uid,
                  );

                  // Get the snapshot data and select all messages
                  messagesStream.first.then((snapshot) {
                    if (snapshot.docs.isNotEmpty) {
                      _selectAllMessages(snapshot.docs);
                    }
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                onPressed: _selectedMessageIds.isNotEmpty
                    ? _deleteSelectedMessages
                    : null,
              ),
            ] else ...[
              // Normal mode actions
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
                onPressed: () {
                  _showChatOptions(context);
                },
              ),
            ],
          ],
        ),
        body: Column(
          children: [
            // Messages list
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/chat_bg.png'),
                    fit: BoxFit.cover,
                    opacity: isDarkMode ? 0.03 : 0.05, // Dimmer in dark mode
                    colorFilter: isDarkMode
                        ? ColorFilter.mode(
                            Color(0xFF0A1929), BlendMode.hardLight)
                        : null,
                  ),
                ),
                padding: EdgeInsets.only(top: kToolbarHeight + 40),
                child: _buildMessageList(),
              ),
            ),

            // Message input area
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  // New receiver info UI
  Widget _buildReceiverInfo() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Row(
      children: [
        // Avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDarkMode
                ? Color(0xFF1E88E5)
                : Color(0xFF2196F3), // Bright blue
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Color(0xFF1565C0)
                        .withOpacity(0.3) // Darker blue shadow for dark mode
                    : Color(0xFF1976D2).withOpacity(0.3), // Blue shadow
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.recieverName != null && widget.recieverName!.isNotEmpty
                  ? widget.recieverName![0].toUpperCase()
                  : widget.recieverEmail[0].toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),

        SizedBox(width: 12),

        // Name and status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name
              Text(
                widget.recieverName ?? widget.recieverEmail,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),

              // Online status
              Text(
                "", // Removed "Online" text
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Message input area
  Widget _buildInputArea() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    bool isEmpty = _messageController.text.trim().isEmpty;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF102A43).withOpacity(0.9) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.5)
                : Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image preview if an image is selected
          if (_imageFile != null)
            Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 12),
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(_imageFile!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _imageFile = null;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                if (_isUploading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.4),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

          Row(
            children: [
              // Attachment button
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.attach_file,
                  color: isDarkMode ? Colors.white70 : Color(0xFF1976D2),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'gallery':
                      _pickImage(ImageSource.gallery);
                      break;
                    case 'camera':
                      _pickImage(ImageSource.camera);
                      break;
                    case 'files':
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('File attachment coming soon')));
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'gallery',
                    child: Row(
                      children: [
                        Icon(Icons.photo_library, color: Color(0xFF4CAF50)),
                        SizedBox(width: 10),
                        Text('Gallery'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'camera',
                    child: Row(
                      children: [
                        Icon(Icons.camera_alt, color: Color(0xFF2196F3)),
                        SizedBox(width: 10),
                        Text('Camera'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'files',
                    child: Row(
                      children: [
                        Icon(Icons.insert_drive_file, color: Color(0xFFFFA000)),
                        SizedBox(width: 10),
                        Text('Files'),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(width: 8),

              // Text input field
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Color(0xFF1E3A5F)
                        : Color(0xFFE3F2FD).withOpacity(0.7),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isDarkMode
                          ? Color(0xFF3949AB).withOpacity(0.3)
                          : Color(0xFF2196F3).withOpacity(0.3),
                    ),
                  ),
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: _imageFile != null
                          ? 'Add a caption...'
                          : 'Type a message...',
                      hintStyle: TextStyle(
                        color: isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    onEditingComplete: _sendMessage,
                  ),
                ),
              ),
              SizedBox(width: 8),

              // Send button
              InkWell(
                onTap: () {
                  if (_isUploading) {
                    // Don't allow multiple uploads at once
                    return;
                  }

                  if (_imageFile != null) {
                    // If we have an image, send it regardless of text
                    _uploadAndSendImage();
                  } else if (_messageController.text.trim().isNotEmpty) {
                    // Otherwise only send if there's text
                    _sendMessage();
                  }
                },
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _isUploading
                        ? (isDarkMode ? Color(0xFF1565C0) : Color(0xFF1976D2))
                        : (isDarkMode ? Color(0xFF1E88E5) : Color(0xFF2196F3)),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode
                            ? Color(0xFF1976D2).withOpacity(0.3)
                            : Color(0xFF1976D2).withOpacity(0.2),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _isUploading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Show chat options menu
  void _showChatOptions(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    // Calculate position based on AppBar (typically right-aligned)
    final RenderBox? overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;

    // Show popup menu instead of bottom sheet
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          overlay!.size.width - 10, kToolbarHeight + 5, 10, 0),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDarkMode ? Color(0xFF102A43) : Colors.white,
      items: [
        // Block user option
        PopupMenuItem(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 48,
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (isDarkMode ? Colors.grey[700] : Colors.grey[200])!,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.block_rounded,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                  size: 16,
                ),
              ),
              SizedBox(width: 12),
              Text(
                "Block User",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          onTap: () {
            _blockUser();
          },
        ),

        // Clear chat option
        PopupMenuItem(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 48,
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (isDarkMode ? Colors.red[900] : Colors.red[50])!
                      .withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: isDarkMode ? Colors.red[300] : Colors.red,
                  size: 16,
                ),
              ),
              SizedBox(width: 12),
              Text(
                "Delete All Messages",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          onTap: () {
            _showClearChatConfirmation();
          },
        ),

        // Report user option
        PopupMenuItem(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: 48,
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (isDarkMode ? Colors.amber[900] : Colors.amber[50])!
                      .withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.report_outlined,
                  color: isDarkMode ? Colors.amber[300] : Colors.amber[700],
                  size: 16,
                ),
              ),
              SizedBox(width: 12),
              Text(
                "Report User",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          onTap: () {
            _reportUser();
          },
        ),
      ],
    );
  }

  // Block user functionality
  void _blockUser() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFFE3F2FD),
        title: Text(
          "Block User",
          style: TextStyle(color: Color(0xFF1976D2)),
        ),
        content: Text(
          "Are you sure you want to block ${widget.recieverName ?? widget.recieverEmail}? They won't be able to send you messages.",
          style: TextStyle(color: Color(0xFF1976D2).withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: Color(0xFF1976D2).withOpacity(0.7)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              // Get current user ID
              final currentUserID = _authService.getCurrentUser()!.uid;

              // Add user to blocked list in Firestore
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUserID)
                  .collection('blocked_users')
                  .doc(widget.recieverID)
                  .set({
                'email': widget.recieverEmail,
                'name': widget.recieverName,
                'blocked_at': FieldValue.serverTimestamp(),
              });

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("User blocked successfully"),
                  backgroundColor: Colors.red,
                ),
              );

              // Navigate back to home screen
              Navigator.of(context).pop();
            },
            child: Text(
              "Block",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced message list
  Widget _buildMessageList() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return StreamBuilder(
      stream: _chatService.getMessages(
        widget.recieverID,
        _authService.getCurrentUser()!.uid,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Something went wrong!",
              style: TextStyle(
                color: isDarkMode ? Colors.red[200] : Colors.red,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: isDarkMode
                  ? Color(0xFF64B5F6)
                  : Color(0xFF1976D2), // Brighter blue in dark mode
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "Send a message to start the conversation!",
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          );
        }

        // Convert to list for easier handling
        List<DocumentSnapshot> messages = snapshot.data!.docs;

        // Check if we received a new message
        bool receivedNewMessage = _previousMessageCount != null &&
            _previousMessageCount! < messages.length;
        _previousMessageCount = messages.length;

        // Trigger scroll to bottom when messages load or when new messages arrive
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Always scroll on initial load, when new messages arrive, or when forced
          if (receivedNewMessage ||
              _previousMessageCount == 1 ||
              _forceScrollToBottom) {
            scrollDown();
            _forceScrollToBottom = false; // Reset the flag
          }
        });

        return ListView.builder(
          controller: _scrollController,
          reverse: false, // Newest messages at bottom
          itemCount: messages.length,
          padding: EdgeInsets.only(
              top: 8,
              bottom: 16,
              left: 8,
              right: 8), // Add proper padding all around
          physics:
              AlwaysScrollableScrollPhysics(), // Enable scrolling even when content doesn't fill the screen
          itemBuilder: (context, index) {
            final doc = messages[index];
            final data = doc.data() as Map<String, dynamic>;

            // Get message data
            final String messageId = doc.id;
            final String message = data["message"] ?? "";
            final String senderID = data["senderID"] ?? "";
            final Timestamp timestamp = data["timestamp"] as Timestamp;
            final bool isRead = data["seen"] ?? false;
            final String messageType = data["type"] ?? "text";
            final String? imageUrl = data["imageUrl"];

            // Determine if this is from the current user
            final bool isCurrentUser =
                senderID == _authService.getCurrentUser()!.uid;

            // Check if this message is selected
            final bool isSelected = _selectedMessageIds.contains(messageId);

            // Determine if this is the first unread message (for indicator)
            bool isFirstUnread = false;
            if (!isCurrentUser && !isRead && index > 0) {
              // Check previous message
              final prevData =
                  messages[index - 1].data() as Map<String, dynamic>;
              final prevSenderID = prevData["senderID"] ?? "";
              final prevIsRead = prevData["seen"] ?? false;

              // If previous message was read or from current user, this is first unread
              isFirstUnread = prevIsRead ||
                  prevSenderID == _authService.getCurrentUser()!.uid;
            }

            return Column(
              children: [
                // Show new messages indicator if this is first unread
                if (isFirstUnread)
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFF1976D2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFF1976D2).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      "New Messages",
                      style: TextStyle(
                        color: Color(0xFF1976D2),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                // The actual chat bubble
                ChatBubble(
                  message: message,
                  isCurrentUser: isCurrentUser,
                  isRead: isRead,
                  timestamp: timestamp,
                  messageId: messageId,
                  isSelected: isSelected,
                  messageType: messageType,
                  imageUrl: imageUrl,
                  onLongPress: (String id) {
                    if (_isInSelectionMode) {
                      _toggleMessageSelection(id);
                    } else {
                      _toggleSelectionMode();
                      _toggleMessageSelection(id);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Method to show attachment options
  void _showAttachmentOptions() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    print("Opening attachment options..."); // Debug print

    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: isDarkMode ? Color(0xFF10243E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Share Content",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Gallery option
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Color(0xFF4CAF50)
                                  .withOpacity(isDarkMode ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              Icons.photo_library,
                              color: Color(0xFF4CAF50),
                              size: 30,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Gallery",
                            style: TextStyle(
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Camera option
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Color(0xFF2196F3)
                                  .withOpacity(isDarkMode ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Color(0xFF2196F3),
                              size: 30,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Camera",
                            style: TextStyle(
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Files option
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        // Implement file attachment
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("File sharing coming soon!")));
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Color(0xFFFFA000)
                                  .withOpacity(isDarkMode ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              Icons.insert_drive_file,
                              color: Color(0xFFFFA000),
                              size: 30,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Files",
                            style: TextStyle(
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      print("Bottom sheet closed with value: $value"); // Debug print
    }).catchError((error) {
      print("Error showing bottom sheet: $error"); // Debug print
    });
  }

  // Method to send a message
  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      // Set flag to force scroll to bottom when the message appears
      _forceScrollToBottom = true;

      await _chatService.sendMessage(
          widget.recieverID, _messageController.text);

      _messageController.clear();

      // Added delay to ensure the message appears in the list before scrolling
      Future.delayed(const Duration(milliseconds: 500), () {
        scrollDown();
      });
    }
  }

  // Show confirmation dialog for clearing chat
  void _showClearChatConfirmation() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Color(0xFF102A43) : Colors.white,
        title: Text(
          "Delete All Messages?",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "This will permanently delete ALL messages in this conversation. This action cannot be undone.",
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearChat(); // This will delete all messages
            },
            child: Text(
              "Delete All",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Clear all messages in the chat
  void _clearChat() {
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

    try {
      // Get the current user ID and generate the chat room ID
      final String currentUserID = _authService.getCurrentUser()!.uid;
      List<String> ids = [currentUserID, widget.recieverID];
      ids.sort();
      String chatRoomID = ids.join('_');

      // Get reference to messages collection
      final messagesCollection = FirebaseFirestore.instance
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages");

      // Get all messages first, then delete them
      messagesCollection.get().then((snapshot) async {
        // Check if there are messages to delete
        if (snapshot.docs.isEmpty) {
          // Close loading indicator
          Navigator.pop(context);

          // Show message
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("No messages to clear"),
            backgroundColor: Colors.blue,
          ));
          return;
        }

        print("Found ${snapshot.docs.length} messages to delete");

        try {
          // Delete each message - needs to be sequential
          for (var doc in snapshot.docs) {
            await doc.reference.delete();
          }

          // All messages deleted successfully
          print("Successfully deleted all ${snapshot.docs.length} messages");

          // Reset UI state
          setState(() {
            if (_imageFile != null) {
              _imageFile = null;
            }
            _forceScrollToBottom = true;
            if (_isInSelectionMode) {
              _isInSelectionMode = false;
              _selectedMessageIds.clear();
            }
          });

          // Close loading indicator
          Navigator.pop(context);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("All messages cleared successfully"),
            backgroundColor: Colors.green,
          ));
        } catch (err) {
          // Error deleting messages
          print("Error deleting messages: $err");

          // Close loading indicator
          Navigator.pop(context);

          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Error clearing messages: $err"),
            backgroundColor: Colors.red,
          ));
        }
      }).catchError((error) {
        print("Error getting messages: $error");

        // Close loading indicator
        Navigator.pop(context);

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error accessing messages: $error"),
          backgroundColor: Colors.red,
        ));
      });
    } catch (e) {
      // Generic error
      print("Error in clear chat function: $e");

      // Close loading indicator
      Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error clearing chat: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  // Report user functionality
  void _reportUser() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Color(0xFF10243E) : Colors.white,
        title: Text(
          "Report User",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Why are you reporting this user?",
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            SizedBox(height: 16),
            _buildReportOption("Inappropriate messages"),
            _buildReportOption("Spam"),
            _buildReportOption("Harassment"),
            _buildReportOption("Fake profile"),
            _buildReportOption("Other"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for report options
  Widget _buildReportOption(String reason) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        // Show confirmation
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Report submitted. Thank you for your feedback."),
          backgroundColor: Colors.green,
        ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(
              Icons.radio_button_unchecked,
              size: 20,
              color: isDarkMode ? Colors.amber[300] : Colors.amber[700],
            ),
            SizedBox(width: 12),
            Text(
              reason,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to pick image from gallery
  Future<void> _pickImage(ImageSource source) async {
    // Don't allow selecting a new image while one is already uploading
    if (_isUploading) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please wait until current upload completes')),
      );
      return;
    }

    try {
      // Show progress indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Opening image picker...')),
      );

      // Try to get the image with explicit user action (not auto-opening)
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70, // Reduce quality to optimize file size
        maxWidth: 1200, // Limit dimensions to save storage
        maxHeight: 1200,
      );

      // Clear the snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Only process if the user selected an image (not if gallery opened automatically)
      if (pickedFile != null) {
        print('Image picked: ${pickedFile.path}');

        // Check if file exists
        final file = File(pickedFile.path);
        final fileExists = await file.exists();
        print('File exists: $fileExists');

        if (!fileExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: Selected file does not exist'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Check file size and show warning for large files
        final fileSize = await file.length();
        final fileSizeKB = (fileSize / 1024).round();
        print('Image size: ${fileSizeKB}KB');

        // Warn user if image is large
        if (fileSizeKB > 5000) {
          // 5MB
          // Show warning for large files
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Warning: Large image (${(fileSizeKB / 1024).toStringAsFixed(1)}MB). Upload may be slow.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }

        setState(() {
          _imageFile = file;
        });

        // Don't automatically upload - let user add caption first
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Image selected. Add caption (optional) and press send.'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        print('No image selected or gallery closed');
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Error selecting image: ${e.toString().split('\n')[0]}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Method to upload and send image with optimized approach
  Future<void> _uploadAndSendImage() async {
    if (_imageFile == null) return;

    try {
      setState(() {
        _isUploading = true;
      });

      // Create the chatroom ID
      String chatRoomId = _chatService.getChatRoomID(
        _authService.getCurrentUser()!.uid,
        widget.recieverID,
      );

      print('Starting image upload to Firebase Storage');
      // Verify file exists and has content
      if (!await _imageFile!.exists()) {
        throw Exception('Image file does not exist');
      }

      final fileSize = await _imageFile!.length();
      print('Image size: ${(fileSize / 1024).round()}KB');

      // Get start time to measure upload performance
      final startTime = DateTime.now();

      // Upload the image with optimized storage service
      String imageUrl = await _storageService
          .uploadImage(_imageFile!, chatRoomId)
          .timeout(const Duration(seconds: 30), onTimeout: () {
        throw TimeoutException('Image upload timed out');
      });

      print(
          'Image uploaded successfully. URL: ${imageUrl.substring(0, 50)}...');

      // Calculate upload duration
      final uploadDuration = DateTime.now().difference(startTime);
      print('Image upload took: ${uploadDuration.inMilliseconds}ms');

      // Send the image message with an optional caption
      await _chatService.sendImageMessage(
        widget.recieverID,
        imageUrl,
        message: _messageController.text.trim(),
      );

      print('Image message sent successfully');

      // Clear the message input and image
      _messageController.clear();
      setState(() {
        _imageFile = null;
        _isUploading = false;
        // Set flag to force scroll to bottom when the message appears
        _forceScrollToBottom = true;
      });

      // Scroll to bottom after sending with a slight delay to ensure message is rendered
      Future.delayed(const Duration(milliseconds: 300), () {
        scrollDown();
      });
    } catch (e) {
      print('Error uploading image: $e');

      setState(() {
        _isUploading = false;
      });

      String errorMessage = 'Error sending image. Please try again.';

      if (e.toString().contains('storage/unauthorized')) {
        errorMessage =
            'Storage permission denied. Please check your permissions.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage =
            'Upload timed out. Please check your internet connection.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('object-not-found')) {
        errorMessage =
            'Could not access storage. Contact support if problem persists.';
      } else if (e.toString().contains('Storage path error')) {
        errorMessage =
            'Problem with storage path. Try again with a different image.';
      } else if (e.toString().contains('quota-exceeded')) {
        errorMessage = 'Storage quota exceeded. Please contact support.';
      } else if (e.toString().contains('File does not exist')) {
        errorMessage = 'Could not access the selected image file.';
      } else if (e.toString().contains('Image too large')) {
        errorMessage =
            'Image is too large. Please select a smaller image (under 10MB).';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () {
              if (_imageFile != null) {
                _uploadAndSendImage();
              }
            },
          ),
        ),
      );
    }
  }

  // Check and request permissions for image picker
  Future<void> _checkAndRequestPermissions() async {
    try {
      // This will prompt for permissions if needed but won't automatically open gallery
      final XFile? testFile = await _imagePicker
          .pickImage(
        source: ImageSource.gallery,
        maxWidth: 1,
        maxHeight: 1,
        imageQuality: 1,
      )
          .timeout(Duration(milliseconds: 100), onTimeout: () {
        // If it takes too long, just cancel to avoid opening the gallery
        print("Permission check timeout - preventing gallery from opening");
        return null;
      });

      if (testFile != null) {
        print("Permission already granted");
        // Clean up the test file
        File(testFile.path)
            .delete()
            .catchError((e) => print("Error deleting test file: $e"));
      }
    } catch (e) {
      print("Permission check failed: $e");
    }
  }
}

// Create a separate stateful widget for the message input to isolate rebuilds
class MessageInputField extends StatefulWidget {
  final TextEditingController messageController;
  final FocusNode focusNode;
  final VoidCallback onSend;

  const MessageInputField({
    super.key,
    required this.messageController,
    required this.focusNode,
    required this.onSend,
  });

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  // Local state to track if the text field is empty
  bool _isEmpty = true;

  @override
  void initState() {
    super.initState();
    // Initialize empty state
    _isEmpty = widget.messageController.text.trim().isEmpty;

    // Listen for changes without rebuilding the entire chat page
    widget.messageController.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    // Remove listener to prevent memory leaks
    widget.messageController.removeListener(_handleTextChange);
    super.dispose();
  }

  // Only update state when the empty status changes
  void _handleTextChange() {
    final isEmpty = widget.messageController.text.trim().isEmpty;
    if (isEmpty != _isEmpty) {
      setState(() {
        _isEmpty = isEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFF90CAF9).withOpacity(0.7), // Light blue background
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1976D2).withOpacity(0.2), // Blue shadow
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Message text field - optimized to prevent screen flicker
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Color(0xFF90CAF9).withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: widget.messageController,
                focusNode: widget.focusNode,
                style: TextStyle(color: Color(0xFF1976D2)),
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  hintStyle:
                      TextStyle(color: Color(0xFF1976D2).withOpacity(0.6)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  if (!_isEmpty) {
                    widget.onSend();
                  }
                },
              ),
            ),
          ),

          SizedBox(width: 8),

          // Send button - always visible
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1976D2), // Dark blue
                  Color(0xFF2196F3), // Bright blue
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF1976D2).withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.send_rounded, color: Colors.white),
              onPressed: _isEmpty ? null : widget.onSend,
            ),
          ),
        ],
      ),
    );
  }
}
