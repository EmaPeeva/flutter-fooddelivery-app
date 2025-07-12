import 'dart:io';
import 'package:fooddelivery_app/pages/bottomnav.dart';
import 'package:fooddelivery_app/pages/home.dart';
import 'package:fooddelivery_app/pages/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fooddelivery_app/service/database.dart';
import 'package:fooddelivery_app/service/shared_pref.dart';
import 'package:image_picker/image_picker.dart';

 class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> { 
  // Key to identify the form and validate inputs
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields to capture user input
  final _nameCtr = TextEditingController();
  final _emailCtr = TextEditingController();
  final _addressCtr = TextEditingController();
  final _currentPasswordCtr = TextEditingController();
  final _newPasswordCtr = TextEditingController();

  // URL string for profile photo stored remotely
  String profilePhotoUrl = '';

  // Local file for picked image (if user selects a new photo)
  File? _pickedImageFile;

  // Image picker instance to pick images from gallery or camera
  final ImagePicker _picker = ImagePicker();

  // Currently signed-in Firebase user
  User? currentUser;

  // Boolean to track loading state for async operations
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Get current Firebase user at widget initialization
    currentUser = FirebaseAuth.instance.currentUser;

    // If user is logged in, load their profile data from Firestore
    if (currentUser != null) {
      _loadProfileForUser(currentUser!.uid);
    }

    // Listen to auth state changes (user sign-in/sign-out)
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        // If no user logged in, clear all input fields and data
        _clearFields();
      } else {
        // If user logs in, update currentUser and reload profile data
        currentUser = user;
        _loadProfileForUser(user.uid);
      }
    });
  }

  // Clears all text fields and resets profile photo variables
  void _clearFields() {
    _nameCtr.clear();
    _emailCtr.clear();
    _addressCtr.clear();
    _currentPasswordCtr.clear();
    _newPasswordCtr.clear();

    setState(() {
      profilePhotoUrl = '';
      _pickedImageFile = null;
    });
  }

  // Loads profile data for the given user ID from Firestore
  Future<void> _loadProfileForUser(String uid) async {
    try {
      // Retrieve document from Firestore users collection by user ID
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        // If document exists, extract the data map
        final data = doc.data()!;

        // Set the text controllers with data from Firestore fields
        _nameCtr.text = data['name'] ?? '';
        _emailCtr.text = data['email'] ?? currentUser?.email ?? '';
        _addressCtr.text = data['address'] ?? '';

        setState(() {
          // Update profile photo URL and clear local picked image
          profilePhotoUrl = data['image'] ?? '';
          _pickedImageFile = null;
        });

        // Save the loaded profile info locally in SharedPreferences for faster access
        final prefs = SharedpreferenceHelper();
        await prefs.saveUserName(_nameCtr.text);
        await prefs.saveUserEmail(_emailCtr.text);
        await prefs.saveUserAddress(_addressCtr.text);
        await prefs.saveUserImage(profilePhotoUrl);
      } else {
        // If no document in Firestore, initialize fields with FirebaseAuth email only
        _nameCtr.clear();
        _emailCtr.text = currentUser?.email ?? '';
        _addressCtr.clear();

        setState(() {
          profilePhotoUrl = '';
          _pickedImageFile = null;
        });
      }
    } catch (e) {
      // In case of error, print error and clear fields
      debugPrint("Error loading profile: $e");
      _clearFields();
    }
  }



 // Opens the image picker to select a new profile picture from the gallery
Future<void> _pickImage() async {
  try {
    // Let user pick an image from gallery with 80% quality
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    
    // If an image was selected
    if (pickedFile != null) {
      // Update local state with the selected file so UI can show preview
      setState(() => _pickedImageFile = File(pickedFile.path));
      
      // Upload the picked image to Cloudinary and get the remote URL
      String? url = await _uploadImageToStorage(_pickedImageFile!);
      
      if (url != null) {
        // Update profile photo URL in state
        setState(() => profilePhotoUrl = url);

        // Update user document in Firestore with new profile image URL
        await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({'image': profilePhotoUrl});

        // Save new image URL locally in SharedPreferences for offline access
        await SharedpreferenceHelper().saveUserImage(profilePhotoUrl);
      }
    }
  } catch (e) {
    // If picking or uploading image fails, show error message
    debugPrint('Image picker error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to pick image')),
    );
  }
}

