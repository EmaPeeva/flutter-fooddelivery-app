import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

 class ManageUsers extends StatefulWidget {
  const ManageUsers({super.key});

  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;   // Firestore instance to access database

  // Method to remove an order document from the admin's Orders collection only
  Future<void> removeUserOrder(String orderId) async {
    try {
      await _firestore.collection('Orders').doc(orderId).delete();  // Delete order doc by ID

      // Show confirmation message after successful removal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order removed from admin view only'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show error message if deletion fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove order: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Show confirmation dialog before deleting an order
  Future<void> confirmDelete(String orderId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Remove Order"),                 // Dialog title
        content: const Text("Are you sure you want to remove this order?"),  // Dialog message
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),   // Cancel button returns false
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),    // Remove button returns true
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Remove")),
        ],
      ),
    );

    // If user confirms deletion, call removeUserOrder to delete
    if (shouldDelete == true) {
      removeUserOrder(orderId);
    }
  }

  // Widget to show a colored status chip based on order status string
  Widget _statusChip(String status) {
    Color color = Colors.grey;      // Default grey color

    if (status == 'pending') color = Colors.orange;
    if (status == 'confirmed') color = Colors.blue;
    if (status == 'on the way') color = Colors.purple;
    if (status == 'delivered') color = Colors.green;

    return Chip(
      label: Text(
        status.toUpperCase(),        // Show status text in uppercase
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: color,       // Background color changes based on status
    );
  }


  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF6F6F6),  // Light grey background for the page
    appBar: AppBar(
      title: const Text("Manage Users"),       // App bar title
      elevation: 4,                            // Shadow under app bar
      backgroundColor: Colors.deepOrangeAccent,  // Orange color for app bar
    ),
    body: StreamBuilder<QuerySnapshot>(
      // Listen to Orders collection, only orders with Status "Delivered" or "Cancelled"
      stream: _firestore
          .collection('Orders')
          .where('Status', whereIn: ["Delivered", "Cancelled"])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // Show error message if any error in fetching data
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading spinner while waiting for data
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!.docs;  // List of orders from the snapshot

        if (orders.isEmpty) {
          // Show message if no delivered or cancelled orders found
          return const Center(
            child: Text(
              'No delivered orders found.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        // Build scrollable list of order cards
        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: orders.length,          // Number of orders
          itemBuilder: (context, index) {
            var order = orders[index];       // Current order document
            var data = order.data() as Map<String, dynamic>;

            String userId = data["Id"] ?? '';  // Get userId from order

            // Fetch user data with FutureBuilder for each user related to an order
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  // Show placeholder card while loading user info
                  return Card(
                    child: ListTile(
                      title: Text('Loading user info...'),
                    ),
                  );
                }

                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  // Show message if user data not found
                  return Card(
                    child: ListTile(
                      title: Text('User info not available'),
                    ),
                  );
                }

                // Extract user info from snapshot
                final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                String userName = userData['name'] ?? 'No Name';
                String userEmail = userData['email'] ?? 'No Email';

                String status = data['Status'] ?? 'unknown';  // Order status

                // Display order info in a Card with user details and status
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.deepOrange.shade100,
                      child: const Icon(Icons.person, color: Colors.deepOrange),
                    ),
                    title: Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Show user email with icon
                          Row(
                            children: [
                              const Icon(Icons.email, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(userEmail),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Show colored status chip using your _statusChip widget
                          _statusChip(status),
                        ],
                      ),
                    ),
                    // Delete button on the right to confirm and remove the order
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      onPressed: () {
                        confirmDelete(order.id);    // Calls confirmDelete method
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    ),
  );
}
} 
