import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  /// Add or update user profile data in "users" collection with given uid
  Future addUserDetails(Map<String, dynamic> userInfoMap, String uid) async {
    return await FirebaseFirestore.instance
        .collection("users")               // Access "users" collection
        .doc(uid)                         // Select document with id = uid
        .set(userInfoMap, SetOptions(merge: true)); // Set data, merge if exists
  }

  /// Save user's order inside their own "Orders" subcollection
  Future addUserOrderDetails(
      Map<String, dynamic> userOrderMap, String userId, String orderId) async {
    return await FirebaseFirestore.instance
        .collection("users")               // Access "users" collection
        .doc(userId)                      // Select user document
        .collection("Orders")             // Access user's "Orders" subcollection
        .doc(orderId)                    // Select order document by orderId
        .set(userOrderMap);              // Save the order data
  }

  /// Save order in the main "Orders" collection for admin view
  Future addAdminOrderDetails(
      Map<String, dynamic> userOrderMap, String orderId) async {
    return await FirebaseFirestore.instance
        .collection("Orders")             // Access main "Orders" collection
        .doc(orderId)                    // Select order document by orderId
        .set(userOrderMap);              // Save the order data
  }

  /// Get a stream of active user orders (status NOT "Cancelled")
  Future<Stream<QuerySnapshot>> getUserOrders(String userId) async {
    return FirebaseFirestore.instance
        .collection("users")              // Access "users" collection
        .doc(userId)                     // Select user document
        .collection("Orders")            // Access user's "Orders" subcollection
        .where("Status", isNotEqualTo: "Cancelled") // Filter out cancelled orders
        .snapshots();                   // Return real-time stream of orders
  }

  /// Get a stream of user's order history with "Delivered" or "Cancelled" status
  Future<Stream<QuerySnapshot>> getUserOrderHistory(String userId) async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("Orders")
        .where("Status", whereIn: ["Delivered", "Cancelled"]) // Filter by status
        .snapshots();
  }

  /// Get all orders from the global admin "Orders" collection as a stream
  Stream<QuerySnapshot> getAllOrders() {
    return FirebaseFirestore.instance
        .collection("Orders")
        .snapshots();
  }

  /// Get delivered or cancelled orders from admin collection as a stream
  Future<Stream<QuerySnapshot>> getDeliveredOrCancelledOrdersForAdmin() async {
    return FirebaseFirestore.instance
        .collection("Orders")
        .where("Status", whereIn: ["Delivered", "Cancelled"]) // Filter orders
        .snapshots();
  }

  /// Update an order's details in both user and admin collections
  Future<void> updateUserOrderDetails(
      String userId, String orderId, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('Orders')
        .doc(orderId)
        .update(data);                  // Update user order data

    await FirebaseFirestore.instance
        .collection('Orders')
        .doc(orderId)
        .update(data);                 // Update admin order data
  }

  /// Cancel an order by setting its status to "Cancelled" in both places
  Future<void> cancelOrder(String userId, String orderId) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("Orders")
        .doc(orderId)
        .update({"Status": "Cancelled"}); // Update user order status

    await FirebaseFirestore.instance
        .collection("Orders")
        .doc(orderId)
        .update({"Status": "Cancelled"}); // Update admin order status
  }

  /// Delete an order completely from both user and admin collections
  Future<void> deleteOrderCompletely(String userId, String orderId) async {
    final userOrderRef = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("Orders")
        .doc(orderId);                  // Reference to user's order document

    final adminOrderRef =
        FirebaseFirestore.instance.collection("Orders").doc(orderId); // Admin order reference

    WriteBatch batch = FirebaseFirestore.instance.batch();  // Create batch operation
    batch.delete(userOrderRef);                             // Queue user order deletion
    batch.delete(adminOrderRef);                            // Queue admin order deletion

    await batch.commit();                                   // Execute batch deletions atomically
  }

  /// Update user's address in all their orders (user + admin collections)
  Future<void> updateUserAddressInOrders(
      String userId, String newAddress) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    WriteBatch batch = firestore.batch();                 // Batch operation for multiple updates

    // Get all orders under user document
    QuerySnapshot userOrders = await firestore
        .collection('users')
        .doc(userId)
        .collection('Orders')
        .get();

    for (var doc in userOrders.docs) {
      batch.update(doc.reference, {"Address": newAddress}); // Update address in user orders
    }

    // Get all orders in global collection for the user
    QuerySnapshot globalOrders = await firestore
        .collection('Orders')
        .where('Id', isEqualTo: userId)
        .get();

    for (var doc in globalOrders.docs) {
      batch.update(doc.reference, {"Address": newAddress}); // Update address in admin orders
    }

    await batch.commit();                                  // Commit all updates together
  }
}
 