import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 225, 190, 231),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(120),
              child: Image.asset(
                'assets/logo.png',
                height: 250.0,
                width: 250.0,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 40),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Uni",
                    style: TextStyle(
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 66, 66, 66),
                    ),
                  ),
                  AnimatedTextKit(
                    repeatForever: true,
                    isRepeatingAnimation: true,
                    animatedTexts: [
                      TypewriterAnimatedText(
                        "versity",
                        textStyle: TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 33, 150, 243),
                        ),
                        speed: const Duration(milliseconds: 300),
                        cursor: '',
                      ),
                      TypewriterAnimatedText(
                        "on",
                        textStyle: TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 156, 39, 176),
                        ),
                        speed: const Duration(milliseconds: 300),
                        cursor: '',
                      ),
                    ],
                  ),
                  Text(
                    "Hub",
                    style: TextStyle(
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 66, 66, 66),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Etkinliklere katıl, ilgi alanlarına uygun toplulukları keşfet!",
              style: TextStyle(
                fontSize: 18.0,
                fontStyle: FontStyle.italic,
                color: const Color.fromARGB(255, 66, 66, 66),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 60),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text('Giriş Yap'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                textStyle: TextStyle(fontSize: 18),
                backgroundColor: const Color.fromARGB(255, 33, 150, 243),
                foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 20,
                shadowColor: const Color.fromARGB(255, 33, 150, 243), // Gölge rengi
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: Text('Kayıt Ol'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                textStyle: TextStyle(fontSize: 18),
                backgroundColor: const Color.fromARGB(255, 156, 39, 176),
                foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 20,
                shadowColor: const Color.fromARGB(255, 156, 39, 176),
              ),
            ),
          ],
        ),
      ),
    );
  }
}