import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unihub/pages/login_page.dart'; // LoginPage sayfanızın import edilmesi gerekecek

class HomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _signOut(BuildContext context) async {
    await _auth.signOut(); // Firebase çıkış işlemi
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(), // Çıkış yaptıktan sonra LoginPage'e yönlendir
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Sayfası"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Home Page"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _signOut(context), // Çıkış butonuna tıklayınca çıkış yapar
              child: Text("Çıkış Yap"),
            ),
          ],
        ),
      ),
    );
  }
}
