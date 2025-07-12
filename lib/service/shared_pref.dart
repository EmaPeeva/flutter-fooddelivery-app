import 'package:shared_preferences/shared_preferences.dart'; 

class SharedpreferenceHelper {
  // Keys used to store data in SharedPreferences
  static String userIdKey = "USERKEY";
  static String userNameKey = "USERNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";
  static String userImagekey = "USERIMAGEKEY";
  static String userAddresskey = "USERADDRESSKEY";

  // Function to save user ID locally
  Future<bool> saveUserId(String getUserId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();  // Get SharedPreferences instance
    return prefs.setString(userIdKey, getUserId);                    // Save userId with key userIdKey
  }

  // Function to save user name locally
  Future<bool> saveUserName(String getUserName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();  // Get SharedPreferences instance
    return prefs.setString(userNameKey, getUserName);                // Save userName with key userNameKey
  }

  // Function to save user email locally
  Future<bool> saveUserEmail(String getUserEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();  // Get SharedPreferences instance
    return prefs.setString(userEmailKey, getUserEmail);              // Save userEmail with key userEmailKey
  }

  // Function to save user address locally
  Future<bool> saveUserAddress(String getUserAddress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();  // Get SharedPreferences instance
    return prefs.setString(userAddresskey, getUserAddress);          // Save userAddress with key userAddresskey
  }

  // Function to save user image URL or path locally
  Future<bool> saveUserImage(String getUserImage) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();  // Get SharedPreferences instance
    return prefs.setString(userImagekey, getUserImage);              // Save userImage with key userImagekey
  }

  // Function to retrieve user ID from local storage
  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();  // Get SharedPreferences instance
    return prefs.getString(userIdKey);                               // Return stored userId or null if not found
  }

  // Function to retrieve user name from local storage
  Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();  // Get SharedPreferences instance
    return prefs.getString(userNameKey);                             // Return stored userName or null if not found
  }

  // Function to retrieve user email from local storage
  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();  // Get SharedPreferences instance
    return prefs.getString(userEmailKey);                            // Return stored userEmail or null if not found
  }

  // Function to retrieve user address from local storage
  Future<String?> getUserAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();  // Get SharedPreferences instance
    return prefs.getString(userAddresskey);                          // Return stored userAddress or null if not found
  }

  // Function to retrieve user image from local storage
  Future<String?> getUserImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();  // Get SharedPreferences instance
    return prefs.getString(userImagekey);                            // Return stored userImage or null if not found
  }
}
 