// Uploads a File to Cloudinary image hosting and returns the image URL as String
Future<String?> _uploadImageToStorage(File imageFile) async {
  try {
    // Your Cloudinary cloud name and unsigned upload preset (replace with your values)
    const cloudName = 'djiysbbic';
    const uploadPreset = 'flutter_preset';

    // Cloudinary upload API endpoint
    final uploadUrl = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

    // Prepare multipart POST request with file and preset
    final request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    // Send the request and wait for response
    final response = await request.send();

    if (response.statusCode == 200) {
      // Parse response body to extract secure URL of uploaded image
      final res = await http.Response.fromStream(response);
      final data = json.decode(res.body);
      return data['secure_url']; // Return image URL
    } else {
      debugPrint('Cloudinary upload failed: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    debugPrint('Cloudinary error: $e');
    return null;
  }
}

// Save profile changes, including name, email, address, password and profile photo
Future<void> saveProfileInfo() async {
  // Validate form input fields
  if (!_formKey.currentState!.validate()) return;

  // Make sure user is logged in
  if (currentUser == null) return;

  // Show loading spinner while processing
  setState(() { 
    _isLoading = true;
  });

  // Get trimmed input values
  final newEmail = _emailCtr.text.trim();
  final currentPassword = _currentPasswordCtr.text.trim();
  final newPassword = _newPasswordCtr.text.trim();
  final currentEmail = currentUser!.email ?? '';

  try {
    // If user wants to change email
    if (newEmail != currentEmail) {
      // Require current password to re-authenticate for sensitive change
      if (currentPassword.isEmpty) {
        throw FirebaseAuthException(
          code: 'requires-password',
          message: 'Enter current password to update email.',
        );
      }

      // Reauthenticate user with current credentials
      final credential = EmailAuthProvider.credential(
        email: currentEmail,
        password: currentPassword,
      );
      await currentUser!.reauthenticateWithCredential(credential);

      // Update email in Firebase Auth
      await currentUser!.updateEmail(newEmail);

      // Update email in Firestore user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update({'email': newEmail});

      // Save updated email locally
      await SharedpreferenceHelper().saveUserEmail(newEmail);
    }

    // If user wants to update password
    if (newPassword.isNotEmpty) {
      // Require current password again for re-authentication
      if (currentPassword.isEmpty) {
        throw FirebaseAuthException(
          code: 'requires-password',
          message: 'Enter current password to update password.',
        );
      }

      // Reauthenticate user
      final credential = EmailAuthProvider.credential(
        email: currentEmail,
        password: currentPassword,
      );
      await currentUser!.reauthenticateWithCredential(credential);

      // Update password in Firebase Auth
      await currentUser!.updatePassword(newPassword);
    }

    // Prepare updated profile data map for Firestore
    final uid = currentUser!.uid;
    Map<String, dynamic> userMap = {
      "name": _nameCtr.text.trim(),
      "email": newEmail,
      "image": profilePhotoUrl,
      "address": _addressCtr.text.trim(),
      "uid": uid,
    };

    // Add/update user data in Firestore (make sure your method merges existing data)
    await DatabaseMethods().addUserDetails(userMap, uid);

    // Also update user address in all related orders (optional)
    await DatabaseMethods().updateUserAddressInOrders(uid, _addressCtr.text.trim());

    // Save updated data locally as well
    final prefs = SharedpreferenceHelper();
    await prefs.saveUserId(uid);
    await prefs.saveUserName(_nameCtr.text.trim());
    await prefs.saveUserAddress(_addressCtr.text.trim());
    await prefs.saveUserImage(profilePhotoUrl);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),  
    );

    // Clear password fields after update
    _currentPasswordCtr.clear();
    _newPasswordCtr.clear();
  } on FirebaseAuthException catch (e) {
    // Show error if re-authentication or update fails
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message ?? 'Authentication error')),
    );
  } catch (e) {
    // Show any other errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update profile: $e')),
    );
  } finally {
    // Hide loading spinner
    setState(() {
      _isLoading = false;
    });
  }
}
 
 @override
