import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'utils/api_service.dart';
import 'views/viewchat.dart';
import 'views/view_taskdetails.dart';
import 'views/viewprofile.dart';
import 'views/login_screen.dart';
import 'views/signup_screen.dart';
import 'utils/session_manager.dart';

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

  final List<String> _titles = [
    "Chat",
    "Task Details",
    "Profile",
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  void _fetchUserDetails() async {
    try {
      final userdetails = await _apiService.getUserProfile();

      // Update state with user details
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
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userName == null) {
      // Show a loading indicator while fetching user details
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final height = MediaQuery.of(context).size.height;
    final List<Widget> _screens = [
      ChatScreen(taskData: [], userName: _userName ?? 'Unknown User Name'),
      TaskDetailsScreen(username: _userName ?? 'Unknown User'),
      ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: _screens[_currentIndex],
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: height * 0.1,
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavBarItem(icon: Icons.chat, index: 0),
                _buildNavBarItem(icon: Icons.list, index: 1),
                _buildNavBarItem(icon: Icons.person, index: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBarItem({required IconData icon, required int index}) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
        alignment: Alignment.center,
        transform: isSelected
            ? Matrix4.translationValues(0, -30, 0)
            : Matrix4.identity(),
        width: isSelected ? 60 : 40,
        height: isSelected ? 60 : 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.black : Colors.transparent,
          border: isSelected
              ? Border.all(
                  color: const Color.fromARGB(255, 243, 230, 178), width: 4)
              : null,
        ),
        child: Icon(
          icon,
          size: isSelected ? 30 : 28,
          color: isSelected ? const Color(0xFFFFCD03) : const Color(0xFF888888),
        ),
      ),
    );
  }
}
