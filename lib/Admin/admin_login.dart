import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fooddelivery_app/Admin/home_admin.dart';
import 'package:lottie/lottie.dart';
import 'package:fooddelivery_app/Admin/admin_login.dart';  

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;

  Future<void> adminLogin(String username, String password) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Admin')
          .where('username', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isEmpty) {
        showSnackBar("Invalid username or password", Colors.redAccent);
        return;
      }

      var adminDoc = querySnapshot.docs.first;
      var data = adminDoc.data() as Map<String, dynamic>;

      // Convert input password to int
      int inputPassword = int.tryParse(password) ?? -1; // if not a number, set -1 to fail

      // Check if stored password is an int
      if (data['password'] is int) {
        if (data['password'] == inputPassword) {
          showSnackBar("Logged in Successfully!", Colors.white);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => HomeAdmin()));
        } else {
          showSnackBar("Invalid username or password", Colors.redAccent);
        }
      } else {
        // If password stored as string for some reason
        if (data['password'].toString() == password) {
          showSnackBar("Logged in Successfully!", Colors.white);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => HomeAdmin()));
        } else {
          showSnackBar("Invalid username or password", Colors.redAccent);
        }
      }
    } catch (e) {
      showSnackBar("Invalid username or password", Colors.redAccent);
    }
  }

  void showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        elevation: 6,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            Icon(
              color == Colors.redAccent ? Icons.error : Icons.check_circle,
              color: color == Colors.redAccent ? Colors.white : Colors.green,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: color == Colors.redAccent ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  } 


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffbecec),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 250,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xffff9a9e), Color(0xfffad0c4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Center(
                    child: Lottie.asset("images/signup.json", height: 180), 
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(25.0),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pinkAccent.withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Admin Login",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          label: "Username",
                          controller: usernameController,
                          icon: Icons.person,
                          hintText: "admin123",
                        ),
                        const SizedBox(height: 20),
                        _buildPasswordField(),
                        const SizedBox(height: 30),
                        GestureDetector(
                          onTap: () {
                            if (usernameController.text.isNotEmpty &&
                                passwordController.text.isNotEmpty) {
                                adminLogin(usernameController.text, passwordController.text); 
                            }
                          },
                          child: _buildLoginButton(),
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
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            )),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey),
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.deepOrange),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Password",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            )),
        const SizedBox(height: 6),
        TextField(
          obscureText: _obscureText,
          controller: passwordController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscureText = !_obscureText),
              child: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
            ),
            hintText: "••••••••",
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.deepOrange),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xffff4e50), Color(0xfff9d423)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          "Login",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}
 