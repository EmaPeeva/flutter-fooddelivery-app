import 'package:flutter/material.dart';
import 'package:fooddelivery_app/Admin/all_order.dart';
import 'package:fooddelivery_app/Admin/chat_page.dart';
import 'package:fooddelivery_app/Admin/manage_users.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For sign out
import 'package:fooddelivery_app/pages/login.dart'; // Update this path if needed


class HomeAdmin extends StatefulWidget { 
  const HomeAdmin({super.key});  // Constructor

  @override
  State<HomeAdmin> createState() => _HomeAdminState();  // Create state object
}

class _HomeAdminState extends State<HomeAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),  // Title of the app bar
        backgroundColor: Colors.deepOrange,    // Orange color for app bar
        automaticallyImplyLeading: false,      // Removes default back arrow button
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),    // Logout icon button
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();  // Sign out user from Firebase
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LogIn()),  // Navigate to login screen
                (route) => false,  // Remove all previous routes to prevent back navigation
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),  // Add padding around the content
        child: GridView.count(
          crossAxisCount: 2,            // Two items per row
          crossAxisSpacing: 16,         // Space between columns
          mainAxisSpacing: 16,          // Space between rows
          children: [
            // Manage Orders card/button
            _buildAdminCard(
              title: "Manage Orders",    // Text on the card
              icon: Icons.list_alt,      // Icon for this card
              color: Colors.blueAccent,  // Background color
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminOrdersPage()),  // Navigate to orders page
                );
              },
            ),
            // Manage Users card/button
            _buildAdminCard(
              title: "Manage Users",
              icon: Icons.people,
              color: Colors.purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageUsers()),  // Navigate to users management page
                );
              },
            ),
            // Admin Chat card/button
            _buildAdminCard(
              title: "Admin Chat",
              icon: Icons.chat,
              color: Colors.teal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminChatPage()),  // Navigate to chat page
                );
              },
            ),
          ],
        ),
      ),
    );
  
}


  Widget _buildAdminCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
        color: color,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildAdminCard({
  required String title,        // Text to show on the card
  required IconData icon,       // Icon to display
  required Color color,         // Background color of the card
  required VoidCallback onTap,  // Function to call when tapped
}) {
  return GestureDetector(
    onTap: onTap,               // Detects tap and calls the provided function
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Rounded corners
      elevation: 6,             // Shadow depth under the card
      color: color,             // Card background color
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Shrinks column to fit content
          children: [
            Icon(icon, size: 40, color: Colors.white), // Large white icon
            const SizedBox(height: 10),                // Space between icon and text
            Text(
              title,                                   // Title text
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,                   // White text color
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

 