import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  ProfilePage({required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? errorMessage;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // Kullanıcı verilerini Firestore'dan çekme
  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userSnapshot.exists) {
        setState(() {
          userData = userSnapshot.data() as Map<String, dynamic>;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Kullanıcı bulunamadı';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Veri alınırken hata oluştu: $e';
        isLoading = false;
      });
    }
  }

  // Fotoğraf seçme işlemi
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _uploadImageToStorage();
    }
  }

  // Fotoğrafı Firebase Storage'a yükleme ve URL'sini Firestore'a kaydetme
  Future<void> _uploadImageToStorage() async {
    if (_image == null) return;

    try {
      final storageRef = FirebaseStorage.instance.ref().child('profile_pics/${widget.userId}.jpg');
      await storageRef.putFile(_image!);
      final imageUrl = await storageRef.getDownloadURL();

      // Fotoğraf URL'sini Firestore'da güncelleme
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'profilePicture': imageUrl,
      });

      setState(() {
        userData!['profilePicture'] = imageUrl;
      });
    } catch (e) {
      print('Fotoğraf yüklenirken hata: $e');
      setState(() {
        errorMessage = 'Fotoğraf yüklenirken hata oluştu: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profil")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userData == null
              ? Center(child: Text(errorMessage ?? 'Veriler alınırken bir sorun oluştu.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: userData!['profilePicture'] != null
                              ? NetworkImage(userData!['profilePicture'])
                              : AssetImage('assets/default_avatar.png') as ImageProvider,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text('Ad Soyad: ${userData!['fullName']}'),
                      Text('E-mail: ${userData!['email']}'),
                      Text('Cinsiyet: ${userData!['gender']}'),
                      Text('Doğum Tarihi: ${userData!['birthdate']}'),
                      Text('İlgi Alanları: ${userData!['interests']}'),
                    ],
                  ),
                ),
    );
  }
}
