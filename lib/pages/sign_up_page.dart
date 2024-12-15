import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _genderController = TextEditingController();
  final _interestsController = TextEditingController();
  
  File? _imageFile;  // Profil fotoğrafı için dosya
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Profil fotoğrafı seçimi
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Kayıt işlemi
  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        // E-posta kontrolü
        if (!_emailController.text.endsWith('@trakya.edu.tr')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('E-posta adresi @trakya.edu.tr uzantılı olmalıdır!'))
          );
          return;
        }

        // Kullanıcıyı Firebase Authentication ile kaydetme
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Kullanıcı verilerini Firestore'a kaydetme
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'birthDate': _birthDateController.text,
          'gender': _genderController.text,
          'interests': _interestsController.text,
          'email': _emailController.text,
          'profilePic': _imageFile != null ? _imageFile!.path : '',  // Fotoğraf isteğe bağlı
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kullanıcı başarıyla kaydedildi!'))
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${e.message}'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kayıt Ol")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Ad ve Soyad
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'Ad'),
                validator: (value) => value!.isEmpty ? 'Adınızı girin' : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Soyad'),
                validator: (value) => value!.isEmpty ? 'Soyadınızı girin' : null,
              ),
              // Doğum Tarihi
              TextFormField(
                controller: _birthDateController,
                decoration: InputDecoration(labelText: 'Doğum Tarihi'),
                validator: (value) => value!.isEmpty ? 'Doğum tarihinizi girin' : null,
              ),
              // Cinsiyet
              TextFormField(
                controller: _genderController,
                decoration: InputDecoration(labelText: 'Cinsiyet'),
                validator: (value) => value!.isEmpty ? 'Cinsiyetinizi girin' : null,
              ),
              // İlgi Alanları
              TextFormField(
                controller: _interestsController,
                decoration: InputDecoration(labelText: 'İlgi Alanlarınız'),
                validator: (value) => value!.isEmpty ? 'İlgi alanlarınızı girin' : null,
              ),
              // E-posta
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'E-posta'),
                validator: (value) => value!.isEmpty || !value.contains('@') ? 'Geçerli bir e-posta girin' : null,
              ),
              // Şifre
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Şifre'),
                validator: (value) => value!.isEmpty ? 'Şifrenizi girin' : null,
              ),
              // Profil Fotoğrafı Seçme
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                      : null,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
                child: Text('Kayıt Ol'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
