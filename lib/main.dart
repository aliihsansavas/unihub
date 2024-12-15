import 'package:flutter/material.dart';
import 'pages/welcome_page.dart';
import 'pages/sign_up_page.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/communities_page.dart';
import 'pages/community_details_page.dart';
import 'pages/events_page.dart';
import 'pages/profile_page.dart';
import 'pages/settings_page.dart';
import 'pages/create_community_page.dart';
import 'pages/community_management_page.dart';
import 'pages/help_support_page.dart';
import 'pages/admin_panel.dart';

void main() {
  runApp(UniHubApp());
}

class UniHubApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UniHub',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/adminPanel',
      routes: {
        '/welcome': (context) => WelcomePage(),
        '/signup': (context) => SignUpPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/communities': (context) => CommunitiesPage(),
        '/communityDetails': (context) => CommunityDetailsPage(),
        '/events': (context) => EventsPage(),
        '/profile': (context) => ProfilePage(),
        '/settings': (context) => SettingsPage(),
        '/createCommunity': (context) => CreateCommunityPage(),
        '/manageCommunity': (context) => CommunityManagementPage(),
        '/helpSupport': (context) => HelpSupportPage(),
        '/adminPanel': (context) => AdminPanel(),
      },
    );
  }
}