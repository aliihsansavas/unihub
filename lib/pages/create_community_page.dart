import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class CreateCommunityPage extends StatefulWidget {
  @override
  _CreateCommunityPageState createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<CreateCommunityPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<String> _selectedCategories = [];
  final List<String> _categories = ['Education', 'Technology', 'Sports', 'Music', 'Art', 'Science'];
  List<TextEditingController> _rulesControllers = [TextEditingController()];

  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _addRule() {
    if (_rulesControllers.length < 10) {
      setState(() {
        _rulesControllers.add(TextEditingController());
      });
    }
  }

  Future<void> _saveCommunity(BuildContext context) async {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedCategories.isEmpty ||
        _rulesControllers.every((controller) => controller.text.isEmpty) ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lütfen tüm alanları doldurun ve bir resim seçin.")),
      );
      return;
    }

    // Resim kaydetme işlemi
    final directory = await getApplicationDocumentsDirectory();
    final communityImagesDir = Directory('${directory.path}/communityimages');
    if (!await communityImagesDir.exists()) {
      await communityImagesDir.create(recursive: true);
    }

    String imageName = basename(_image!.path);
    final imagePath = '${communityImagesDir.path}/$imageName';
    await _image!.copy(imagePath);

    // Kuralları birleştir
    String rules = "";
    for (int i = 0; i < _rulesControllers.length; i++) {
      if (_rulesControllers[i].text.isNotEmpty) {
        rules += "${i + 1}. ${_rulesControllers[i].text}\n";
      }
    }

    // Firestore verisini hazırlama
    Map<String, dynamic> communityData = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'category': _selectedCategories.join(', '),
      'rules': rules.trim(),
      'image': imagePath,
    };

    try {
      // Firebase Firestore'a veri ekle
      await FirebaseFirestore.instance.collection('communityinfo').add(communityData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Topluluk başarıyla oluşturuldu!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata oluştu: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Topluluk Oluştur",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resim ve Ad
            Row(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: ClipOval(
                    child: _image == null
                        ? Container(
                            color: Colors.grey[300],
                            height: 80,
                            width: 80,
                            child: Icon(Icons.image, size: 40, color: Colors.grey[700]),
                          )
                        : Image.file(
                            _image!,
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Topluluk Adı",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Açıklama
            _buildSection(
              title: "Topluluk Açıklaması",
              child: TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Açıklamanızı girin...",
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 16),

            // Kategoriler
            _buildSection(
              title: "Kategoriler",
              child: Wrap(
                spacing: 8.0,
                children: _categories.map((category) {
                  return FilterChip(
                    label: Text(category),
                    selected: _selectedCategories.contains(category),
                    onSelected: (selected) {
                      setState(() {
                        if (selected && _selectedCategories.length < 10) {
                          _selectedCategories.add(category);
                        } else {
                          _selectedCategories.remove(category);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 16),

            // Kurallar
            _buildSection(
              title: "Topluluk Kuralları",
              child: Column(
                children: List.generate(_rulesControllers.length, (index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _rulesControllers[index],
                          decoration: InputDecoration(
                            labelText: "Kural ${index + 1}",
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                      ),
                      if (index == _rulesControllers.length - 1 && _rulesControllers.length < 10)
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: _addRule,
                        ),
                    ],
                  );
                }),
              ),
            ),
            SizedBox(height: 32),

            // Buton
            Center(
              child: ElevatedButton(
                onPressed: () => _saveCommunity(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  "Topluluğu Oluştur",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modern bölüm görünümü
  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 10, spreadRadius: 1)],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
