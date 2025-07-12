import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fooddelivery_app/pages/bottomnav.dart';
import 'package:fooddelivery_app/service/database.dart';
import 'package:fooddelivery_app/service/shared_pref.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui'; 
import 'login.dart'; // or the correct path to your login screen

class SignUp extends StatefulWidget {
  const SignUp({super.key}); // Constructor for SignUp widget

  @override
  State<SignUp> createState() => _SignUpState(); // Create mutable state for widget
}

class _SignUpState extends State<SignUp> { 
  String email = "", password = "", name = ""; // store user data
  TextEditingController namecontroller = TextEditingController(); // Controller for name input
  TextEditingController passwordcontroller = TextEditingController(); // Controller for password input
  TextEditingController mailcontroller = TextEditingController(); // Controller for email input
  bool _obscureText = true; // Control password visibility

  registration() async {  // Function to handle user registration
    final emailRegEx = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'); // Regex for validating email format

    if (passwordcontroller.text.isNotEmpty && // Check if password is not empty
        namecontroller.text.isNotEmpty &&     // Check if name is not empty
        mailcontroller.text.isNotEmpty) {     // Check if email is not empty
      
      if (!emailRegEx.hasMatch(mailcontroller.text)) { // Validate email format
        showSnackBar("Please enter a valid email address", Colors.redAccent); // Show error if invalid
        return; // Stop further execution
      }

      String password = passwordcontroller.text; // Get password from input

      final passwordRegExUpper = RegExp(r'[A-Z]'); // Regex to check for uppercase letter
      final passwordRegExNumber = RegExp(r'[0-9]'); // Regex to check for number

      if (password.length < 6) { // Check password length
        showSnackBar("Password must be at least 6 characters long", Colors.redAccent); // Show error
        return; // Stop execution
      } else if (!passwordRegExUpper.hasMatch(password)) { // Check for uppercase letter
        showSnackBar("Password must contain at least one uppercase letter", Colors.redAccent); // Error message
        return; // Stop execution
      } else if (!passwordRegExNumber.hasMatch(password)) { // Check for number in password
        showSnackBar("Password must contain at least one number", Colors.redAccent); // Error message
        return; // Stop execution
      }

      try { // Try to register user
        String email = mailcontroller.text; // Get email from input
        password = passwordcontroller.text; // Get password from input again

        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password); // Register user in Firebase
        
        String uid = FirebaseAuth.instance.currentUser!.uid; // Get user ID after registration

        Map<String, dynamic> userInfoMap = { // Create map to store user info
          "name": namecontroller.text, // User name
          "email": mailcontroller.text, // User email
          "uid": uid, // User ID
          "image": "", // Default empty image URL
          "address": "", // Default empty address
        };

        await SharedpreferenceHelper().saveUserId(uid); // Save user ID locally
        await SharedpreferenceHelper().saveUserEmail(mailcontroller.text); // Save email locally
        await SharedpreferenceHelper().saveUserName(namecontroller.text); // Save name locally

        await DatabaseMethods().addUserDetails(userInfoMap, uid); // Save user details in database

        showSnackBar("Registration Successful!", Colors.white); // Show success message

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNav())); // Navigate to main app screen

      } on FirebaseAuthException catch (e) { // Catch Firebase registration errors
        if (e.code == 'weak-password') {
          showSnackBar("Password provided is too weak", Colors.orangeAccent); // Show weak password error
        } else if (e.code == "email-already-in-use") {
          showSnackBar("Account Already exists", Colors.orangeAccent); // Show email already used error
        } else {
          showSnackBar("Error: ${e.message}", Colors.orangeAccent); // Show any other error from Firebase
        }
      } catch (e) { // Catch any other errors
        showSnackBar("Error: $e", Colors.orangeAccent); // Show generic error message
      }
    } else {
      showSnackBar("Please fill all fields", Colors.redAccent); // If any input is empty, show error
    }
  }


  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xfffbecec), // Set background color of the page
    body: SingleChildScrollView( // Make the whole content scrollable if needed
      child: Column(
        children: [
          // Top Lottie Animation
          Stack(
            children: [
              Container(
                height: 280, // Container height for animation area
                decoration: const BoxDecoration(
                  gradient: LinearGradient( // Background gradient colors
                    colors: [Color(0xffff9a9e), Color(0xfffad0c4)],
                    begin: Alignment.topLeft, // Gradient start position
                    end: Alignment.bottomRight, // Gradient end position
                  ),
                  borderRadius: BorderRadius.only( // Rounded corners at bottom only
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Center(
                  child: Lottie.asset("images/signup.json", height: 180), // Show Lottie animation
                ),
              ),
            ],
          ),

          // Glassmorphism Sign-Up Form
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10), // Outer padding
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25.0), // Rounded corners for form
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0), // Blur effect behind form
                child: Container(
                  width: double.infinity, // Full width container
                  padding: const EdgeInsets.all(20), // Inner padding inside form
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6), // Semi-transparent white background
                    borderRadius: BorderRadius.circular(25.0), // Rounded corners again
                    border: Border.all(color: Colors.white.withOpacity(0.3)), // Light border
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pinkAccent.withOpacity(0.1), // Soft shadow color
                        blurRadius: 30, // Shadow blur radius
                        offset: const Offset(0, 8), // Shadow position offset
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Create Account", // Title text
                        style: TextStyle(
                          fontSize: 22, // Font size
                          fontWeight: FontWeight.w700, // Bold font weight
                          color: Colors.black87, // Text color
                        ),
                      ),
                      const SizedBox(height: 30), // Space below title

                      _buildInputField( // Custom input field for full name
                        label: "Full Name",
                        controller: namecontroller,
                        icon: Icons.person,
                        hintText: "John Doe",
                      ),

                      const SizedBox(height: 20), // Space between fields

                      _buildInputField( // Custom input field for email
                        label: "Email Address",
                        controller: mailcontroller,
                        icon: Icons.email_outlined,
                        hintText: "example@mail.com",
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 20), // Space between fields

                      _buildPasswordField(), // Custom password input field

                      const SizedBox(height: 30), // Space before button

                      GestureDetector(
                        onTap: () {
                          registration(); // Call registration function on tap
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300), // Animation duration
                          height: 50, // Button height
                          width: double.infinity, // Button full width
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30), // Rounded button corners
                            gradient: const LinearGradient( // Gradient background for button
                              colors: [Color(0xffff4e50), Color(0xfff9d423)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepOrange.withOpacity(0.3), // Button shadow color
                                blurRadius: 10, // Shadow blur radius
                                offset: const Offset(0, 5), // Shadow offset
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "Sign Up", // Button text
                              style: TextStyle(
                                color: Colors.white, // Text color
                                fontWeight: FontWeight.bold, // Bold font
                                fontSize: 16, // Font size
                                letterSpacing: 1.1, // Letter spacing
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20), // Space after button

                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade400)), // Left line
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text("or", style: TextStyle(color: Colors.black45)), // 'or' text
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade400)), // Right line
                        ],
                      ),

                      const SizedBox(height: 15), // Space after divider

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Center horizontally
                        children: [
                          const Text("Already a user? ", style: TextStyle(fontSize: 14)), // Text prompt
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, _createRoute()); // Navigate to login page
                            },
                            child: const Text(
                              "Log In", // Login text clickable
                              style: TextStyle(
                                color: Colors.deepOrangeAccent, // Text color
                                fontWeight: FontWeight.bold, // Bold font
                                fontSize: 14, // Font size
                                decoration: TextDecoration.underline, // Underline text
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10), // Bottom space
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildInputField({  // Custom reusable input field widget
  required TextEditingController controller, // Controller for text input
  required String label, // Label text shown above the field
  required IconData icon, // Icon shown inside the field
  String? hintText, // Placeholder text inside the field (optional)
  TextInputType? keyboardType, // Keyboard type (optional)
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start horizontally
    children: [
      Text(label, // Show the label text
          style: const TextStyle(
            fontSize: 14, // Font size for label
            fontWeight: FontWeight.w600, // Semi-bold label text
            color: Colors.black87, // Label color
          )),
      const SizedBox(height: 6), // Space between label and text field
      TextField(
        controller: controller, // Attach controller to get/set input value
        keyboardType: keyboardType, // Set keyboard type if provided
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey), // Icon shown on left inside field
          hintText: hintText, // Placeholder text inside the input
          filled: true, // Fill the background color
          fillColor: Colors.white, // White background fill
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16), // Padding inside input
          enabledBorder: OutlineInputBorder( // Border when input is not focused
            borderRadius: BorderRadius.circular(14), // Rounded corners of border
            borderSide: BorderSide(color: Colors.grey.shade300), // Light grey border color
          ),
          focusedBorder: OutlineInputBorder( // Border when input is focused
            borderRadius: BorderRadius.circular(14), // Rounded corners for focused border
            borderSide: const BorderSide(color: Colors.deepOrange), // Orange border color when focused
          ),
        ),
      ),
    ],
  );
}

