import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/user_profile.dart';
import '../utils/api_service.dart';
import '../utils/db_helper.dart';
import '../utils/session_manager.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DBHelper _dbHelper = DBHelper();
  final _apiService = ApiService();
  bool _isDarkModeEnabled = false; // Tracks the state of the Dark Mode toggle
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  void _fetchUserDetails() async {
    try {
      final userDetails = await _apiService.getUserProfile();

      // Update state with user profile
      setState(() {
        _userProfile = UserProfile.fromMap(userDetails);
        _isLoading = false;
      });
    } catch (e) {
      print("Failed to fetch user details: $e");
      Fluttertoast.showToast(
        msg: 'Failed to fetch user details.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkModeEnabled = value;
    });
  }

  void _clearData() async {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Clear Data'),
          content: Text(
              'Are you sure you want to clear all tasks and chat history?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.blue)),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                await _dbHelper.clearAllTasks();
                await _dbHelper.clearAllChatMessages();
                Navigator.pop(context, true);
                Fluttertoast.showToast(
                  msg: 'All data cleared successfully',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                );
              },
              child: Text('Clear', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    await SessionManager().clearSession();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
    Fluttertoast.showToast(
      msg: 'Logged out successfully',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final containerColor = const Color(0xFF1C1C1E);

    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Top Container with Curved Edges
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipPath(
                        clipper: BottomCurveClipper(),
                        child: Container(
                          height: 280,
                          width: double.infinity,
                          color: containerColor,
                          child: Center(
                            child: Text(
                              'OASIS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Profile Picture Overlapping Container
                      Positioned(
                        bottom: -60,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 5,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 75,
                              backgroundColor: const Color(0xFF1C1C1E),
                              child: Icon(Icons.person,
                                  size: 80, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 100),

                  // User Name
                  Text(
                    _userProfile?.name ?? 'Unknown User',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Email Section
                  Text(
                    _userProfile?.email ?? 'No Email Provided',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 40),

                  // Clear Data Option
                  ListTile(
                    leading: Icon(Icons.delete_forever, color: Colors.red),
                    title: Text('Clear Data',
                        style: TextStyle(color: Colors.white)),
                    onTap: _clearData,
                  ),
                  ListTile(
                    leading: Icon(Icons.lock, color: Colors.red),
                    title:
                        Text('Logout', style: TextStyle(color: Colors.white)),
                    onTap: _logout,
                  ),
                  SizedBox(height: 50),

                  // About Section
                  Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'App Version: 1.0.0\nDeveloped by: Y&D, Inc',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
    );
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
