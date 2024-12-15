import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
class WelcomePage extends StatefulWidget {
  final Function(bool) onThemeToggle;

  WelcomePage({required this.onThemeToggle});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _borderWidthAnimation;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: const Color(0xFF42A5F5),
      end: const Color(0xFFCE93D8),
    ).animate(_controller);

    _borderWidthAnimation = Tween<double>(
      begin: 5,
      end: 10,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(120),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _colorAnimation.value!,
                          width: _borderWidthAnimation.value,
                        ),
                        borderRadius: BorderRadius.circular(120),
                      ),
                      child: _isDarkMode ? Image.asset(
                        'assets/dark_mode.png',
                        height: 250.0,
                        width: 250.0,
                        fit: BoxFit.cover,
                      ) : Image.asset(
                        'assets/light_mode.png',
                        height: 250.0,
                        width: 250.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
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
                        color: _isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF212121),
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
                            color: const Color(0xFF1E88E5)
                          ),
                          speed: const Duration(milliseconds: 300),
                          cursor: '',
                        ),
                        TypewriterAnimatedText(
                          "on",
                          textStyle: TextStyle(
                            fontSize: 40.0,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFCE93D8)
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
                        color: _isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF212121),
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
                  color: _isDarkMode ? const Color(0xFFBDBDBD) : const Color(0xFF616161),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Text('Giriş Yap'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                  textStyle: TextStyle(fontSize: 18),
                  backgroundColor: _isDarkMode ? const Color(0xFF1E88E5) : const Color(0xFF42A5F5),
                  foregroundColor: _isDarkMode ? const Color(0xFFFFFFFF) :  const Color(0xFF212121),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 15,
                  shadowColor: _isDarkMode ? const Color(0xFF1E88E5) : const Color(0xFF42A5F5),
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
                  backgroundColor: _isDarkMode ? const Color(0xFF7B1FA2) : const Color(0xFFCE93D8),
                  foregroundColor: _isDarkMode ? const Color(0xFFFFFFFF) :  const Color(0xFF212121),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 15,
                  shadowColor: _isDarkMode ? const Color(0xFF7B1FA2) : const Color(0xFFCE93D8),
                ),
              ),
            ],
          ),
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(10),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isDarkMode = !_isDarkMode;
                  });
                  widget.onThemeToggle(_isDarkMode);
                },
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: _isDarkMode ? const Color(0xFF42A5F5) : const Color(0xFFCE93D8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tema Rengi:",
                        style: TextStyle(
                          fontSize: 18.0,
                          color: _isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF212121),
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 35,
                        decoration: BoxDecoration(
                          color: _isDarkMode ? Colors.amber : Colors.grey,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Align(
                            alignment: _isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
                            child: Icon(
                              _isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                              color: _isDarkMode ? Colors.white : Colors.yellow,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}