Widget _buildPasswordField() { // Custom widget for password input field
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start, // Align label and input start horizontally
    children: [
      const Text("Password", // Fixed label "Password"
          style: TextStyle(
            fontSize: 14, // Font size for label
            fontWeight: FontWeight.w600, // Semi-bold label
            color: Colors.black87, // Label color
          )),
      const SizedBox(height: 6), // Space between label and input field
      TextField(
        obscureText: _obscureText, // Hide/show password based on this bool
        controller: passwordcontroller, // Attach password controller
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey), // Lock icon on left
          suffixIcon: GestureDetector( // Eye icon on right to toggle password visibility
            onTap: () => setState(() => _obscureText = !_obscureText), // Toggle obscureText state on tap
            child: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility, // Show eye open/closed icon
              color: Colors.grey, // Icon color grey
            ),
          ),
          hintText: "••••••••", // Placeholder dots for password
          filled: true, // Fill background with color
          fillColor: Colors.white, // White background fill
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16), // Padding inside input
          enabledBorder: OutlineInputBorder( // Border when not focused
            borderRadius: BorderRadius.circular(14), // Rounded corners
            borderSide: BorderSide(color: Colors.grey.shade300), // Light grey border
          ),
          focusedBorder: OutlineInputBorder( // Border when focused
            borderRadius: BorderRadius.circular(14), // Rounded corners
            borderSide: const BorderSide(color: Colors.deepOrange), // Orange border color on focus
          ),
        ),
      ),
    ],
  );
}

