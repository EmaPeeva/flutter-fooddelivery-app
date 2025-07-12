import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fooddelivery_app/pages/bottomnav.dart';
import 'package:fooddelivery_app/pages/detail_page.dart';
import 'package:fooddelivery_app/pages/home.dart';
import 'package:fooddelivery_app/pages/track_order_page.dart';
import 'package:fooddelivery_app/service/database.dart';
import 'package:fooddelivery_app/service/shared_pref.dart';
import 'package:fooddelivery_app/service/widget_support.dart'; 

 // Stateful widget to display and manage user orders   can change its UI when something changes 
class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState(); // Create mutable state for this widget, which will control how the UI works and updates
}

// State class for the Order widget
class _OrderState extends State<Order> {
  String? id; // To store current user ID
  Stream? orderStream; // Stream to listen for order data updates from database

  @override
  void initState() { //uns once when the widget is first created
    super.initState();
    getOnLoad(); // Call method to initialize data when widget loads
  }

  // Async method to fetch user ID and get orders stream from database
  getOnLoad() async {
    id = await SharedpreferenceHelper().getUserId(); // Get user ID from shared preferences/local storage
    orderStream = await DatabaseMethods().getUserOrders(id!); // Get stream of orders for this user from database
    setState(() {}); // Trigger UI rebuild with new data (orderStream)
  }

  // Async method to cancel an order by ID
  Future<void> cancelOrder(String orderId) async {
    await DatabaseMethods().cancelOrder(id!, orderId); // Call database method to cancel order

    // Show a snackbar notification to user confirming cancellation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Order cancelled successfully!"),
        backgroundColor: Colors.redAccent, // Red color to indicate action
        behavior: SnackBarBehavior.floating, // Snackbar floats above UI
      ),
    );
  
}

 // Widget that builds a colored badge showing the status of the order (e.g., Pending, Delivered, Cancelled)
Widget _buildStatusBadge(String status) {
  Color bgColor; // Variable to hold badge background color

  // Choose color based on status text (case-insensitive)
  switch (status.toLowerCase()) {
    case "pending":
      bgColor = Colors.orangeAccent; // Orange for pending orders
      break;
    case "delivered":
      bgColor = Colors.green; // Green for delivered orders
      break;
    case "cancelled":
      bgColor = Colors.red; // Red for cancelled orders
      break;
    default:
      bgColor = Colors.blueGrey; // Default color if status unknown
  }

  // Return a container styled as a badge with text inside
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Padding inside badge
    decoration: BoxDecoration(
      color: bgColor, // Background color based on status
      borderRadius: BorderRadius.circular(20), // Rounded corners
    ),
    child: Text(
      status.toUpperCase(), // Show status text in uppercase
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // White bold text
    ),
  );
}

