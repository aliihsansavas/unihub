import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
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

  void _toggleTheme(bool isDarkMode) {
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UniHub',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/communities',  // Etkinlikler sayfası başlangıç sayfası olarak belirlendi
      routes: {
  '/welcome': (context) => WelcomePage(onThemeToggle: _toggleTheme),
  '/signup': (context) => SignUpPage(),
  '/login': (context) => LoginPage(),
  '/home': (context) => HomePage(),
  '/communities': (context) => CommunitiesPage(),
  '/communityDetails': (context) => CommunityDetailsPage(),
  '/events': (context) => EventsPage(),
  '/profile': (context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/communities'));
      return Container();
    } else {
      return ProfilePage(userId: user.uid);
    }
  },
  '/settings': (context) => SettingsPage(),
  '/createCommunity': (context) => CreateCommunityPage(),
  '/helpSupport': (context) => HelpSupportPage(),
  '/adminPanel': (context) => AdminPanel(),
},

    );
  }
}
