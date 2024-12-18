import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class EmailVerification extends StatefulWidget {
  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerification> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isEmailVerified = false;
  bool isVerificationInProgress = false;
  int countdown = 60;
  Timer? _timer;
  Timer? _verificationTimer;
  bool _isDarkMode = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;
  }

  @override
  void initState() {
    super.initState();
    startVerificationCheck();
  }

  void startVerificationCheck() {
    _verificationTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      checkEmailVerification();
    });
  }

  Future<void> checkEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      if (user.emailVerified) {
        setState(() {
          isEmailVerified = true;
        });
        _verificationTimer?.cancel();
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, '/login');
        });
      }
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified && !isVerificationInProgress) {
        setState(() {
          isVerificationInProgress = true;
          countdown = 60;
        });
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Doğrulama e-postası yeniden gönderildi!',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        startCountdown();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Doğrulama e-postası gönderilemedi!\nLütfen daha sonra tekrar deneyin.',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      startCountdown();
    }
  }

  void startCountdown() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() {
          countdown--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          isVerificationInProgress = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _verificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("E-posta Doğrulama")),
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              isEmailVerified
                  ? 'E-posta adresiniz doğrulandı!\nGiriş sayfasına yönlendiriliyorsunuz...'
                  : 'E-posta adresiniz doğrulanmadı.\nLütfen e-posta adresinizi doğrulayın!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: isEmailVerified ? const Color.fromARGB(255, 36, 141, 39) : const Color.fromARGB(255, 198, 52, 42),
              ),
            ),
            SizedBox(height: 20),
            if (!isEmailVerified)
              ElevatedButton(
                onPressed: isVerificationInProgress ? null : resendVerificationEmail,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  textStyle: TextStyle(fontSize: 18),
                  backgroundColor: _isDarkMode ? const Color(0xFF7B1FA2) : const Color(0xFFCE93D8),
                  foregroundColor: _isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF212121),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 15,
                  shadowColor: _isDarkMode ? const Color(0xFF7B1FA2) : const Color(0xFFCE93D8),
                ),
                child: Text(isVerificationInProgress
                    ? 'Lütfen bekleyin... (${countdown}s)'
                    : 'Doğrulama linkini yeniden gönder'),
              ),
          ],
        ),
      ),
    );
  }
}