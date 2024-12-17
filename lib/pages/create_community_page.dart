import 'package:flutter/material.dart';
import 'package:unihub/pages/database_helper.dart'; // Veritabanı yardımcı sınıfınızın yolu
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart'; // Resim seçimi için gerekli
import 'dart:io';
import 'package:path/path.dart';



File? _image; // Resim dosyasını saklamak için değişken
final ImagePicker _picker = ImagePicker(); // Resim seçmek için bir ImagePicker nesnesi

class CreateCommunityPage extends StatefulWidget {
  @override
  _CreateCommunityPageState createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<CreateCommunityPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _rulesController = TextEditingController();
  String? _category;

  final List<String> _categories = ['Education', 'Technology', 'Sports', 'Music'];

  Future<void> _pickImage() async {
  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    setState(() {
      _image = File(pickedFile.path); // Seçilen resmi _image değişkenine atıyoruz
    });
  }
}


  Future<void> _saveCommunity(BuildContext context) async {
  if (_nameController.text.isEmpty ||
      _descriptionController.text.isEmpty ||
      _rulesController.text.isEmpty ||
      _category == null ||
      _image == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Lütfen tüm alanları doldurun ve bir resim seçin.")),
    );
    return;
  }

 // Resmin ismini ve yolunu al
  String imageName = basename(_image!.path);

  // Uygulamanın belgeler dizinine erişim
  final directory = await getApplicationDocumentsDirectory();
  
  // "communityimages" klasörünün var olup olmadığını kontrol et
  final communityImagesDir = Directory('${directory.path}/communityimages');
  
  // Eğer klasör yoksa, oluştur
  if (!await communityImagesDir.exists()) {
    await communityImagesDir.create(recursive: true);
  }

  // Resmi hedef dizine kopyala
  final imagePath = '${communityImagesDir.path}/$imageName';
  await _image!.copy(imagePath);


  // Veritabanına kayıt ekleme
  Map<String, dynamic> communityData = {
    'name': _nameController.text,
    'description': _descriptionController.text,
    'category': _category!,
    'rules': _rulesController.text,
    'image': imageName, // Resim adı ekleniyor
  };

  try {
    await DatabaseHelper.instance.insert(communityData);
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
      appBar: AppBar(title: Text("Create Community")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Topluluk Adı", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(controller: _nameController, decoration: InputDecoration(hintText: "Topluluk adı girin")),
            SizedBox(height: 16),

            Text("Topluluk Açıklaması", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(controller: _descriptionController, decoration: InputDecoration(hintText: "Açıklama girin")),
            SizedBox(height: 16),

            Text("Topluluk Kategorisi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              hint: Text("Bir kategori seçin"),
              value: _category,
              onChanged: (newValue) {
                setState(() {
                  _category = newValue;
                });
              },
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
            ),
            SizedBox(height: 16),

            Text("Topluluk Kuralları", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(controller: _rulesController, decoration: InputDecoration(hintText: "Kurallar girin")),
            SizedBox(height: 32),

            
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("Fotoğraf Seç"),
            ),
            _image != null
                ? Image.file(_image!, height: 150, width: 150, fit: BoxFit.cover)
                : Text("Fotoğraf seçilmedi"),
            
            ElevatedButton(
                onPressed: () {
                  _saveCommunity(context);  // context'i fonksiyona ilet
                },
                child: Text("Create Community")
              ),
          ],
        ),
      ),
    );
  }
}
