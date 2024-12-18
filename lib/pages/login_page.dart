import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unihub/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  bool _isDarkMode = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;
  }

  final AuthServiceLogin _authService = AuthServiceLogin();

  Future<void> _login() async {
    setState(() {
      _errorMessage = null;
    });
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim().toLowerCase();

    if (!email.endsWith('@trakya.edu.tr') && email != 'unihubyonetim@gmail.com') {
      setState(() {
        _errorMessage = 'Geçerli bir okul mail adresi giriniz.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = await _authService.signInWithEmailPassword(
          email, _passwordController.text);

      if (user != null) {
        await user.reload();
        if (!user.emailVerified) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Lütfen e-posta adresinizi doğrulayınız!',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(12),
            ),
          );
          Navigator.pushReplacementNamed(context, '/emailVerification');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Giriş Başarılı',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(12),
            ),
          );
          if (email == 'unihubyonetim@gmail.com') {
            Navigator.pushNamedAndRemoveUntil(context, '/adminPanel', (route) => false);
          } else {
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          }
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetPassword() async {
    setState(() {
      _errorMessage = null;
    });
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Lütfen geçerli bir e-posta adresi girin.';
      });
      return;
    }

    try {
      await _authService.resetPassword(email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.email,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Text(
                'Şifre sıfırlama e-postası gönderildi!',
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(12),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Giriş Yap")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  "Hoş Geldiniz!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "E-posta",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'E-posta adresi giriniz';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Şifre",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Şifre giriniz';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  )
                else
                  SizedBox.shrink(),
                SizedBox(height: 20),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          textStyle: TextStyle(fontSize: 18),
                          backgroundColor: _isDarkMode ? const Color(0xFF1E88E5) : const Color(0xFF42A5F5),
                          foregroundColor: _isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF212121),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 15,
                          shadowColor: _isDarkMode ? const Color(0xFF1E88E5) : const Color(0xFF42A5F5),
                        ),
                        child: Text("Giriş Yap"),
                      ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E88E5)
                  ),
                  child: Text("Hesabınız yok mu? Kayıt olun"),
                ),
                TextButton(
                  onPressed: _resetPassword,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E88E5)
                  ),
                  child: Text("Şifre sıfırlama linki gönder"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}