import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fooddelivery_app/service/database.dart';
import 'package:fooddelivery_app/service/shared_pref.dart';
import 'package:fooddelivery_app/service/widget_support.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:convert'; // for jsonDecode
import 'package:http/http.dart' as http; // for HTTP requests
import 'package:flutter_stripe/flutter_stripe.dart'; // for Stripe
import 'package:fooddelivery_app/service/constant.dart';
import 'package:random_string/random_string.dart';

class DetailPage extends StatefulWidget { //hows details of a selected food item
  final String image; //required fields that describe the food item:
  final String name;
  final String price;
  final String description;
  final double star; 

  // New optional parameters for editing existing order
  final String? existingOrderId; 
  final int? initialQuantity;
  final String? initialAddress;

  const DetailPage({   //This is the constructor that is used when calling DetailPage(...).

//required fields must be passed.

//Optional fields can be left out.
     Key? key, 
    required this.image,
    required this.name,
    required this.price,
    required this.description,
    required this.star,
    this.existingOrderId,
    this.initialQuantity,
    this.initialAddress,
  }) : super(key:key); // <- 

  @override
  State<DetailPage> createState() => _DetailPageState(); // widget to its State class, _HomeState, which will control how the UI works and updates
}
 class _DetailPageState extends State<DetailPage> {
  // Controller for the address text input field
  TextEditingController adresscontroller = TextEditingController();

  // Stores payment intent details, used for payment processing (if any)
  Map<String, dynamic>? paymentIntent;

  // Variables to store user info fetched from shared preferences
  String? name, id, email, adress, description;

  // Quantity of the food item the user wants to order
  int quantity = 1;

  // Total price calculated as price * quantity
  int totalprice = 0;

  // Food item rating (average rating)
  double star = 0.0;

  // User's personal rating for the food item
  double userRating = 0.0;

  // Coordinates - could be used for delivery location (not used here)
  double lat = 0.0;
  double lng = 0.0;

  // Function to fetch saved user info (name, id, email, address) from shared preferences asynchronously
  getthesharedpref() async {
    name = await SharedpreferenceHelper().getUserName(); // get user name
    id = await SharedpreferenceHelper().getUserId();     // get user id
    email = await SharedpreferenceHelper().getUserEmail(); // get user email
    adress = await SharedpreferenceHelper().getUserAddress(); // get saved address
    setState(() {
      // Update UI after loading data
    });
  }

  // Runs once when the widget is first created
  @override
  void initState() {
    super.initState();

    // Set initial quantity from widget property or default to 1
    quantity = widget.initialQuantity ?? 1;

    // Set the address input field's text from widget property or empty
    adresscontroller.text = widget.initialAddress ?? '';
    adress = widget.initialAddress ?? '';

    // Calculate initial total price = price * quantity
    totalprice = (int.parse(widget.price) * quantity);

    // Fetch saved user data
    getthesharedpref();
  }

  // Called after initState and when dependencies change
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Recalculate total price (in case something changed)
    totalprice = (int.parse(widget.price) * quantity);
  }

  // Builds the UI of the detail page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background color of the entire screen (red color)
      backgroundColor: Color(0xffef2b39),

      // Stack allows overlapping widgets
      body: Stack(
        children: [
          // Positioned widget for back button at top-left corner
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context), // Go back when tapped
              child: CircleAvatar(
                backgroundColor: Colors.white, // white circle background
                child: Icon(Icons.arrow_back, color: Color(0xffef2b39)), // red back arrow icon
              ),
            ),
          ),

          // Main content column
          Column(
            children: [
              SizedBox(height: 60), // Space at the top

              // Hero widget for smooth image transition animation between pages
              Hero(
                tag: widget.image, // Unique tag based on image path
                child: Image.asset(
                  widget.image, // Food image
                  height: MediaQuery.of(context).size.height / 3, // One-third of screen height
                ),
              ),

              // The bottom sheet container that can be dragged up/down to reveal more content
              Expanded(
                child: DraggableScrollableSheet(
                  initialChildSize: 0.55, // Initial height (55% of screen)
                  minChildSize: 0.45,     // Minimum height (45%)
                  maxChildSize: 0.95,     // Maximum height (95%)
                  builder: (context, scrollController) {
                    return Container(
                      padding: EdgeInsets.all(20), // Padding inside the container
                      decoration: BoxDecoration(
                        color: Colors.white, // White background color
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(30)), // Rounded top corners
                      ),
                      // Scrollable content inside the bottom sheet
                      child: SingleChildScrollView(
                        controller: scrollController, // Connect scroll to draggable sheet
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Small grey bar at the top to indicate draggable area
                            Center(
                              child: Container(
                                width: 40,
                                height: 5,
                                margin: EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: Colors.grey[400], // light grey color
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),

                            // Food name in bold, big font
                            Text(
                              widget.name,
                              style: AppWidget.boldTextFeildStyle()
                                  .copyWith(fontSize: 26),
                            ),

                            SizedBox(height: 8), // Spacing

                            // Food price styled text
                            Text("\$${widget.price}",
                                style: AppWidget.priceTextFeildStyle()),

                            SizedBox(height: 20), // Spacing

                            // Food description text
                            Text(
                              widget.description,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[700]),
                            ),

                            SizedBox(height: 30), // Spacing

                            // Label "Average Rating"
                            Text("Average Rating",
                                style: AppWidget.boldTextFeildStyle()),

                            SizedBox(height: 10), // Spacing

                            // Row with stars and numeric average rating
                            Row(
                              children: [
                                RatingBarIndicator(
                                  rating: widget.star, // Show average rating stars
                                  itemBuilder: (context, index) => Icon(
                                    Icons.star,
                                    color: Colors.amber, // star color
                                  ),
                                  itemCount: 5,  // max stars
                                  itemSize: 24.0,
                                  direction: Axis.horizontal,
                                ),
                                SizedBox(width: 10), // spacing
                                Text(widget.star.toStringAsFixed(1),
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black87)),
                              ],
                            ),

                            SizedBox(height: 20), // Spacing

                            // Label "Your Rating"
                            Text("Your Rating",
                                style: AppWidget.boldTextFeildStyle()),

                            SizedBox(height: 10), // Spacing

                            // RatingBar where user can set their own rating
                            RatingBar.builder(
                              initialRating: userRating, // current user rating
                              minRating: 1,              // minimum rating is 1
                              allowHalfRating: true,     // allow half stars
                              itemCount: 5,              // 5 stars max
                              itemPadding:
                                  EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                setState(() {
                                  userRating = rating; // update user's rating
                                });
                                // Optional: you can save this rating somewhere
                                print("User rated: $rating");
                              },
                            ),

                            // Label "Quantity"
                            Text("Quantity",
                                style: AppWidget.boldTextFeildStyle()),

                            SizedBox(height: 10), // Spacing

                            // Row with buttons to decrease/increase quantity and current quantity display
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Button to decrease quantity
                                _buildQuantityButton(Icons.remove, () {
                                  if (quantity > 1) {
                                    setState(() {
                                      quantity--;
                                      totalprice -= int.parse(widget.price);
                                    });
                                  }
                                }),

                                // Display current quantity
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    quantity.toString(),
                                    style: AppWidget.boldTextFeildStyle()
                                        .copyWith(fontSize: 20),
                                  ),
                                ),

                                // Button to increase quantity
                                _buildQuantityButton(Icons.add, () {
                                  setState(() {
                                    quantity++;
                                    totalprice += int.parse(widget.price);
                                  });
                                }),
                              ],
                            ),

                            SizedBox(height: 40), // Spacing

                            // Row with total price and order button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Total price container
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: Color(0xffef2b39), // red background
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "\$${totalprice.toString()}",
                                    style: AppWidget.priceTextFeildStyle()
                                        .copyWith(color: Colors.white),
                                  ),
                                ),

                                // Order Now / Update Order button
                                GestureDetector(
                                  onTap: () async {
                                    await openBox(); // Presumably opens a storage box (e.g. Hive)

                                    // Check if address is entered
                                    if (adresscontroller.text.trim().isNotEmpty) {
                                      // Save address locally
                                      await SharedpreferenceHelper()
                                          .saveUserAddress(adresscontroller.text);

                                      setState(() {
                                        adress = adresscontroller.text;
                                      });

                                      // If this is a new order (no existing order id)
                                      if (widget.existingOrderId == null) {
                                        // Start payment process
                                        await makePayment(totalprice.toString());
                                      } else {
                                        // Update existing order instead
                                        await updateOrder();
                                      }
                                    } else {
                                      // Show error message if address empty
                                      showSnackBar(
                                          "Please enter your address.", Colors.red);
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 18),
                                    decoration: BoxDecoration(
                                      color: Colors.black, // black background
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.shopping_cart, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text(
                                          widget.existingOrderId == null
                                              ? "Order Now"  // For new orders
                                              : "Update Order", // For editing orders
                                          style: AppWidget.boldTextFeildStyle()
                                              .copyWith(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  // Method to update an existing order in the database
Future<void> updateOrder() async {
  try {
    // Call a method to update the order details in database for the given user id and existing order id
    await DatabaseMethods().updateUserOrderDetails(
      id!,                      // User ID (non-null)
      widget.existingOrderId!,  // Existing order ID (non-null)
      {
        "Quantity": quantity.toString(),           // Update quantity as string
        "Total": totalprice.toString(),            // Update total price as string
        "Address": adresscontroller.text,          // Update address from the input controller
        "Timestamp": FieldValue.serverTimestamp(), // Update with current server timestamp
      },
    );

    // Show a success message (snackbar) after successful update
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        elevation: 6,
        behavior: SnackBarBehavior.floating,             // Snack bar floats over content
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Margin around snackbar
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),       // Rounded corners
        ),
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28), // Green check icon
            SizedBox(width: 12),                                   // Spacing
            Expanded(
              child: Text(
                "Order updated successfully!",                   // Message text
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        duration: Duration(seconds: 3), // Show snackbar for 3 seconds
      ),
    );

    // After success, navigate back and send 'true' to indicate success
    Navigator.pop(context, true);
  } catch (e) {
    // If error happens, show error message snackbar
    showSnackBar("Failed to update order: $e", Colors.red);
  }
}

// Method to handle the payment process using Stripe
Future<void> makePayment(String amount) async {
  try {
    // Create a payment intent on the server with given amount and currency (USD)
    paymentIntent = await createPaymentIntent(amount, 'USD');

    // Initialize Stripe payment sheet with client secret and styling
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntent!['client_secret'], // Client secret from payment intent
        style: ThemeMode.dark,                                       // Dark theme for payment sheet
        merchantDisplayName: 'Mia',                                  // Merchant name shown in sheet
      ),
    );

    // Display the payment sheet to the user to complete payment
    await displayPaymentSheet(amount);
  } catch (e, s) {
    // Print any errors with stack trace for debugging
    print('exception:$e$s');
  }
}
 
  // Method to present the Stripe payment sheet to the user and handle payment success/failure
