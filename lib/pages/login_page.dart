import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
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

  Future<void> _checkEmailVerification(User user) async {
    await user.reload();
    if (!user.emailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lütfen e-posta adresinizi doğrulayınız!',
            style: TextStyle(color: Colors.black),
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
          content: Text(
            'Giriş Başarılı',
            style: TextStyle(color: Colors.black),
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
      Navigator.pushNamedAndRemoveUntil(context, '/home', (Route<dynamic> route) => false);
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();

    if (!email.endsWith('@trakya.edu.tr') && email != 'unihubyonetim@gmail.com') {
      setState(() {
        _errorMessage = 'Geçerli bir @trakya.edu.tr e-posta adresi girin.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text,
      );

      User? user = userCredential.user;
      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Giriş Başarılı',
              style: TextStyle(color: Colors.black),
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
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _handleFirebaseAuthError(e);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Bir hata oluştu. Lütfen tekrar deneyin.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Bu e-posta ile kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Şifreniz yanlış. Lütfen tekrar deneyin.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      default:
        return 'Bir hata oluştu: ${e.message}';
    }
  }

  void _resetPassword() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Lütfen geçerli bir e-posta adresi girin.';
      });
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Şifre sıfırlama e-postası gönderildi!',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          _errorMessage = 'Bu e-posta adresi ile kayıtlı bir kullanıcı bulunamadı.';
        } else {
          _errorMessage = 'Bir hata oluştu: ${e.message}';
        }
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
                  ),
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