Route _createRoute() { 
  return PageRouteBuilder( // Create custom page route with animation
    pageBuilder: (context, animation, secondaryAnimation) => const LogIn(), // The page to show (LogIn)
    transitionsBuilder: (context, animation, secondaryAnimation, child) {  
      const begin = Offset(1.0, 0.0); // Start slide animation from right
      const end = Offset.zero; // End at original position (no offset)
      const curve = Curves.ease; // Use ease curve for smooth animation

      final tween = 
          Tween(begin: begin, end: end).chain(CurveTween(curve: curve)); // Define tween with curve

      return SlideTransition( // Use SlideTransition widget for animation
        position: animation.drive(tween), // Animate position using tween
        child: child, // The child page to animate
      );
    },
  );
} 

void showSnackBar(String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar( // Show snackbar message
    SnackBar(
      backgroundColor: color, // Background color of snackbar
      elevation: 6, // Shadow elevation
      behavior: SnackBarBehavior.floating, // Snackbar floats above UI
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Margin around snackbar
      shape: RoundedRectangleBorder( // Rounded corners for snackbar
        borderRadius: BorderRadius.circular(12),
      ),
      content: Row( // Content of snackbar is a row with icon and text
        children: [
          Icon(
            color == Colors.redAccent ? Icons.error : Icons.check_circle, // Icon based on color (error or success)
            color: color == Colors.redAccent ? Colors.white : Colors.green, // Icon color accordingly
            size: 28, // Icon size
          ),
          const SizedBox(width: 12), // Spacing between icon and text
          Expanded(
            child: Text(
              message, // Message text
              style: TextStyle(
                color: color == Colors.redAccent ? Colors.white : Colors.black87, // Text color based on background
                fontSize: 16, // Font size
                fontWeight: FontWeight.w600, // Semi-bold font
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 3), // Snackbar visible duration
    ),
  );
 } 
}
   

  