displayPaymentSheet(String amount) async {
  try {
    // Show the payment sheet UI to the user for completing the payment
    await Stripe.instance.presentPaymentSheet().then((value) async {
      
      // Generate a random order ID (10 alphanumeric characters)
      String orderId = randomAlphaNumeric(10);

      // Example coordinates for the driver location (hardcoded here)
      lat = 41.9981; // latitude
      lng = 21.4254; // longitude

      // Prepare a map (dictionary) with order details to save to database
      Map<String, dynamic> userOrderMap = {
        "Name": name,                   // User name
        "Id": id,                       // User ID
        "Quantity": quantity.toString(),// Quantity ordered
        "Total": totalprice.toString(), // Total price of order
        "Email": email,                 // User email
        "FoodName": widget.name,        // Food name ordered
        "FoodImage": widget.image,      // Image of the food
        "Description": widget.description, // Food description
        "Star": widget.star.toString(), // Food star rating
        "OrderId": orderId,             // Unique order ID
        "Status": "Pending",            // Order status initially pending
        "driverLat": lat,               // Driver latitude location
        "driverLng": lng,               // Driver longitude location
        "Timestamp": FieldValue.serverTimestamp(), // Server timestamp for order time
        "UserRating": userRating.toString(),       // User rating for this order
        "Address": adress ?? adresscontroller.text, // User delivery address
      };

      // Save the order details to user's order collection in database
      await DatabaseMethods().addUserOrderDetails(userOrderMap, id!, orderId);

      // Also save the order to admin's order collection for management
      await DatabaseMethods().addAdminOrderDetails(userOrderMap, orderId);

      // Show a snackbar notifying order placed successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.white,
          elevation: 6,
          behavior: SnackBarBehavior.floating, // Floating snackbar style
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Padding around snackbar
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28), // Green check icon
              SizedBox(width: 12), // Spacing
              Expanded(
                child: Text(
                  "Order Placed Successfully!", // Message text
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          duration: Duration(seconds: 3), // Show snackbar for 3 seconds
        ),
      );

      // Show a dialog box confirming successful payment
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min, // Wrap content vertically
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green), // Green check icon
                  Text("Payment Successful") // Message
                ],
              )
            ],
          ),
        ),
      );

      // Reset the payment intent since payment is done
      paymentIntent = null;

      // Close current page and return 'true' indicating order was placed
      Navigator.pop(context, true);

    }).onError((error, stackTrace) {
      // Print error info if any occurs during presenting payment sheet
      print("Error is: ----->$error $stackTrace");
    });
  } on StripeException catch (e) {
    // Catch specific Stripe exceptions (e.g. user cancels payment)
    print("Error is:---> $e");
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text("Cancelled"), // Inform user that payment was cancelled
      ),
    );
  } catch (e) {
    // Catch all other exceptions
    print('$e');
  }
}

