import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../models/user_profile.dart';
import '../../utils/api_service.dart';
import '../../utils/db_helper.dart';
import '../../utils/session_manager.dart';
import '../login_screen.dart';
import '../../main.dart'; // Import for themeNotifier

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DBHelper _dbHelper = DBHelper();
  final _apiService = ApiService();
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
    final textColor =
        Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
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
                          color: Theme.of(context).primaryColor,
                          child: Center(
                            child: Text(
                              'OASIS',
                              style: TextStyle(
                                color: textColor,
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
                                color: Theme.of(context).primaryColor,
                                width: 5,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 75,
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              child: Icon(Icons.person,
                                  size: 80,
                                  color: Theme.of(context).primaryColor),
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
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Email Section
                  Text(
                    _userProfile?.email ?? 'No Email Provided',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 40),

                  // Theme Toggle
                  ListTile(
                    leading: Icon(
                      MyApp.themeNotifier.value == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: textColor,
                    ),
                    title: Text(
                      MyApp.themeNotifier.value == ThemeMode.dark
                          ? 'Dark Mode'
                          : 'Light Mode',
                      style: TextStyle(color: textColor),
                    ),
                    trailing: Switch(
                      value: MyApp.themeNotifier.value == ThemeMode.dark,
                      onChanged: (value) {
                        setState(() {
                          MyApp.themeNotifier.value =
                              value ? ThemeMode.dark : ThemeMode.light;
                        });
                      },
                    ),
                  ),

                  // Clear Data Option
                  ListTile(
                    leading: Icon(Icons.delete_forever, color: Colors.red),
                    title: Text('Clear Data',
                        style: TextStyle(color: textColor)),
                    onTap: _clearData,
                  ),
                  ListTile(
                    leading: Icon(Icons.lock, color: Colors.red),
                    title: Text('Logout', style: TextStyle(color: textColor)),
                    onTap: _logout,
                  ),
                  SizedBox(height: 50),

                  // About Section
                  Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
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