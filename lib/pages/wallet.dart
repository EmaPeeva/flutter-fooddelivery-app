import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fooddelivery_app/pages/bottomnav.dart';
import 'package:fooddelivery_app/pages/home.dart';
import 'package:intl/intl.dart';

 class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState(); // Create mutable state for this page
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController(); // Controller for message input field
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance to get current user

  // Function to send message
  void _sendMessage() async {
    final user = _auth.currentUser; // Get currently logged in user
    if (user == null || _controller.text.trim().isEmpty) return; // If no user or message empty, do nothing

    // Get user document from Firestore to retrieve name
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    // Use name from Firestore, or fallback to displayName or email or 'User'
    final senderName = userDoc.data()?['name'] ?? user.displayName ?? user.email ?? 'User';

    // Add new chat message to 'chats' collection in Firestore
    await FirebaseFirestore.instance.collection('chats').add({
      'text': _controller.text.trim(), // The message text, trimmed
      'timestamp': FieldValue.serverTimestamp(), // Current server time
      'senderId': user.uid, // User ID of sender
      'senderEmail': user.email ?? 'Anonymous', // Sender email or default
      'senderName': senderName, // Sender's name
      'userId': user.uid, // User ID (redundant with senderId, but saved)
      'receiverId': 'admin', // Receiver is hardcoded as 'admin'
    });

    _controller.clear(); // Clear the input field after sending
  }

  // Function to delete a message by document ID
  void _deleteMessage(String docId) async {
    await FirebaseFirestore.instance.collection('chats').doc(docId).delete(); // Delete message doc
  }

  // Function to edit a message by document ID and current text
  void _editMessage(String docId, String currentText) async {
    final TextEditingController editController = TextEditingController(text: currentText); // Controller pre-filled with current message

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'), // Dialog title
        content: TextField(
          controller: editController, // Input field for editing
          decoration: const InputDecoration(hintText: 'Edit your message'), // Hint text
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel editing closes dialog
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedText = editController.text.trim(); // Get edited text
              if (updatedText.isNotEmpty) {
                // Update Firestore document with new text if not empty
                await FirebaseFirestore.instance
                    .collection('chats')
                    .doc(docId)
                    .update({'text': updatedText});
              }
              Navigator.pop(context); // Close dialog after saving
            },
            child: const Text('Save'), // Save button label
          ),
        ],
      ),
    );
  
}

    @override
Widget build(BuildContext context) {
  final currentUser = _auth.currentUser; // Get the currently logged in user

  return Scaffold(
    backgroundColor: const Color(0xfff8f8f8), // Set background color for the whole page

    appBar: AppBar(
      backgroundColor: Colors.redAccent, // App bar color
      elevation: 0, // No shadow
      leading: IconButton(
        icon: const Icon(Icons.arrow_back), // Back arrow icon
        onPressed: () {
          // Navigate back to BottomNav page, replacing current page in stack
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomNav()),
          );
        },
      ),
      title: Row(
        children: const [
          CircleAvatar(
            backgroundImage: AssetImage('images/deliverer.png'), // Deliverer avatar image
            radius: 18, // Size of avatar
          ),
          SizedBox(width: 10), // Spacing between avatar and text
          Text("Deliverer"), // Title text
        ],
      ),
    ),

    body: Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            // Listen to 'chats' collection where userId matches current user
            stream: FirebaseFirestore.instance
                .collection('chats')
                .where('userId', isEqualTo: currentUser?.uid)
                .orderBy('timestamp', descending: true) // Latest messages first
                .snapshots(),

            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator()); // Show loading spinner if no data yet
              }

              final docs = snapshot.data!.docs; // Get the list of message docs

              if (docs.isEmpty) {
                return const Center(child: Text("No messages yet")); // Show text if no messages
              }

              return ListView.builder(
                padding: const EdgeInsets.all(10), // Padding around list
                reverse: true, // Show newest messages at the bottom
                itemCount: docs.length, // Number of messages
                itemBuilder: (context, index) {
                  final doc = docs[index]; // Current message document
                  final data = doc.data() as Map<String, dynamic>; // Message data map

                  final senderId = data['senderId'] ?? ''; // ID of sender
                  final isMe = senderId == currentUser?.uid; // Check if current user sent this
                  final isAdmin = senderId == 'admin'; // Check if sender is admin

                  // Convert Firestore Timestamp to DateTime or use current time if missing
                  final timestamp = (data['timestamp'] is Timestamp)
                      ? (data['timestamp'] as Timestamp).toDate()
                      : DateTime.now();

                  final timeString = DateFormat('hh:mm a').format(timestamp); // Format time string like "03:15 PM"

                  // Determine sender's display name (Deliverer if admin, else from data)
                  final senderName = isAdmin
                      ? 'Deliverer'
                      : data['senderName'] ?? data['senderEmail'] ?? 'User';

                  return GestureDetector(
                    // On long press, if this message is sent by current user, show edit/delete options
                    onLongPress: isMe
                        ? () => showModalBottomSheet(
                              context: context,
                              builder: (_) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.edit), // Edit icon
                                    title: const Text('Edit'), // Edit label
                                    onTap: () {
                                      Navigator.pop(context); // Close bottom sheet
                                      _editMessage(doc.id, data['text']); // Open edit message dialog
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.delete), // Delete icon
                                    title: const Text('Delete'), // Delete label
                                    onTap: () {
                                      Navigator.pop(context); // Close bottom sheet
                                      _deleteMessage(doc.id); // Delete message from Firestore
                                    },
                                  ),
                                ],
                              ),
                            )
                        : null, // If not sender, no action on long press
                                    child: Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.redAccent : Colors.grey[300],
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: isMe
                                  ? const Radius.circular(12)
                                  : Radius.zero,
                              bottomRight: isMe
                                  ? Radius.zero
                                  : const Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isMe)
                                Text(
                                  senderName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                              Text(
                                data['text'] ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      isMe ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  timeString,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isMe
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                              )
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
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