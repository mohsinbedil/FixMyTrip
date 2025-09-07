import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Simple class to hold message data with proper encapsulation
class ChatMessage {
  final String id;
  final Map<String, dynamic> data;

  ChatMessage({required this.id, required this.data});
}

class UserChatScreen extends StatefulWidget {
  const UserChatScreen({super.key});

  @override
  _UserChatScreenState createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  // Controllers and Firebase instances
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();

  // State variables
  List<Map<String, dynamic>> _admins = [];
  final List<ChatMessage> _cachedMessages = [];
  bool _isInitialLoad = true;
  String? _selectedAdminId;
  String? _currentChatId;

  @override
  void initState() {
    super.initState();
    _loadAdmins(); // Load available admins when screen initializes
  }

  /// Loads all admin users from Firestore 'admins' collection
  void _loadAdmins() async {
    try {
      final snapshot = await _firestore.collection('admins').get();
      setState(() {
        _admins = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id, // Document ID
            'name': (data['name'] as String?) ?? 'Admin',
            'email': (data['email'] as String?) ?? '',
            'uid': (data['uid'] as String?) ?? '', // Admin's Firebase UID
          };
        }).toList();

        // Select the first admin by default if available
        if (_admins.isNotEmpty) {
          _selectedAdminId = _admins[0]['id'];
          _getOrCreateChat();
        }
      });
    } catch (e) {
      print('Error loading admins: $e');
    }
  }

  /// Gets or creates a chat group with the selected admin