// Method to create a Stripe payment intent on the backend server via Stripe API
createPaymentIntent(String amount, String currency) async {
  try {
    // Prepare the body parameters for the payment intent request
    Map<String, dynamic> body = {
      'amount': calculateAmount(amount), // Amount in smallest currency unit (e.g. cents)
      'currency': currency,               // Currency code (e.g. USD)
      'payment_method_types[]': 'card'   // Accept card payments
    };

    // Make a POST request to Stripe's payment intents API
    var response = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
      headers: {
        'Authorization': 'Bearer $secretkey',         // Your Stripe secret key for authorization
        'Content-Type': 'application/x-www-form-urlencoded', // Content type for form data
      },
      body: body, // Request body parameters
    );

    // Debug print the response status code
    print("Status code: ${response.statusCode}");
    // Debug print the response body from Stripe API
    print("Stripe response: ${response.body}");

    // Decode and return the JSON response as a Map
    return jsonDecode(response.body);
  } catch (err) {
    // Print any error caught during the HTTP request
    print('Exception charging user: ${err.toString()}');
  }
}

// Helper method to convert amount string (e.g. "10") to smallest currency unit (e.g. 1000 cents)
calculateAmount(String amount) {
  // Multiply amount by 100 because Stripe expects amount in cents
  final calculatedAmount = (int.parse(amount) * 100);

  // Return amount as string
  return calculatedAmount.toString();
}
 

  // Method to open a dialog box where user can add/edit their address
