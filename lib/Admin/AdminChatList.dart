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

class AdminChatScreen extends StatefulWidget {
  const AdminChatScreen({super.key});

  @override
  _AdminChatScreenState createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  // Controllers and Firebase instances
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();

  // State variables
  List<Map<String, dynamic>> _chats = [];
  final List<ChatMessage> _cachedMessages = [];
  bool _isInitialLoad = true;
  String? _selectedChatId;
  String? _currentChatId;
  Map<String, int> _unreadCounts = {};

  @override
  void initState() {
    super.initState();
    _loadChats(); // Load all chats when screen initializes
    _setupUnreadListener(); // Listen for unread messages
  }

  /// Loads all chats where current admin is a participant
  void _loadChats() async {
    final currentAdminId = _auth.currentUser?.uid;
    if (currentAdminId == null) return;

    try {
      final snapshot = await _firestore
          .collection('chat')
          .where('adminId', isEqualTo: currentAdminId)
          .get();

      setState(() {
        _chats = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id, // Chat document ID
            'userId': data['userId'],
            'userEmail': data['userEmail'] ?? 'User',
            'userName': data['userName'] ?? 'User',
            'lastMessage': data['lastMessage'] ?? '',
            'lastMessageTime': data['lastMessageTime'],
          };
        }).toList();

        // Select the first chat by default if available
        if (_chats.isNotEmpty) {
          _selectedChatId = _chats[0]['id'];
          _currentChatId = _selectedChatId;
          _markMessagesAsRead();
        }
      });
    } catch (e) {
      print('Error loading chats: $e');
    }
  }

  /// Sets up a listener to track unread message counts for all chats
  void _setupUnreadListener() {
    final currentAdminId = _auth.currentUser?.uid;
    if (currentAdminId == null) return;

    _firestore
        .collection('chat')
        .where('adminId', isEqualTo: currentAdminId)
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        final chatId = doc.id;
        final userId = doc.data()['userId'];

        if (userId != null) {
          // Listen for unread messages in this chat
          _firestore
              .collection('chat')
              .doc(chatId)
              .collection('messages')
              .where('senderId', isEqualTo: userId)
              .where('read', isEqualTo: false)
              .snapshots()
              .listen((messageSnapshot) {
            setState(() {
              _unreadCounts[chatId] = messageSnapshot.docs.length;
            });
          });
        }
      }
    });
  }

  /// Marks messages from user as read for the current admin
  void _markMessagesAsRead() async {
    final currentAdminId = _auth.currentUser?.uid;
    if (currentAdminId == null || _currentChatId == null) return;

    try {
      // Query unread messages from user
      final unreadMessages = await _firestore
          .collection('chat')
          .doc(_currentChatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: currentAdminId)
          .where('read', isEqualTo: false)
          .get();

      // Update each unread message
      for (var doc in unreadMessages.docs) {
        await doc.reference.update({
          'read': true,
          'readBy': FieldValue.arrayUnion([currentAdminId]),
        });
      }

      // Reset unread count for this chat
      setState(() {
        if (_currentChatId != null) {
          _unreadCounts[_currentChatId!] = 0;
        }
      });
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
    final currentAdminId = _auth.currentUser?.uid;
    final currentAdminEmail = _auth.currentUser?.email;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Admin Chat",
              style: GoogleFonts.quicksand(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _selectedChatId != null ? "Chatting with User" : "Select a Chat",
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1B263B),
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: Row(
        children: [
          // Chats list sidebar
          Container(
            width: 300,
            color: const Color(0xFF1B263B),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Chats",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _chats.length,
                    itemBuilder: (context, index) {
                      final chat = _chats[index];
                      final unreadCount = _unreadCounts[chat['id']] ?? 0;
                      
                      return ListTile(
                        title: Text(
                          chat['userName'] as String,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: _selectedChatId == chat['id'] 
                                ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          chat['userEmail'] as String,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                          ),
                        ),
                        trailing: unreadCount > 0
                            ? CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: Text(
                                  unreadCount.toString(),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedChatId = chat['id'];
                            _currentChatId = chat['id'];
                            _isInitialLoad = true;
                            _cachedMessages.clear();
                          });
                          _markMessagesAsRead();
                        },
                        selected: _selectedChatId == chat['id'],
                        selectedTileColor: Colors.blueAccent.withOpacity(0.2),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Vertical divider
          const VerticalDivider(width: 1, color: Colors.grey),
          
          // Main chat area
          Expanded(
            child: Column(
              children: [
                // Show message if no chat selected
                if (_selectedChatId == null)
                  Expanded(
                    child: Center(
                      child: Text(
                        "Select a chat to start messaging",
                        style: GoogleFonts.poppins(color: Colors.white70),
                      ),
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
                              final isMe = message.data['senderId'] == currentAdminId;

                              return _buildMessageBubble(
                                message,
                                isMe,
                                currentAdminEmail ?? 'Admin',
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
                                "Start a conversation with user",
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
          ),
        ],
      ),
    );
  }

  /// Builds individual message bubble widget
  Widget _buildMessageBubble(
    ChatMessage message,
    bool isMe,
    String currentAdminEmail,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // User avatar (only show for user messages)
          if (!isMe)
            CircleAvatar(
              backgroundColor: Colors.greenAccent.withOpacity(0.2),
              radius: 16,
              child: Icon(
                Icons.person,
                color: Colors.greenAccent,
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
                  // Show "User" label for user messages
                  if (!isMe)
                    Text(
                      'User',
                      style: GoogleFonts.poppins(
                        color: Colors.greenAccent,
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
                      // Read/delivery status icons (only for admin's messages)
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
                enabled: _selectedChatId != null,
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Send button
          CircleAvatar(
            backgroundColor: _selectedChatId != null 
                ? Colors.blueAccent : Colors.grey,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _selectedChatId != null 
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

    final currentAdminId = _auth.currentUser?.uid;
    final currentAdminEmail = _auth.currentUser?.email;
    if (currentAdminId == null || _currentChatId == null) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    try {
      // Create a temporary message ID
      final tempMessageId = DateTime.now().millisecondsSinceEpoch.toString();

      // Create message data
      final newMessageData = {
        'text': messageText,
        'senderId': currentAdminId,
        'senderEmail': currentAdminEmail,
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
        _cachedMessages.removeWhere((msg) => msg.id == DateTime.now().millisecondsSinceEpoch.toString());
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