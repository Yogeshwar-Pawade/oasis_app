import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'utils/api_service.dart';
import 'views/oasis/viewchat.dart';
import 'views/flash/view_taskdetails.dart';
import 'views/flash/viewprofile.dart';
import 'views/login_screen.dart';
import 'views/signup_screen.dart';
import 'utils/session_manager.dart';
import 'conf/theme.dart'; // Import the theme file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isLoggedIn = await SessionManager().isLoggedIn();
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});

  // Global theme notifier
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, child) {
        return MaterialApp(
          title: 'Task Management App',
          theme: lightTheme, // Light theme
          darkTheme: darkTheme, // Dark theme
          themeMode: currentTheme, // Use the current theme
          home: isLoggedIn ? MainScreen() : LoginScreen(),
          routes: {
            '/signup': (context) => SignupScreen(),
          },
        );
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
    }
  }

  Widget build(BuildContext context) {
    if (_userName == null) {
      // Show a loading indicator while fetching user details
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final height = MediaQuery.of(context).size.height;
    final brightness = Theme.of(context).brightness; // Defined brightness here
    final Color navBarColor =
        brightness == Brightness.dark ? darkPrimaryColor : lightPrimaryColor;
    final Color navBarTextColor =
        brightness == Brightness.dark ? darkTextColor : lightTextColor;

    final List<Widget> _screens = [
      ChatScreen(taskData: [], userName: _userName ?? 'Unknown User Name'),
      ProfileScreen(),
    ];

    return Container(
      decoration: getGradientBackground(brightness),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _screens[_currentIndex],
        bottomNavigationBar: Container(
          color: navBarColor, // Dynamic background color
          padding: EdgeInsets.symmetric(
            vertical: height * 0.015,
          ),
          height: height * 0.1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNavBarButton(
                label: "Oasis",
                index: 0,
                icon: Icons.chat, // Chat icon for Oasis
                context: context,
                textColor: navBarTextColor,
                brightness: brightness, // Pass brightness here
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.06,
              ),
              _buildNavBarButton(
                label: "Flash",
                index: 1,
                icon: Icons.bolt, // Lightning icon for Flash
                context: context,
                textColor: navBarTextColor,
                brightness: brightness, // Pass brightness here
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
  required IconData icon,
  required BuildContext context,
  required Color textColor,
  required Brightness brightness, // Accept brightness as a parameter
}) {
  final isSelected = _currentIndex == index;
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  final double buttonWidth = screenWidth * (isSelected ? 0.40 : 0.25);
  final double buttonHeight = screenHeight * (isSelected ? 0.08 : 0.06);

  return AnimatedContainer(
    duration: Duration(milliseconds: 100),
    curve: Curves.easeInOut,
    width: buttonWidth,
    height: buttonHeight,
    child: GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.002,
          horizontal: screenWidth * 0.02,
        ),
        margin: EdgeInsets.only(
          bottom: screenHeight * 0.01,
        ),
        decoration: BoxDecoration(
          border: isSelected
              ? null // No border when selected
              : Border.all(width: 1, color: textColor.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(18),
          color: isSelected
              ? (brightness == Brightness.dark
                  ? Color.fromARGB(255, 19, 20, 21) // Dark mode selected
                  : Color.fromARGB(255, 243, 242, 242)) // Light mode selected
              : (brightness == Brightness.dark
                  ? Colors.black // Dark mode not selected
                  : Colors.transparent), // Light mode not selected
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? textColor // White text for selected
                  : Colors.grey, // Grey text for not selected
              size: screenHeight * 0.025,
            ),
            if (isSelected) ...[
              SizedBox(width: screenWidth * 0.02),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize:
                      isSelected ? screenHeight * 0.02 : screenHeight * 0.018,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
}