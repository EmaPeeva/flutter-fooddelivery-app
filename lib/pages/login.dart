import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import'package:flutter/material.dart';
import 'package:fooddelivery_app/Admin/admin_login.dart';
import 'package:fooddelivery_app/pages/bottomnav.dart';
import 'package:lottie/lottie.dart';
import 'signup.dart';  


class LogIn extends StatefulWidget { 
  final bool showLogoutMessage; // Whether to show "logged out" message on screen

  const LogIn({Key? key, this.showLogoutMessage = false}) : super(key: key);

  @override 
  State<LogIn> createState() => _LogInState(); // Create the state object
}

class _LogInState extends State<LogIn> {
  String email="", password="", name=""; // Variables to store user input values
  TextEditingController namecontroller = new TextEditingController(); // Controller for name input field
  TextEditingController passwordcontroller = new TextEditingController(); // Controller for password input field
  TextEditingController mailcontroller = new TextEditingController(); // Controller for email input field
  bool _obscureText = true; // To show/hide password text

  @override
  void initState() {
    super.initState();

    // If showLogoutMessage is true, show a snackbar after widget is built
    if (widget.showLogoutMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.white, // Snackbar background color
            elevation: 6, // Shadow elevation of snackbar
            behavior: SnackBarBehavior.floating, // Snackbar floats over content
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Margin around snackbar
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
            content: Row( // Row with icon and text
              children: const [
                Icon(Icons.check_circle, color: Colors.green, size: 28), // Green check icon
                SizedBox(width: 12), // Space between icon and text
                Expanded(
                  child: Text(
                    "Logged out successfully!", // Message text
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 3), // Duration the snackbar is visible
          ),
        );
      });
    }
  } 

  // Function to handle user login
  userLogin() async {
    try {
      // Try to sign in user with email and password
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email.trim(), password: password.trim());

      // On success, show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.white,
          elevation: 6,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Logged in Successful!", // Success message
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate to BottomNav page after login
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BottomNav()),
      );

    } on FirebaseAuthException catch (e) {
      // On any Firebase auth error, show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent, // Red background for errors
          elevation: 6,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white, size: 28), // Error icon
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Invalid email or password", // Fixed error message
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
  
}


 
  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xfffbecec), // Set background color of the whole screen
    body: SingleChildScrollView(               // Make the content scrollable if it overflows screen
      child: Column(                          // Arrange widgets vertically
        children: [
          // Top Lottie Animation inside a Stack
          Stack(
            children: [
              Container(
                height: 280,                   // Fixed height for the top section
                decoration: const BoxDecoration(
                  gradient: LinearGradient(   // Background gradient colors
                    colors: [Color(0xffff9a9e), Color(0xfffad0c4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(  // Rounded corners only at bottom left and right
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Center(
                  child: Lottie.asset("images/signup.json", height: 180), // Play Lottie animation with fixed height
                ),
              ),
            ],
          ),

          // Glassmorphism style sign-up form container with padding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10), // Space around the form
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25.0), // Rounded corners for the form
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0), // Blur background behind the form for glass effect
                child: Container(
                  width: double.infinity,           // Make container take full width
                  padding: const EdgeInsets.all(20), // Inner padding inside the form container
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6), // Semi-transparent white background
                    borderRadius: BorderRadius.circular(25.0), // Rounded corners same as ClipRRect
                    border: Border.all(color: Colors.white.withOpacity(0.3)), // Light border for the glass effect
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pinkAccent.withOpacity(0.1), // Soft pink shadow color
                        blurRadius: 30,           // Blur effect for shadow
                        offset: const Offset(0, 8), // Shadow offset downwards
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Created Account",          // Title text of the form
                        style: TextStyle(
                          fontSize: 22,             // Font size
                          fontWeight: FontWeight.w700, // Bold text
                          color: Colors.black87,   // Dark grey color
                        ),
                      ),
                      const SizedBox(height: 10),  // Space between title and next widget

                      const SizedBox(height: 20),  // Extra space before input fields

                      // Email input field
                      _buildInputField(
                        label: "Email Address",    // Label for the field
                        controller: mailcontroller, // Controller to get email text
                        icon: Icons.email_outlined, // Email icon on the left
                        hintText: "example@mail.com", // Placeholder text inside input
                        keyboardType: TextInputType.emailAddress, // Show email keyboard on mobile
                      ),
                      const SizedBox(height: 20),  // Space below email input

                      // Password input field with special builder method
                      _buildPasswordField(),

                      const SizedBox(height: 30),  // Space before the button

                      // Sign Up button wrapped with GestureDetector to detect taps
                      GestureDetector(
                        onTap: () {
                          if (mailcontroller.text != "" && passwordcontroller.text != "") {
                            setState(() {
                              email = mailcontroller.text;      // Store entered email in state variable
                              password = passwordcontroller.text; // Store entered password
                            });
                            userLogin();                        // Call login function
                          }
                          // TODO: Implement sign-up logic if needed
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300), // Animate changes smoothly
                          height: 50,                 // Fixed height for button
                          width: double.infinity,     // Full width button
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30), // Rounded corners for button
                            gradient: const LinearGradient(          // Gradient background for button
                              colors: [Color(0xffff4e50), Color(0xfff9d423)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepOrange.withOpacity(0.3), // Shadow color
                                blurRadius: 10,            // Blur for shadow
                                offset: const Offset(0, 5), // Shadow below button
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "LogIn",               // Button label text
                              style: TextStyle(
                                color: Colors.white,  // White text color
                                fontWeight: FontWeight.bold, // Bold font weight
                                fontSize: 16,         // Font size 16
                                letterSpacing: 1.1,   // Spacing between letters
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),  // Space after button

                      // "OR" divider with lines on both sides
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade400)), // Left line
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text("or", style: TextStyle(color: Colors.black45)), // "or" text in middle
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade400)), // Right line
                        ],
                      ),

                      const SizedBox(height: 15),  // Space after divider

                      // "Don't have an account?" with sign up link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Center the row content
                        children: [
                          const Text("Don't have a account? ", style: TextStyle(fontSize: 14)), // Normal text
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, _createRoute()); // Navigate to Sign Up screen when tapped
                            },
                            child: const Text(
                              "Sign Up",          // Link text
                              style: TextStyle(
                                color: Colors.deepOrangeAccent, // Orange accent color
                                fontWeight: FontWeight.bold,    // Bold text
                                fontSize: 14,
                                decoration: TextDecoration.underline, // Underlined text to look clickable
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),  // Small space below

                      // Login as Admin link
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AdminLogin()), // Navigate to AdminLogin screen
                          );
                        },
                        child: const Text(
                          "Login as Admin?",     // Link text
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.deepPurple,   // Purple color text
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline, // Underlined for link style
                          ),
                        ),
                      ),
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

