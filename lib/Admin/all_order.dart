import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fooddelivery_app/service/database.dart';
import 'package:fooddelivery_app/service/widget_support.dart';

 class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  Stream? orderStream;                     // Stream to listen for orders data from database
  TextEditingController searchController = TextEditingController();  // Controller for search input (if used)
  String searchText = '';                  // Stores current search query text

  @override
  void initState() {
    super.initState();
    getOnLoad();                         // Load data when widget is created
  }

  getOnLoad() async {
    orderStream = await DatabaseMethods().getAllOrders();  // Get all orders as a stream from database
    setState(() {});                                    // Refresh UI when data is loaded
  }

  // Widget to build a card UI for each order document
  Widget buildOrderCard(DocumentSnapshot ds) {
    final data = ds.data() as Map<String, dynamic>;    // Extract order data as a map
    String currentStatus = data["Status"].toString();  // Current status of the order
    bool isDelivered = currentStatus.toLowerCase() == "delivered";  // Check if order is delivered

    // Possible order status options to choose from
    List<String> statusOptions = [
      "Pending",
      "Preparing",
      "Out for delivery",
      "Delivered",
      "Cancelled"
    ];

    String? userId = data["Id"];   // Get user ID who placed the order

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),   // Space below each card
      child: Container(
        width: 350,                         // Fixed width for the card
        padding: const EdgeInsets.all(8.0), // Padding inside the card
        decoration: BoxDecoration(
          color: isDelivered ? Colors.grey[200] : Colors.white,  // Grey background if delivered, else white
          borderRadius: BorderRadius.circular(15.0),             // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black12,        // Shadow color
              blurRadius: 4,                // Shadow blur amount
              offset: Offset(0, 2),         // Shadow offset downwards
            ),
          ],
        ),
        child: Column(
          children: [
            // Row for address with icon and text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,    // Center the row content
              children: [
                Icon(Icons.location_on_outlined, color: Color(0xffef2b39)),  // Location pin icon in red
                SizedBox(width: 10.0),                               // Space between icon and text
                Expanded(
                  child: Text(
                    data["Address"],                                 // Display order address
                    style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                    maxLines: 1,                                     // Limit to 1 line
                    overflow: TextOverflow.ellipsis,                // Add ... if text is too long
                  ),
                ),
              ],
            ),
            Divider(),    // Horizontal line separating sections

            // Row for food image and details
            Row(
              children: [
                Image.asset(
                  data["FoodImage"],             // Load food image from assets
                  height: 80,                    // Fixed height for image
                  width: 80,                     // Fixed width for image
                  fit: BoxFit.contain,           // Scale image inside box preserving aspect ratio
                ),
                SizedBox(width: 30.0),            // Space between image and details column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,  // Align text to start (left)
                    children: [
                      Text(
                        data["FoodName"],           // Food name title
                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5.0),        // Small vertical space
                      Row(
                        children: [
                          Icon(Icons.format_list_numbered, color: Color(0xffef2b39), size: 18),  // Quantity icon
                          SizedBox(width: 5.0),
                          Text(data["Quantity"], style: TextStyle(fontSize: 14.0)),             // Quantity text
                          SizedBox(width: 15.0),
                          Icon(Icons.monetization_on, color: Color(0xffef2b39), size: 18),     // Price icon
                          SizedBox(width: 5.0),
                          Text("\$${data["Total"]}", style: TextStyle(fontSize: 14.0)),        // Total price text
                        ],
                      ),
                      SizedBox(height: 6.0),       // Space before status row

                      // Row for showing and changing order status
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.grey[600], size: 16),   // Info icon
                          SizedBox(width: 5),
                          Text(
                            "Status:",
                            style: TextStyle(
                              fontSize: 13.0,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 10),
                          DropdownButton<String>(
                            value: currentStatus,      // Currently selected status
                            items: statusOptions
                                .map((status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status),   // Dropdown menu items with status names
                                    ))
                                .toList(),
                            onChanged: (String? newStatus) async {
                              if (newStatus != null && newStatus != currentStatus) {
                                try {
                                  // Update status in the "Orders" collection in Firestore
                                  await FirebaseFirestore.instance
                                      .collection("Orders")
                                      .doc(ds.id)
                                      .update({"Status": newStatus});

                                  // Also update status inside user's personal order collection
                                  await FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(userId)
                                      .collection("Orders")
                                      .doc(ds.id)
                                      .update({"Status": newStatus});

                                  // Show success message to admin
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Order status updated to $newStatus"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  // Show error message if update fails
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Failed to update status."),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  
}

Widget allOrders() {
  return StreamBuilder(
    stream: orderStream,                     // Listen to the stream of orders from the database
    builder: (context, AsyncSnapshot snapshot) {
      if (!snapshot.hasData) {
        // Show a loading spinner while data is loading
        return Center(child: CircularProgressIndicator());
      }

      List<DocumentSnapshot> allOrders = snapshot.data.docs; // Get all order documents
      Map<String, List<DocumentSnapshot>> userOrders = {};   // Map userId to their list of orders

      // Group orders by userId
      for (var doc in allOrders) {
        final data = doc.data() as Map<String, dynamic>;
        String userId = data["Id"] ?? "unknown_user";        // Get userId from order data
        if (!userOrders.containsKey(userId)) {
          userOrders[userId] = [];                            // Create list if not exists
        }
        userOrders[userId]!.add(doc);                         // Add order to the user's list
      }

      // Build a scrollable list of user orders
      return ListView(
        padding: const EdgeInsets.all(16),
        children: userOrders.entries.map((entry) {
          String userId = entry.key;
          List<DocumentSnapshot> orders = entry.value;

          // For each user, get their profile data asynchronously
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) return SizedBox();   // Show nothing if user data not loaded
              final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
              if (userData == null) return SizedBox();         // Handle null user data

              String userName = userData["name"] ?? "Unknown"; // Get user name or default
              String userEmail = userData["email"] ?? "unknown@email.com"; // Get user email or default

              // 🔍 Search filter: show only if searchText matches name or email (case insensitive)
              if (searchText.isNotEmpty &&
                  !userName.toLowerCase().contains(searchText) &&
                  !userEmail.toLowerCase().contains(searchText)) {
                return SizedBox();   // Hide this user’s orders if search doesn't match
              }

              // Display user info and their orders
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User header with icon, name and email
                    Row(
                      children: [
                        Icon(Icons.person, color: Color(0xffef2b39)),
                        SizedBox(width: 8),
                        Text(
                          "$userName  |  $userEmail",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    // Display all orders for this user using your buildOrderCard widget
                    ...orders.map((doc) => buildOrderCard(doc)).toList(),
                  ],
                ),
              );
            },
          );
        }).toList(),
      );
    },
  );
}


 
 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color(0xfff7f7f7),  // Light gray background for the whole page
    appBar: AppBar(title: Text("Admin Orders")),  // Top app bar with the title

    body: Container(
      margin: const EdgeInsets.only(top: 10.0),  // Space at the top below the app bar
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,  // Center the "Orders" text horizontally
            children: [Text("Orders", style: AppWidget.headerStyle())],  // Page header text with custom style
          ),
          SizedBox(height: 10),  // Space between header and search bar

          // Search input field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),  // Horizontal padding around search field
            child: TextField(
              controller: searchController,  // Connect input field with controller
              decoration: InputDecoration(
                hintText: "Search by user name or email",  // Placeholder text inside input
                prefixIcon: Icon(Icons.search),             // Search icon before text
                suffixIcon: searchText.isNotEmpty           // Show clear button only if there is text typed
                    ? IconButton(
                        icon: Icon(Icons.clear),          // Clear icon
                        onPressed: () {
                          searchController.clear();       // Clear the input field
                          setState(() {
                            searchText = '';              // Reset the search text filter
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(                 // Rounded border for input field
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  searchText = val.toLowerCase();           // Update search text filter on every input change (lowercase for case-insensitive search)
                });
              },
            ),
          ),

          SizedBox(height: 10),  // Space between search bar and list of orders

          // Expanded widget makes the orders list fill remaining space
          Expanded(child: allOrders()),  
        ],
      ),
    ),
  );
 }
}
 


 