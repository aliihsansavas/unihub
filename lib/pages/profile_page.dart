import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';


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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isDarkMode = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(widget.userId).get();

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
      print('Hata: $e');
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _saveImagePath();
    }
  }

  Future<void> _saveImagePath() async {
    if (_image == null) return;

    try {
      String profilePicUrl = _image!.path;

      await _firestore.collection('users').doc(widget.userId).set({
        'profilePic': profilePicUrl,
      }, SetOptions(merge: true));

      setState(() {
        userData!['profilePic'] = profilePicUrl;
      });
    } catch (e) {
      print('Fotoğraf yolunu kaydederken hata: $e');
      setState(() {
        errorMessage = 'Fotoğraf yolunu kaydederken hata oluştu: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil Sayfası", style: TextStyle(fontFamily: 'Roboto', fontSize: 24)),
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : userData == null
              ? Center(child: Text(errorMessage ?? 'Veriler alınırken bir sorun oluştu.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: _isDarkMode ? const Color(0xFF1E88E5) : const Color(0xFF42A5F5),
                              backgroundImage: _image != null
                                  ? FileImage(_image!)
                                  : userData!['profilePic'] != null && userData!['profilePic'].isNotEmpty
                                      ? FileImage(File(userData!['profilePic']))
                                      : AssetImage('assets/light_mode.png') as ImageProvider,
                              child: _image == null && userData!['profilePic'] == null
                                  ? Icon(Icons.camera_alt, size: 40, color: Colors.white)
                                  : null,
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        infoCard(Icons.person, 'Ad Soyad: ${userData!['firstName']} ${userData!['lastName']}'),
                        SizedBox(height: 12),
                        infoCard(Icons.transgender, 'Cinsiyet: ${userData!['gender']}'),
                        SizedBox(height: 12),
                        infoCard(Icons.cake, 'Doğum Tarihi: ${userData!['birthDate']}'),
                        SizedBox(height: 12),
                        infoCard(Icons.email, 'E-mail: ${userData!['email']}'),
                        SizedBox(height: 12),
                        infoCard(Icons.interests, 'İlgi Alanları: ${userData!['interests'].join(', ')}'),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileUpdatePage(userId: widget.userId),
                              ),
                            );
                          },
                          child: Text('Profil Güncelle', style: TextStyle(fontSize: 18)),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/createCommunity');
                            // Topluluk oluşturma işlemi
                          },
                          child: Text('Topluluk Oluştur', style: TextStyle(fontSize: 18)),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget infoCard(IconData icon, String text) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: _isDarkMode ? const Color(0xFF1E88E5) : const Color(0xFF42A5F5)),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileUpdatePage extends StatefulWidget {
  final String userId;

  ProfileUpdatePage({required this.userId});

  @override
  _ProfileUpdatePageState createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;

  // Controller'lar tanımlandı
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _genderController = TextEditingController();
  TextEditingController _birthDateController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _interestsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(widget.userId).get();
      if (userSnapshot.exists) {
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _firstNameController.text = userData['firstName'] ?? '';
          _lastNameController.text = userData['lastName'] ?? '';
          _genderController.text = userData['gender'] ?? '';
          _birthDateController.text = userData['birthDate'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _interestsController.text = (userData['interests'] as List<dynamic>?)?.join(', ') ?? '';
        });
      }
    } catch (e) {
      print('Kullanıcı verileri alınırken hata oluştu: $e');
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firestore.collection('users').doc(widget.userId).update({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'gender': _genderController.text,
          'birthDate': _birthDateController.text,
          'email': _emailController.text,
          'interests': _interestsController.text.split(',').map((e) => e.trim()).toList(),
        });
        Navigator.pop(context);
      } catch (e) {
        print('Profil güncellenirken hata oluştu: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profil Güncelle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: 'Ad'),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: 'Soyad'),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _genderController,
                  decoration: InputDecoration(labelText: 'Cinsiyet'),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _birthDateController,
                  decoration: InputDecoration(labelText: 'Doğum Tarihi'),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'E-mail'),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _interestsController,
                  decoration: InputDecoration(labelText: 'İlgi Alanları (Virgülle ayırın)'),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _updateProfile,
                  child: Text('Profili Güncelle'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