/// Gets or creates a chat group with the selected admin
void _getOrCreateChat() async {
  final currentUserId = _auth.currentUser?.uid;
  if (currentUserId == null || _selectedAdminId == null) return;

  try {
    // Check if a chat already exists between user and admin
    final existingChats = await _firestore
        .collection('chat')
        .where('participants', arrayContains: currentUserId)
        .get();

    String chatId = ''; // Initialize with empty string
    bool chatExists = false;

    // Look for a chat that includes both the user and the selected admin
    for (var chatDoc in existingChats.docs) {
      final participants = List<String>.from(chatDoc.data()['participants'] ?? []);
      if (participants.contains(_selectedAdminId)) {
        chatId = chatDoc.id;
        chatExists = true;
        break;
      }
    }

    if (!chatExists) {
      // Create a new chat group
      final newChatRef = await _firestore.collection('chat').add({
        'participants': [currentUserId, _selectedAdminId],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'adminId': _selectedAdminId,
        'userId': currentUserId,
      });
      
      chatId = newChatRef.id;
    }

    setState(() {
      _currentChatId = chatId;
    });
    
    _markMessagesAsRead();
  } catch (e) {
    print('Error getting/creating chat: $e');
  }
}

  /// Marks messages from admin as read for the current user
  void _markMessagesAsRead() async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null || _currentChatId == null) return;

    try {
      // Query unread messages from admin
      final unreadMessages = await _firestore
          .collection('chat')
          .doc(_currentChatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: currentUserId)
          .where('read', isEqualTo: false)
          .get();

      // Update each unread message
      for (var doc in unreadMessages.docs) {
        await doc.reference.update({
          'read': true,
          'readBy': FieldValue.arrayUnion([currentUserId]),
        });
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  /// Scrolls the message list to the bottom (newest message)
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _auth.currentUser?.uid;
    final currentUserEmail = _auth.currentUser?.email;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Chat Support",
              style: GoogleFonts.quicksand(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _selectedAdminId != null ? "Connected to Admin" : "Select an Admin",
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1B263B),
        foregroundColor: Colors.white,
        elevation: 1,
        actions: [
          if (_admins.isNotEmpty)
            PopupMenuButton(
              icon: const Icon(Icons.person),
              itemBuilder: (context) => _admins.map((admin) {
                return PopupMenuItem(
                  value: admin['id'],
                  child: Text(
                    admin['name'] as String,
                    style: GoogleFonts.poppins(),
                  ),
                );
              }).toList(),
              onSelected: (adminId) {
                setState(() {
                  _selectedAdminId = adminId as String;
                  _isInitialLoad = true;
                  _cachedMessages.clear();
                  _currentChatId = null;
                });
                _getOrCreateChat();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Show message if no admins available
          if (_selectedAdminId == null)
            Expanded(
              child: Center(
                child: Text(
                  "No admins available",
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
              ),
            )
          else if (_currentChatId == null)
            Expanded(
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          else
            // Main chat message area
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chat')
                    .doc(_currentChatId)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  // Show loading indicator on initial load
                  if (_isInitialLoad &&
                      snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    // Cache messages to prevent full redraws on every update
                    if (_isInitialLoad) {
                      _cachedMessages.clear();
                      _cachedMessages.addAll(
                        snapshot.data!.docs.map(
                          (doc) => ChatMessage(
                            id: doc.id,
                            data: doc.data() as Map<String, dynamic>,
                          ),
                        ),
                      );
                      _isInitialLoad = false;

                      // Scroll to bottom after initial load completes
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToBottom();
                      });
                    } else {
                      // Only update with new messages (optimization)
                      final newMessages = snapshot.data!.docs;
                      if (newMessages.length > _cachedMessages.length) {
                        _cachedMessages.addAll(
                          newMessages
                              .skip(_cachedMessages.length)
                              .map(
                                (doc) => ChatMessage(
                                  id: doc.id,
                                  data: doc.data() as Map<String, dynamic>,
                                ),
                              )
                              .toList(),
                        );

                        // Scroll to bottom when new message is added
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToBottom();
                        });
                      }
                    }

                    // Build list of message bubbles
                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true, // Newest messages at bottom
                      itemCount: _cachedMessages.length,
                      itemBuilder: (context, index) {
                        final message = _cachedMessages[index];
                        final isMe = message.data['senderId'] == currentUserId;

                        return _buildMessageBubble(
                          message,
                          isMe,
                          currentUserEmail ?? 'User',
                        );
                      },
                    );
                  }

                  // Empty state when no messages exist
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat, size: 64, color: Colors.grey.shade600),
                        const SizedBox(height: 16),
                        Text(
                          "Start a conversation with admin",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          // Message input field at bottom
          _buildMessageInput(),
        ],
      ),
    );
  }

  /// Builds individual message bubble widget
  Widget _buildMessageBubble(
    ChatMessage message,
    bool isMe,
    String currentUserEmail,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Admin avatar (only show for admin messages)
          if (!isMe)
            CircleAvatar(
              backgroundColor: Colors.blueAccent.withOpacity(0.2),
              radius: 16,
              child: Icon(
                Icons.admin_panel_settings,
                color: Colors.blueAccent,
                size: 16,
              ),
            ),
          const SizedBox(width: 8),
          // Message bubble content
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF005C4B) : const Color(0xFF202C33),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(8),
                  topRight: const Radius.circular(8),
                  bottomLeft: isMe ? const Radius.circular(8) : const Radius.circular(2),
                  bottomRight: isMe ? const Radius.circular(2) : const Radius.circular(8),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show "Admin" label for admin messages
                  if (!isMe)
                    Text(
                      'Admin',
                      style: GoogleFonts.poppins(
                        color: Colors.blueAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (!isMe) const SizedBox(height: 4),
                  // Message text
                  Text(
                    message.data['text'],
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  // Message metadata (time and read status)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _formatTimestamp(message.data['timestamp']),
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                      if (isMe) const SizedBox(width: 4),
                      // Read/delivery status icons (only for user's messages)
                      if (isMe)
                        Icon(
                          message.data['read'] == true ? Icons.done_all : Icons.done,
                          size: 12,
                          color: message.data['read'] == true ? Colors.blueAccent : Colors.white70,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  /// Formats Firestore timestamp to readable time string
  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('HH:mm').format(date);
  }

  /// Builds the message input field and send button
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: const Color(0xFF1B263B),
      child: Row(
        children: [
          // Text input field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2D3748),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  hintStyle: GoogleFonts.poppins(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                minLines: 1,
                maxLines: 3,
                enabled: _selectedAdminId != null && _currentChatId != null,
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Send button
          CircleAvatar(
            backgroundColor: (_selectedAdminId != null && _currentChatId != null) 
                ? Colors.blueAccent : Colors.grey,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: (_selectedAdminId != null && _currentChatId != null) 
                  ? _sendMessage : null,
            ),
          ),
        ],
      ),
    );
  }

  /// Sends a new message to Firestore
  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final currentUserId = _auth.currentUser?.uid;
    final currentUserEmail = _auth.currentUser?.email;
    if (currentUserId == null || _currentChatId == null) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    try {
      // Create a temporary message ID
      final tempMessageId = DateTime.now().millisecondsSinceEpoch.toString();

      // Create message data
      final newMessageData = {
        'text': messageText,
        'senderId': currentUserId,
        'senderEmail': currentUserEmail,
        'timestamp': Timestamp.now(),
        'read': false,
        'readBy': [],
      };

      // Add to cache immediately for instant UI update
      setState(() {
        _cachedMessages.add(
          ChatMessage(id: tempMessageId, data: newMessageData),
        );
      });

      // Scroll to bottom after adding to cache
      _scrollToBottom();

      // Write to Firestore - save to chat collection
      final newMessageRef = await _firestore
          .collection('chat')
          .doc(_currentChatId)
          .collection('messages')
          .add(newMessageData);

      // Update the cached message with the real Firestore ID
      setState(() {
        final index = _cachedMessages.indexWhere((msg) => msg.id == tempMessageId);
        if (index != -1) {
          _cachedMessages[index] = ChatMessage(
            id: newMessageRef.id,
            data: {...newMessageData, 'id': newMessageRef.id},
          );
        }
      });

      // Update last message info in chat document
      await _firestore.collection('chat').doc(_currentChatId).update({
        'lastMessage': messageText,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Remove from cache if there was an error
      setState(() {
        _cachedMessages.removeWhere((msg) => msg.id.length > 10 && msg.id.startsWith('1'));
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to send message: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}