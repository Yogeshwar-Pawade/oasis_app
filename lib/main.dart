import 'dart:ui'; // Required for BackdropFilter
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'utils/api_service.dart';
import './views/Oasis/chats.dart';
import './views/Flash/tasks.dart';
import 'views/login_screen.dart';
import 'views/signup_screen.dart';
import 'utils/session_manager.dart';
import '/conf/theme.dart';
import 'conf/frostedglass.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isLoggedIn = await SessionManager().isLoggedIn();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Management App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: isLoggedIn ? MainScreen() : LoginScreen(),
      routes: {
        '/signup': (context) => SignupScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final _apiService = ApiService();
  String? _userName;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  void _fetchUserDetails() async {
    try {
      final userdetails = await _apiService.getUserProfile();
      setState(() {
        _userName = userdetails['name'] ?? 'Unknown User';
        _userEmail = userdetails['email'] ?? 'No Email Provided';
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
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userName == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> _screens = [
      ChatScreen(taskData: [], userName: _userName ?? 'Unknown User Name'),
      TaskDetailsScreen(username: _userName ?? 'Unknown User'),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _screens[_currentIndex],
      bottomNavigationBar: Glassmorphism(
        blur: 80.0,
        opacity: 0.4,
        radius: 30.0, // Rounded corners
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical:
                MediaQuery.of(context).size.height * 0.015, // Reduced padding
          ),
          height: MediaQuery.of(context).size.height * 0.1, // Reduced height
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNavBarButton(
                label: "Oasis",
                index: 0,
                context: context,
              ),
              SizedBox(
                width:
                    MediaQuery.of(context).size.width * 0.06, // Reduced spacing
              ),
              _buildNavBarButton(
                label: "Flash",
                index: 1,
                context: context,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavBarButton({
    required String label,
    required int index,
    required BuildContext context,
  }) {
    final isSelected = _currentIndex == index;

    final double buttonWidth =
        MediaQuery.of(context).size.width * (isSelected ? 0.40 : 0.25);
    final double buttonheight =
        MediaQuery.of(context).size.height * (isSelected ? 0.08 : 0.06);

    return AnimatedContainer(
      duration: Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      width: buttonWidth,
      height: buttonheight,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.002,
            horizontal: MediaQuery.of(context).size.width * 0.02,
          ),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.01,
          ),
          decoration: BoxDecoration(
              border:
                  Border.all(width: 1, color: Colors.white.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(18),
              color: isSelected
                  ? darkPrimaryColor // Solid primary color for selected button
                  // : const Color.fromARGB(255, 58, 58, 58), // Solid light gray for unselected button
                  : Colors.transparent),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white, // Text color
                fontSize: isSelected ? 16 : 14, // Font size
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
