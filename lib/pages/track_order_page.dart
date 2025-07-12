import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';  // <-- add this

 // Stateful widget to track a specific order by its orderId,can change its UI when something changes 
class TrackOrderPage extends StatefulWidget {
  final String orderId; // The ID of the order to track

  // Constructor requires orderId and allows optional key
  const TrackOrderPage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<TrackOrderPage> createState() => _TrackOrderPageState();
}

class _TrackOrderPageState extends State<TrackOrderPage> { 
  DocumentSnapshot? orderSnapshot; // Holds the Firestore document snapshot of the order
  bool loading = true;             // Indicates if data is still loading
  LatLng? driverLocation;          // Driver's current location on the map (nullable)
  late GoogleMapController _mapController; // Controller for Google Maps widget

  @override
  void initState() {//runs once when the widget is first created
    super.initState();
    fetchOrder(); // Fetch the order data as soon as the widget is initialized
  }

  // Method to fetch order data and subscribe to realtime updates
  fetchOrder() async {
    final userId = FirebaseAuth.instance.currentUser?.uid; // Get current logged-in user ID
    if (userId == null) return; // If no user logged in, stop execution

    // Listen to realtime updates on the user's specific order document
    FirebaseFirestore.instance
        .collection('users')             // Access 'users' collection
        .doc(userId)                     // Document for current user
        .collection('Orders')            // User's 'Orders' subcollection
        .doc(widget.orderId)             // Specific order document by ID
        .snapshots()                    // Listen for realtime changes (Stream)
        .listen((doc) {
      if (doc.exists) {                // If the order document exists
        setState(() {                  // Update state variables inside setState
          orderSnapshot = doc;         // Save the snapshot for UI use
          loading = false;             // Mark loading as complete

          final data = doc.data()!;   // Extract data map from document snapshot
          
          // Check if driver's location fields exist in data
          if (data.containsKey('driverLat') && data.containsKey('driverLng')) {
            driverLocation = LatLng(
              data['driverLat'],       // Latitude value
              data['driverLng'],       // Longitude value
            );
          }
        });
      } else {
        // If order not found in user's orders, fallback to check global 'Orders' collection
        FirebaseFirestore.instance
            .collection('Orders')      // Access global 'Orders' collection
            .doc(widget.orderId)       // The same order document ID
            .get()                     // Fetch document once (no stream here)
            .then((globalDoc) {
          if (globalDoc.exists) {
            setState(() {
              orderSnapshot = globalDoc;  // Save global order data snapshot
              loading = false;            // Loading complete

              final data = globalDoc.data()!;

              // Again check for driver's location in global order data
              if (data.containsKey('driverLat') && data.containsKey('driverLng')) {
                driverLocation = LatLng(
                  data['driverLat'],
                  data['driverLng'],
                );
              }
            });
          } else {
            // If order not found anywhere, set loading false and snapshot null
            setState(() {
              loading = false;
              orderSnapshot = null;
            });
          }
        });
      }
    });
  }

  // Function to show a confirmation popup dialog with a success message
void showConfirmationPopup(BuildContext context, String message) {
  showDialog(
    context: context, // Context to show the dialog in
    builder: (_) => AlertDialog(
      // Rounded corners for the dialog box
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      
      // Title row with green check icon and "Success" text
      title: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 26),
          SizedBox(width: 10),
          Text("Success", style: TextStyle(color: Colors.green)),
        ],
      ),
      
      // The main message content of the dialog
      content: Text(message),
      
      // Action buttons below the message
      actions: [
        TextButton(
          // Close the dialog when tapped
          onPressed: () => Navigator.pop(context),
          child: Text("OK"),
        ),
      ],
    ),
  );
}

// Widget to build a vertical progress indicator showing order status steps
Widget buildStatusProgress(String status) {
  // List of possible steps in the order process
  final steps = ["Pending", "Preparing", "Out for delivery", "Delivered"];
  
  // Find the index of the current status in steps, ignoring case
  int currentStep = steps.indexWhere((step) => step.toLowerCase() == status.toLowerCase());
  
  // If status not found, default to the first step (Pending)
  if (currentStep == -1) currentStep = 0;

  return Column(
    children: List.generate(steps.length, (index) {
      // Is this step active or completed?
      bool isActive = index <= currentStep;

      return Column(
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 300), // Smooth color/shape animation
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? Color(0xffef2b39) : Colors.grey[300], // Highlight active steps
                ),
                child: Icon(
                  isActive ? Icons.check : Icons.circle, // Check mark for completed, circle otherwise
                  color: Colors.white,
                  size: 16,
                ),
              ),
              SizedBox(width: 12),
              Text(
                steps[index], // Step label text
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500, // Bold for active steps
                  color: isActive ? Color(0xffef2b39) : Colors.grey, // Color for active steps
                ),
              ),
            ],
          ),
          // Vertical connecting line between steps, except after last step
          if (index < steps.length - 1)
            Container(
              margin: EdgeInsets.only(left: 11, top: 4, bottom: 4),
              height: 30,
              width: 2,
              color: isActive ? Color(0xffef2b39) : Colors.grey[300], // Same highlight as step color
            ),
        ],
      );
    }),
  );
}

 // Widget that displays the user's order history section