// Widget to build a Card UI representing a single order from Firestore DocumentSnapshot
Widget buildOrderCard(DocumentSnapshot ds) {
  final data = ds.data() as Map<String, dynamic>; // Extract order data as map
  String status = data["Status"]; // Get order status string
  bool isDelivered = status.toLowerCase() == "delivered"; // Flag if delivered
  bool isCancelled = status.toLowerCase() == "cancelled"; // Flag if cancelled

  return Card(
    margin: const EdgeInsets.only(bottom: 16), // Margin below card
    elevation: 5, // Shadow elevation
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Rounded corners
    child: Padding(
      padding: const EdgeInsets.all(14), // Inner padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Left-align content
        children: [
          // Top row: address on left, status badge on right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between children
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xffef2b39)), // Location icon in red color
                  const SizedBox(width: 8), // Spacing between icon and text
                  Text(
                    data["Address"], // Show delivery address
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Bold text
                  ),
                ],
              ),
              _buildStatusBadge(status), // Show order status badge on right
            ],
          ),
          const SizedBox(height: 10), // Vertical spacing
          Divider(), // Horizontal line divider

          // Row showing food image and details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Align top of row children
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8), // Rounded corners for image
                child: Image.asset(
                  data["FoodImage"], // Food image asset path
                  height: 80, // Fixed height
                  width: 80, // Fixed width
                  fit: BoxFit.cover, // Crop/scale image to cover area
                ),
              ),
              const SizedBox(width: 16), // Spacing between image and text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Left align text
                  children: [
                    Text(
                      data["FoodName"], // Food name text
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Bold large text
                    ),
                    const SizedBox(height: 4), // Small spacing
                    Text("Quantity: ${data["Quantity"]}"), // Quantity text
                    Text("Total: \$${data["Total"]}"), // Total price text
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14), // Spacing before buttons

          // Row for action buttons: Edit, Cancel, Track
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // Align buttons to the right
            children: [
              // Show Edit and Cancel buttons only if order not delivered or cancelled
              if (!isDelivered && !isCancelled) ...[
                _actionButton(
                  icon: Icons.edit, // Edit icon
                  label: "Edit",
                  color: Colors.blue, // Blue button color
                  onTap: () async {
                    // Navigate to detail page to edit order
                    bool? updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(
                          image: data["FoodImage"],
                          name: data["FoodName"],
                          price: data["Total"], // Pass total price as string
                          description: data["Description"] ?? "No description available",
                          star: double.tryParse(data["Star"]?.toString() ?? "") ?? 4.0,
                          existingOrderId: ds.id, // Pass document ID for updating order
                          initialQuantity: int.parse(data["Quantity"]), // Initial quantity
                          initialAddress: data["Address"], // Initial address
                        ),
                      ),
                    );
                    if (updated == true) getOnLoad(); // Refresh orders after update
                  },
                ),
                const SizedBox(width: 8), // Spacing between buttons
                _actionButton(
                  icon: Icons.cancel, // Cancel icon
                  label: "Cancel",
                  color: Colors.redAccent, // Red color button
                  onTap: () {
                    // Show confirmation dialog before cancelling
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Cancel Order"),
                        content: const Text("Are you sure you want to cancel this order?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context), // Close dialog
                            child: const Text("No"),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            icon: const Icon(Icons.cancel),
                            label: const Text("Yes, Cancel"),
                            onPressed: () async {
                              Navigator.pop(context); // Close dialog
                              await cancelOrder(ds.id); // Call cancel order method
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
              // Show Track button if order is not cancelled
              if (!isCancelled)
                Padding(
                  padding: const EdgeInsets.only(left: 8), // Space to the left
                  child: _actionButton(
                    icon: Icons.local_shipping, // Truck icon for tracking
                    label: "Track",
                    color: const Color(0xffef2b39), // Same red accent color
                    onTap: () {
                      // Navigate to tracking page passing orderId
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrackOrderPage(orderId: ds.id),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

 

  // Helper widget to create an action button with an icon and label
Widget _actionButton({
  required IconData icon,      // Icon to display on the button
  required String label,       // Text label of the button
  required Color color,        // Color for icon and text
  required VoidCallback onTap, // Function to call when button is pressed
}) {
  return TextButton.icon(
    onPressed: onTap,          // Call onTap when pressed
    icon: Icon(icon, color: color, size: 20), // Display icon with specified color and size
    label: Text(
      label,
      style: TextStyle(color: color, fontWeight: FontWeight.bold), // Label styled with color and bold font
    ),
  );
}

// Widget that builds a list of all orders using a StreamBuilder
Widget allOrders() {
  return StreamBuilder(
    stream: orderStream, // Stream providing live updates of orders
    builder: (context, AsyncSnapshot snapshot) {
      if (!snapshot.hasData) {
        // While waiting for data, show a loading spinner in the center
        return const Center(child: CircularProgressIndicator());
      }

      // Once data is available, build a scrollable list of orders
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Padding around the list
        itemCount: snapshot.data.docs.length, // Number of order documents received
        itemBuilder: (context, index) {
          DocumentSnapshot ds = snapshot.data.docs[index]; // Get each order document snapshot
          return buildOrderCard(ds); // Build the UI card for each order
        },
      );
    },
  );
}

// Main build method of the Order screen
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xfff7f7f7), // Light grey background

    // AppBar with back button and title + subtitle
    appBar: AppBar(
      backgroundColor: Colors.white, // White app bar background
      elevation: 0,                   // No shadow
      centerTitle: true,              // Center the title widget

      // Leading widget: Back arrow button
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xffef2b39)), // Red back arrow
        onPressed: () {
          // On back press, navigate to BottomNav page, clearing navigation stack
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const BottomNav()), // Your home page widget
            (route) => false, // Remove all previous routes
          );
        },
      ),

      // Title widget: Column with icon+title row and subtitle text
      title: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min, // Wrap content width only
            children: const [
              Icon(Icons.receipt_long, color: Color(0xffef2b39)), // Receipt icon in red
              SizedBox(width: 8), // Spacing between icon and text
              Text(
                "Your Orders",
                style: TextStyle(
                  color: Color(0xffef2b39),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 4), // Small vertical space
          Text(
            "Track, edit or cancel your orders anytime", // Subtitle below title
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    ),

    // Body shows the list of all orders
    body: allOrders(),
    );
  } 
}
