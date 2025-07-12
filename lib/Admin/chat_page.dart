import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

 class AdminChatPage extends StatefulWidget {
  const AdminChatPage({super.key});

  @override
  State<AdminChatPage> createState() => _AdminChatPageState();
}

class _AdminChatPageState extends State<AdminChatPage> {
  String? selectedUserId;                   // Holds currently selected user ID to chat with
  bool sidebarVisible = true;               // Controls visibility of sidebar (user list)
  final TextEditingController _messageController = TextEditingController();  // Controller for message input field
  static const adminName = 'Deliverer';    // Name used for admin messages

  Map<String, String> userIdToName = {};   // Map user IDs to their names

  @override
  void initState() {
    super.initState();
    _loadUsers();                         // Load all users from database when page loads
  }

  Future<void> _loadUsers() async {
    // Fetch all users from Firestore 'users' collection
    final snapshot = await FirebaseFirestore.instance.collection('users').get();

    final Map<String, String> loadedUsers = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final uid = data['uid'] as String?;    // Get user ID
      final name = data['name'] as String?;  // Get user name
      if (uid != null && name != null) {
        loadedUsers[uid] = name;              // Store in map if both present
      }
    }
    setState(() => userIdToName = loadedUsers);  // Update state to hold user list
  }

  void _sendMessage() async {
    // Don't send if no user selected or message is empty
    if (selectedUserId == null || _messageController.text.trim().isEmpty) return;

    // Add new message to 'chats' collection in Firestore
    await FirebaseFirestore.instance.collection('chats').add({
      'text': _messageController.text.trim(),   // Message text (trimmed)
      'timestamp': FieldValue.serverTimestamp(), // Server timestamp for sorting
      'senderId': 'admin',                        // Mark sender as admin
      'senderName': adminName,                    // Admin display name
      'userId': selectedUserId,                   // User this chat belongs to
      'receiverId': selectedUserId,               // Message receiver (user)
    });

    _messageController.clear();                    // Clear input after sending
  }

  void _deleteMessage(String messageId) async {
    // Delete message document from Firestore by its ID
    await FirebaseFirestore.instance.collection('chats').doc(messageId).delete();
  }

  void _editMessage(String messageId, String oldText) {
    _messageController.text = oldText;   // Pre-fill input field with old message text

    // Show a dialog to edit the message text
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Message"),
        content: TextField(
          controller: _messageController,  // Input field in dialog
          maxLines: null,                   // Allow multiple lines
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),  // Close dialog on Cancel
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final newText = _messageController.text.trim();   // Get updated text
              if (newText.isNotEmpty) {
                // Update Firestore message document with new text
                await FirebaseFirestore.instance.collection('chats').doc(messageId).update({'text': newText});
              }
              _messageController.clear();   // Clear input field
              Navigator.pop(context);        // Close dialog
            },
            child: const Text("Update"),
          ),
        ], 
      ),
    );
  
}