Widget buildHistorySection() {
  // Get the currently logged-in user's ID from FirebaseAuth
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  // Use StreamBuilder to listen to real-time updates from Firestore orders collection
  return StreamBuilder<QuerySnapshot>(
    // Firestore query:
    // - Go to the user's "Orders" subcollection
    // - Filter orders where Status is either "Delivered" or "Cancelled"
    // - Order the results by Timestamp descending (latest first)
    stream: FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("Orders")
        .where("Status", whereIn: ["Delivered", "Cancelled"])
        .orderBy("Timestamp", descending: true)
        .snapshots(),

    builder: (context, snapshot) {
      // While waiting for data, show a loading spinner
      if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

      // Get the list of order documents from snapshot
      final orders = snapshot.data!.docs;

      // If no orders exist, show a friendly message
      if (orders.isEmpty) return Center(child: Text("No order history yet."));

      // Build a scrollable list of past orders with separators
      return ListView.separated(
        shrinkWrap: true, // Allow ListView inside another scroll view without infinite height
        physics: NeverScrollableScrollPhysics(), // Disable scrolling to let outer scroll view handle it
        itemCount: orders.length, // Number of past orders to show
        separatorBuilder: (_, __) => Divider(), // Divider between list items

        itemBuilder: (context, index) {
          // Get order data as a map
          final d = orders[index].data() as Map<String, dynamic>;

          // Extract the order timestamp and convert Firestore Timestamp to DateTime
          final date = (d['Timestamp'] as Timestamp?)?.toDate();

          return ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Rounded corners for tiles
            ),

            // Leading widget shows the food image in a rounded rectangle
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                d['FoodImage'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),

            // Main title shows the food name in bold
            title: Text(d['FoodName'] ?? "", style: TextStyle(fontWeight: FontWeight.bold)),

            // Subtitle contains status and formatted order date
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Status: ${d['Status']}",
                  style: TextStyle(
                    // Green if delivered, red if cancelled
                    color: d['Status'] == "Delivered" ? Colors.green : Colors.red,
                  ),
                ),
                if (date != null) // Show date if available
                  Text(
                    // Format date to something like "Jun 30, 2025 5:30 PM"
                    DateFormat.yMMMd().add_jm().format(date),
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),

            // Trailing widget shows the total price in bold red color
            trailing: Text(
              "\$${d['Total']}",
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xffef2b39)),
            ),
          );
        },
      );
    },
  );
}

@override
Widget build(BuildContext context) {
  // Show a loading screen while data is being fetched
  if (loading) {
    return Scaffold(
      appBar: AppBar(title: Text("Track Order")),
      body: Center(child: CircularProgressIndicator()),
    );
  }

  // Show a message if the order was not found
  if (orderSnapshot == null) {
    return Scaffold(
      appBar: AppBar(title: Text("Track Order")),
      body: Center(child: Text("Order not found.")),
    );
  }

  // Extract order data from the snapshot
  final data = orderSnapshot!.data() as Map<String, dynamic>;

  // Get the order status or fallback to "Unknown"
  final status = data["Status"] ?? "Unknown";

  // Convert Firestore Timestamp to DateTime (nullable)
  final date = (data['Timestamp'] as Timestamp?)?.toDate();

  // Main scaffold of the page
  return Scaffold(
    backgroundColor: Color(0xfff7f7f7),
    appBar: AppBar(
      backgroundColor: Color(0xffef2b39),
      title: Text("Track Order", style: TextStyle(color: Colors.white)),
      iconTheme: IconThemeData(color: Colors.white),
      centerTitle: true,
    ),
    body: SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Status card container
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title "Order Status"
                Text("Order Status:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),

                // Status row with icon and status text
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xffef2b39)),
                    SizedBox(width: 8),
                    Text(status, style: TextStyle(fontSize: 18, color: Color(0xffef2b39))),
                  ],
                ),

                // Display formatted date if available
                if (date != null) ...[
                  SizedBox(height: 4),
                  Text(
                    DateFormat.yMMMd().add_jm().format(date),
                    style: TextStyle(color: Colors.grey),
                  ),
                ],

                SizedBox(height: 16),

                // Visual progress indicator for order status steps
                buildStatusProgress(status),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Show driver's current location on map if available
          if (driverLocation != null) ...[
            Text("Driver Location:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: driverLocation!,
                    zoom: 15,
                  ),
                  markers: {
                    Marker(markerId: MarkerId('driver'), position: driverLocation!),
                  },
                  onMapCreated: (controller) => _mapController = controller,
                ),
              ),
            ),

            SizedBox(height: 30),
          ],

          // Divider line before order history
          Divider(thickness: 1.2),

          // Title for Order History section
          Text("Order History", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),

          // Display past orders list
          buildHistorySection(),

          SizedBox(height: 30),

          // Confirmation button centered at the bottom
          Center(
            child: ElevatedButton.icon(
              onPressed: () => showConfirmationPopup(context, "You're successfully tracking your order! 🚚"),
              icon: Icon(Icons.done),
              label: Text("Confirm Tracking"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffef2b39),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    ),
   );
  } 
}
  
 

  