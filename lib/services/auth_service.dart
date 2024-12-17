import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService {
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
          content: Text(
            'Kullanıcı kaydı başarılı\nLütfen e-posta adresinizi doğrulayınız!',
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
          content: Text(
            errorMessage,
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $e')),
      );
    }
  }
}