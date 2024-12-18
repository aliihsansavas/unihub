import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthServiceSignup {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isPasswordStrong(String password) {
    return password.length >= 8 &&
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String birthDate,
    required String gender,
    required List<String> interests,
    File? profilePic,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? profilePicUrl;
      if (profilePic != null) {
        profilePicUrl = profilePic.path;
      }

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'birthDate': birthDate,
        'gender': gender,
        'interests': interests,
        'profilePic': profilePicUrl ?? '',
      });

      await userCredential.user!.sendEmailVerification();
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
                  'Kullanıcı kaydı başarılı\nLütfen e-posta adresinizi doğrulayınız!',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(12),
        ),
      );
      Navigator.pushReplacementNamed(context, '/emailVerification');

    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Bu e-posta zaten kayıtlı!';
      } else if (e.code == 'network-request-failed') {
        errorMessage = 'Ağ bağlantısı hatası. Lütfen internetinizi kontrol edin.';
      } else {
        errorMessage = 'Bir hata oluştu: ${e.message}';
      }
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
                  errorMessage,
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(12),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $e')),
      );
    }
  }
}

class AuthServiceLogin {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('users')
          .where("email", isEqualTo: email)
          .get();

      if (query.docs.isNotEmpty) {
        await _auth.sendPasswordResetEmail(email: email);
      } else {
        throw 'Bu e-posta adresi ile kayıtlı bir kullanıcı bulunamadı.';
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        throw 'Ağ hatası, lütfen internet bağlantınızı kontrol edin!';
      } else {
        throw 'Bir hata oluştu: ${e.message}';
      }
    }
  }

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı!';
      case 'wrong-password':
        return 'Şifreniz yanlış. Lütfen tekrar deneyin!';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi. Lütfen doğru formatta bir e-posta giriniz!';
      case 'too-many-requests':
        return 'Çok fazla deneme yaptınız. Lütfen biraz bekleyin.';
      case 'network-request-failed':
        return 'Ağ hatası oluştu. İnternet bağlantınızı kontrol edin!';
      default:
        return 'Geçersiz e-posta adresi veya şifre girdiniz!';
    }
  }
}