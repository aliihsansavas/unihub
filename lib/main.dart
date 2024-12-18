import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth importu
import 'pages/welcome_page.dart';
import 'pages/sign_up_page.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/communities_page.dart';
import 'pages/community_details_page.dart';
import 'pages/events_page.dart';  // EventsPage importu
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';
import 'pages/create_community_page.dart';
import 'pages/community_management_page.dart';
import 'pages/help_support_page.dart';
import 'pages/admin_panel.dart';
import 'pages/email_verification_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(UniHubApp());
}

class UniHubApp extends StatefulWidget {
  @override
  _UniHubAppState createState() => _UniHubAppState();
}

class _UniHubAppState extends State<UniHubApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  void _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _toggleTheme(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode);
    
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UniHub',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
<<<<<<< HEAD
      initialRoute: '/adminPanel',

=======
      initialRoute: '/splash',
>>>>>>> fd2e47841017a6e8516874d7da8054eaf98ff679
      routes: {
        '/splash': (context) => SplashScreen(onThemeToggle: _toggleTheme),
        '/welcome': (context) => WelcomePage(onThemeToggle: _toggleTheme),
        '/signup': (context) => SignUpPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/communities': (context) => CommunitiesPage(),
        '/communityDetails': (context) => CommunityDetailsPage(),
        '/events': (context) => EventsPage(),
        '/profile': (context) {
          User? currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            return ProfilePage(userId: currentUser.uid);
          } else {
            // Kullanıcı oturum açmamış, giriş yapmaya yönlendir
            return WelcomePage(onThemeToggle: _toggleTheme);
          }
        },
        '/settings': (context) => SettingsPage(),
        '/createCommunity': (context) => CreateCommunityPage(),
        '/manageCommunity': (context) => CommunityManagementPage(communityId: 'someCommunityId'),
        '/helpSupport': (context) => HelpSupportPage(),
        '/adminPanel': (context) => AdminPanel(),
        '/emailVerification': (context) => EmailVerification(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  final Function(bool) onThemeToggle;

  const SplashScreen({required this.onThemeToggle});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    User? user = _auth.currentUser;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WelcomePage(onThemeToggle: widget.onThemeToggle),
          ),
        );
      } else if (user.email == 'unihubyonetim@gmail.com') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminPanel(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