Widget build(BuildContext context) {
  final theme = Theme.of(context); // Get current theme for styling

  return Scaffold(
    backgroundColor: Colors.grey[100], // Set light grey background for the whole page

    appBar: AppBar(
      backgroundColor: Colors.white, // White background for app bar
      elevation: 0, // No shadow below app bar
      centerTitle: true, // Center the title horizontally

      leading: GestureDetector(
        onTap: () {
          // When back button tapped
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const BottomNav()), // Go to BottomNav page
            (route) => false, // Remove all previous routes
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Add padding around icon
          child: CircleAvatar(
            backgroundColor: Colors.white, // White circle behind icon
            child: Icon(Icons.arrow_back, color: Color(0xffef2b39)), // Back arrow icon with custom color
          ),
        ),
      ),

      title: Row(
        mainAxisSize: MainAxisSize.min, // Make row just wide enough for content
        children: [
          Icon(Icons.person_outline, color: Colors.redAccent, size: 28), // Person icon in red color
          const SizedBox(width: 8), // Space between icon and text

          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [Colors.redAccent, Colors.deepOrangeAccent], // Gradient colors
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),

            child: Text(
              'Your Profile', // Text shown in app bar
              style: theme.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold, // Bold font
                fontSize: 26, // Font size 26
                color: Colors.white, // Text color (ignored because of ShaderMask)
                shadows: [
                  Shadow(
                    blurRadius: 5, // Soft shadow blur
                    color: Colors.black.withOpacity(0.2), // Shadow color with some transparency
                    offset: const Offset(2, 2), // Shadow offset down-right
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),

    // Main body of the page
    body: _isLoading
        ? const Center(child: CircularProgressIndicator()) // Show loading spinner if loading
        : SingleChildScrollView(
            // Make content scrollable vertically if needed
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24), // Add padding inside scroll area
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Rounded corners on card
              elevation: 5, // Shadow depth

              child: Padding(
                padding: const EdgeInsets.all(24), // Padding inside the card
                child: Form(
                  key: _formKey, // Assign form key for validation
                  child: Column(
                    children: [
                      _buildProfileImage(), // Show user profile image and upload button

                      const SizedBox(height: 24), // Vertical space

                      // Full name input field with validation
                      _buildTextFormField(_nameCtr, 'Full Name', validator: (val) {
                        if (val == null || val.trim().length < 3) {
                          return 'Please enter a valid name'; // Show error if name too short
                        }
                        return null; // No error
                      }),

                      const SizedBox(height: 16), // Space between fields

                      // Email input field with validation
                      _buildTextFormField(_emailCtr, 'Email Address',
                          keyboardType: TextInputType.emailAddress, validator: (val) {
                        if (val == null || !val.contains('@') || val.trim().isEmpty) {
                          return 'Enter a valid email'; // Show error if email invalid
                        }
                        return null; // No error
                      }),

                      const SizedBox(height: 16),

                      // Address input field with validation
                      _buildTextFormField(_addressCtr, 'Address', validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Address cannot be empty'; // Show error if empty
                        }
                        return null;
                      }),

                      const SizedBox(height: 16),

                      // Current password input field (needed when changing email or password)
                      _buildTextFormField(
                        _currentPasswordCtr,
                        'Current Password (required for email/password update)',
                        obscureText: true, // Hide input for password
                        validator: (val) {
                          // If new password entered or email changed, current password is required
                          if ((_newPasswordCtr.text.isNotEmpty ||
                                  _emailCtr.text.trim() != currentUser?.email) &&
                              (val == null || val.isEmpty)) {
                            return 'Enter your current password to update';
                          }
                          return null; // No error
                        },
                      ),

                      const SizedBox(height: 16),

                      // New password input field (optional)
                      _buildTextFormField(
                        _newPasswordCtr,
                        'New Password (leave blank if no change)',
                        obscureText: true,
                        validator: (val) {
                          if (val != null && val.isNotEmpty && val.length < 6) {
                            return 'Password should be at least 6 characters'; // Error if password too short
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      // Save changes button (fills full width)
                      SizedBox(
                        width: double.infinity, // Make button full width
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent, // Button color
                            padding: const EdgeInsets.symmetric(vertical: 14), // Vertical padding inside button
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Rounded corners
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          onPressed: saveProfileInfo, // Call function to save changes when tapped
                          child: const Text('Save Changes'), // Button label
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Logout button (outlined style, full width)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut(); // Sign out user

                            // Navigate to login screen and clear all previous routes
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LogIn(showLogoutMessage: true),
                              ),
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.logout, color: Colors.redAccent), // Logout icon
                          label: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.redAccent), // Outline border color
                            padding: const EdgeInsets.symmetric(vertical: 14), // Button padding
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Rounded corners
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
  );
}

 
 Widget _buildProfileImage() {
  return Stack(  // Use Stack to place camera icon on top of profile picture
    children: [
      CircleAvatar(
        radius: 60, // Circle size
        backgroundColor: Colors.grey.shade300, // Light grey background if no image
        backgroundImage: _pickedImageFile != null
            ? FileImage(_pickedImageFile!) // Show picked image from device if available
            : (profilePhotoUrl.isNotEmpty
                ? NetworkImage(profilePhotoUrl) // Else show image from URL if available
                : null), // No image if none picked or url empty

        // Show first letter of name if no image
        child: profilePhotoUrl.isEmpty && _pickedImageFile == null
            ? Text(
                _nameCtr.text.isNotEmpty ? _nameCtr.text[0].toUpperCase() : '', // First letter uppercase
                style: const TextStyle(fontSize: 48, color: Colors.white), // Big white letter
              )
            : null, // No child if image is shown
      ),

      // Camera icon positioned at bottom right of avatar
      Positioned(
        bottom: 0,
        right: 0,
        child: InkWell(
          onTap: _pickImage, // Call function to pick image when tapped
          borderRadius: BorderRadius.circular(30), // Circular tap area
          child: CircleAvatar(
            radius: 20, // Smaller circle for icon
            backgroundColor: Colors.redAccent, // Red background
            child: const Icon(Icons.camera_alt_outlined, color: Colors.white), // Camera icon in white
          ),
        ),
      ),
    ],
  );
}

Widget _buildTextFormField(
    TextEditingController controller,
    String label, {
    bool obscureText = false, // Hide input for passwords
    TextInputType keyboardType = TextInputType.text, // Default keyboard type
    String? Function(String?)? validator, // Validation function for input
  }) {
  return TextFormField(
    controller: controller, // Control input value
    obscureText: obscureText, // Hide text if password
    keyboardType: keyboardType, // Set keyboard type (email, text, etc)
    validator: validator, // Set validator to check input

    decoration: InputDecoration(
      labelText: label, // Show label above input
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), // Rounded border
      filled: true, // Fill background color inside input
      fillColor: Colors.white, // White fill color
    ),
  );
  } 
}