Future<void> openBox() async {
  return showDialog(
    context: context, // The BuildContext of the widget calling this
    builder: (context) => AlertDialog( // Alert dialog widget
      content: SingleChildScrollView( // Allow content to scroll if too big
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align children to start horizontally
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Close the dialog when cancel icon is tapped
                    },
                    child: Icon(Icons.cancel), // Cancel icon (X)
                  ),
                  SizedBox(width: 30.0), // Spacing between icon and text
                  Text(
                    "Add the Address", // Title text of the dialog
                    style: TextStyle(
                      color: Color.fromARGB(255, 18, 233, 154), // Greenish color
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  )
                ],
              ),
              SizedBox(height: 20.0), // Vertical spacing
              Text("Add Address"), // Label text for address input field
              SizedBox(height: 10.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0), // Horizontal padding inside container
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black38), // Border color and width
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                child: TextField(
                  controller: adresscontroller, // Controller to manage the text input value
                  decoration: InputDecoration(
                    border: InputBorder.none, // Remove default TextField border
                    hintText: "Address Input", // Placeholder text shown when empty
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Close the dialog when 'Add' button tapped
                  },
                  child: Container(
                    width: 100,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 7, 219, 159), // Green button background
                      borderRadius: BorderRadius.circular(10), // Rounded corners
                    ),
                    child: Center(
                      child: Text(
                        "Add", // Button text
                        style: TextStyle(color: Colors.white, fontSize: 15.0), // White text
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// Utility method to show a snackbar with custom message and background color
void showSnackBar(String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: color, // Set background color of snackbar
      content: Text(
        message, // Display the passed message string
        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold), // Bold font for readability
      ),
    ),
  );
}

// Widget builder for quantity increment/decrement buttons with icon and tap callback
Widget _buildQuantityButton(IconData icon, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap, // Function to execute when button tapped
    child: Material(
      elevation: 4, // Slight shadow elevation for button
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Rounded corners
      child: Container(
        padding: EdgeInsets.all(8), // Padding inside button
        decoration: BoxDecoration(
          color: Color(0xffef2b39), // Red background color
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
        child: Icon(icon, color: Colors.white, size: 24), // Icon inside button with white color
      ),
    ),
  );
}
} 