Widget _buildInputField({
  required TextEditingController controller,  // Controller to manage the text input
  required String label,                       // Label text shown above the input field
  required IconData icon,                      // Icon to show inside the input field prefix
  String? hintText,                           // Placeholder text inside the input field (optional)
  TextInputType? keyboardType,                // Type of keyboard to show (email, number, etc.)
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,  // Align children to the start (left)
    children: [
      Text(
        label,                                 // Show the label text
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,               // Dark text color
        ),
      ),
      const SizedBox(height: 6),                // Small space after the label
      TextField(
        controller: controller,                  // Connect the text field to the controller
        keyboardType: keyboardType,              // Set keyboard type if provided
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey), // Show icon before the input text
          hintText: hintText,                       // Placeholder inside input
          filled: true,
          fillColor: Colors.white,                  // White background for input box
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16), // Padding inside input box
          enabledBorder: OutlineInputBorder(        // Border when input is not focused
            borderRadius: BorderRadius.circular(14), // Rounded corners
            borderSide: BorderSide(color: Colors.grey.shade300), // Light grey border color
          ),
          focusedBorder: OutlineInputBorder(        // Border when input is focused (clicked)
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.deepOrange), // Orange border on focus
          ),
        ),
      ),
    ],
  );
}

Widget _buildPasswordField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,  // Align children to left
    children: [
      const Text(
        "Password",                               // Label for password field
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 6),                    // Small space after label
      TextField(
        obscureText: _obscureText,                  // Hide/show password text based on this bool
        controller: passwordcontroller,             // Connect text controller for password
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey), // Lock icon prefix
          suffixIcon: GestureDetector(              // Icon to toggle password visibility
            onTap: () => setState(() => _obscureText = !_obscureText),  // Switch hide/show on tap
            child: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,  // Show correct icon
              color: Colors.grey,
            ),
          ),
          hintText: "••••••••",                      // Placeholder to indicate password input
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          enabledBorder: OutlineInputBorder(        // Border style when not focused
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(        // Border style when focused
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.deepOrange),
          ),
        ),
      ),
    ],
  );
}

Route _createRoute() {
  return PageRouteBuilder(
    // Define the page to navigate to (SignUp screen)
    pageBuilder: (context, animation, secondaryAnimation) => const SignUp(),

    // Define how the page transition animation looks
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);  // Start sliding from the right side of the screen
      const end = Offset.zero;          // End at the original position (center)
      const curve = Curves.ease;        // Smooth animation curve

      // Combine the slide tween with the curve
      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      // Apply the slide transition animation to the new page widget
      return SlideTransition(
        position: animation.drive(tween),  // Animate the position of the new page
        child: child,                      // The page to be displayed (SignUp)
      );
    },
  );
}

void showSnackBar(String message, Color color) {
  // Show a snackbar message at the bottom of the screen
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: color,           // Background color of the snackbar
      content: Text(
        message,                       // Message text displayed in the snackbar
        style: TextStyle(
          fontSize: 16.0,              // Font size of the message
          fontWeight: FontWeight.bold, // Make the message text bold
        ),
      ),
    ),
  );
}
} 

  