Widget _buildSidebar() {
  return Container(
    width: 300,                      // Fixed width for the sidebar
    color: Colors.white,             // White background for the sidebar

    // Listen to the chats collection, ordered by timestamp descending (latest first)
    child: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .orderBy('timestamp', descending: true)
          .snapshots(),

      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());  // Show loading spinner if no data

        // Map to hold the latest message for each user (key: userId, value: message data)
        final Map<String, Map<String, dynamic>> latestMessages = {};

        // Loop through chat documents to find the latest message from each user (exclude admin)
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final userId = data['userId'];
          if (userId != 'admin' && !latestMessages.containsKey(userId)) {
            latestMessages[userId] = data;   // Store only the first (latest) message per user
          }
        }

        // Show message if no users have sent messages yet
        if (latestMessages.isEmpty) {
          return const Center(child: Text("No users have messaged yet"));
        }

        final entries = latestMessages.entries.toList();  // Convert map entries to list for iteration

        return ListView.builder(
          itemCount: entries.length,    // Number of unique users with messages
          itemBuilder: (context, index) {
            final userId = entries[index].key;           // Current userId
            final lastMsg = entries[index].value;        // Last message from this user
            final userName = userIdToName[userId] ?? userId;  // Get username or fallback to userId
            final lastText = lastMsg['text'] ?? '';      // Last message text
            final time = lastMsg['timestamp'] != null    // Format timestamp to readable time
                ? DateFormat('hh:mm a').format((lastMsg['timestamp'] as Timestamp).toDate())
                : '';

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepOrangeAccent,        // Circle avatar with background color
                child: Text(userName[0].toUpperCase(),           // Show first letter of username in uppercase
                    style: const TextStyle(color: Colors.white)),
              ),
              title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),  // Username bold
              subtitle: Text(
                lastText.length > 30 ? '${lastText.substring(0, 30)}...' : lastText,       // Truncate long messages
                overflow: TextOverflow.ellipsis,                                           // Ellipsis if overflow
              ),
              trailing: Text(time, style: const TextStyle(fontSize: 11)),   // Timestamp on right side
              selected: selectedUserId == userId,                           // Highlight if this user is selected
              selectedTileColor: Colors.deepOrange.withOpacity(0.1),       // Light orange background for selected user
              onTap: () => setState(() => selectedUserId = userId),       // Set selected user on tap to load chat
            );
          },
        );
      },
    ),
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Admin Chat Panel'),         // App bar title
      backgroundColor: Colors.deepOrangeAccent,      // App bar color
      actions: [
        IconButton(
          icon: Icon(sidebarVisible ? Icons.menu_open : Icons.menu),  // Toggle icon depends on sidebar visibility
          onPressed: () => setState(() => sidebarVisible = !sidebarVisible),  // Toggle sidebar visibility on press
        ),
      ],
    ),

    body: Row(
      children: [
        if (sidebarVisible) _buildSidebar(),         // Show sidebar if visible

        Expanded(
          child: Column(
            children: [
              Expanded(
                child: selectedUserId == null         // If no user selected
                    ? const Center(child: Text('Select a user to chat with'))  // Show placeholder text
                    : StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('chats')
                            .where('userId', isEqualTo: selectedUserId)  // Get messages for selected user
                            .orderBy('timestamp', descending: true)       // Latest messages first
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) 
                            return const Center(child: CircularProgressIndicator());  // Loading indicator

                          final messages = snapshot.data!.docs;

                          return ListView.builder(
                            reverse: true,                // Start from bottom (latest message)
                            padding: const EdgeInsets.all(12),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final msg = messages[index];
                              final data = msg.data() as Map<String, dynamic>;

                              final isAdmin = data['senderId'] == 'admin';   // Check if message sent by admin

                              final senderName = isAdmin
                                  ? adminName
                                  : userIdToName[data['senderId']] ?? data['senderEmail'] ?? 'User';

                              final timestamp = data['timestamp'] != null
                                  ? (data['timestamp'] as Timestamp).toDate()
                                  : DateTime.now();

                              final time = DateFormat('hh:mm a').format(timestamp);  // Format time

                              return GestureDetector(
                                onLongPress: isAdmin   // Admin messages can be edited/deleted on long press
                                    ? () => showModalBottomSheet(
                                          context: context,
                                          builder: (_) => Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                leading: const Icon(Icons.edit),
                                                title: const Text("Edit"),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  _editMessage(msg.id, data['text']);  // Edit message
                                                },
                                              ),
                                              ListTile(
                                                leading: const Icon(Icons.delete),
                                                title: const Text("Delete"),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  _deleteMessage(msg.id);              // Delete message
                                                },
                                              ),
                                            ],
                                          ),
                                        )
                                    : null,

                                child: Align(
                                  alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,  // Align right if admin
                                  child: Container(
                                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),  // Max width 70% of screen
                                    margin: const EdgeInsets.symmetric(vertical: 6),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isAdmin ? Colors.deepOrangeAccent : Colors.grey[300],  // Different colors for admin/user
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(12),
                                        topRight: const Radius.circular(12),
                                        bottomLeft: Radius.circular(isAdmin ? 12 : 0),    // Rounded corners depending on sender
                                        bottomRight: Radius.circular(isAdmin ? 0 : 12),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          senderName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: isAdmin ? Colors.white70 : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          data['text'] ?? '',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: isAdmin ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Text(
                                            time,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isAdmin ? Colors.white70 : Colors.black54,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),

              // Message input area only visible if a user is selected
              if (selectedUserId != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Colors.grey[100],
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          minLines: 1,
                          maxLines: 5,
                        ),
                      ),
                      const SizedBox(width: 8),

                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.deepOrangeAccent,
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: _sendMessage,  // Send message on tap
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
} 
 
 