import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unihub/services/auth_service.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  String _gender = "";
  bool _isLoading = false;
  final _selectedInterests = <String>{};
  File? _imageFile;
  final AuthService _authService = AuthService();

  final List<String> _categories = [
    'Spor', 'Müzik', 'Sanat', 'Teknoloji', 'Doğa', 'Kitap', 'Gezi', 'Film', 'Yemek', 'Tiyatro',
  ];

  bool _isDarkMode = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _authService.signUp(
          email: _emailController.text,
          password: _passwordController.text,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          birthDate: _birthDateController.text,
          gender: _gender,
          interests: _selectedInterests.toList(),
          profilePic: _imageFile ?? File('assets/light_mode.png'),
          context: context,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
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
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : null,
                  child: _imageFile == null
                      ? Icon(
                          Icons.camera_alt,
                          size: 70,
                          color: Colors.grey,
                        )
                      : null,
                ),
              ),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'Ad'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Lütfen adınızı giriniz!';
                  }
                  if (!RegExp(r'^[a-zA-ZğüşöçıİĞÜŞÖÇ ]+$').hasMatch(value)) {
                    return 'Adınızda sadece harf ve boşluk olmalıdır!';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Soyad'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Lütfen soyadınızı giriniz!';
                  }
                  if (!RegExp(r'^[a-zA-ZğüşöçıİĞÜŞÖÇ ]+$').hasMatch(value)) {
                    return 'Soyadınızda sadece harf ve boşluk olmalıdır!';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _gender.isNotEmpty ? _gender : null,
                decoration: InputDecoration(labelText: 'Cinsiyet'),
                items: ['Erkek', 'Kadın']
                    .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
                validator: (value) => value == null || value.isEmpty ? 'Lütfen cinsiyet seçiniz!' : null,
              ),
              TextFormField(
                controller: _birthDateController,
                decoration: InputDecoration(labelText: 'Doğum Tarihi (GG-AA-YYYY)'),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen doğum tarihinizi giriniz!';
                  }
                  if (!RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(value)) {
                    return 'Lütfen geçerli bir tarih formatı giriniz (GG-AA-YYYY)';
                  }
                  final parts = value.split('-');
                  final day = int.parse(parts[0]);
                  final month = int.parse(parts[1]);
                  final year = int.parse(parts[2]);
                  if (day < 1 || day > 31) {
                    return 'Geçerli bir gün giriniz!';
                  }
                  if (month < 1 || month > 12) {
                    return 'Geçerli bir ay giriniz!';
                  }
                  if (year < 1900 || year > DateTime.now().year) {
                    return 'Geçerli bir yıl giriniz!';
                  }
                  try {
                    final birthDate = DateTime(year, month, day);
                    final today = DateTime.now();
                    final age = today.year - birthDate.year;
                    final isBeforeBirthday = today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day);
                    if (age < 18 || (age == 18 && isBeforeBirthday)) {
                      return '18 yaşından büyük olmanız gerekmektedir!';
                    }
                  } catch (e) {
                    return 'Geçerli bir tarih giriniz!';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'E-posta'),
                validator: (value) => value!.endsWith('@trakya.edu.tr')
                    ? null
                    : 'Lütfen okul mailinizi giriniz!',
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Şifre'),
                validator: (value) => _authService.isPasswordStrong(value!)
                    ? null
                    : 'Şifre en az 8 karakter, bir büyük harf\nbir rakam ve bir özel karakter içermelidir!',
              ),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Şifre Tekrar'),
                validator: (value) => value == _passwordController.text
                    ? null
                    : 'Girilen şifreler birbirini tutmuyor!',
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: _categories.map((category) {
                  return FilterChip(
                    label: Text(category),
                    selected: _selectedInterests.contains(category),
                    onSelected: (isSelected) {
                      setState(() {
                        if (isSelected) {
                          _selectedInterests.add(category);
                        } else {
                          _selectedInterests.remove(category);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 40),
                  textStyle: TextStyle(fontSize: 18),
                  backgroundColor: _isDarkMode ? const Color(0xFF7B1FA2) : const Color(0xFFCE93D8),
                  foregroundColor: _isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF212121),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 15,
                  shadowColor: _isDarkMode ? const Color(0xFF7B1FA2) : const Color(0xFFCE93D8),
                ),
                child: _isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    )
                  : Text('Kayıt Ol'),
              ),
              SizedBox(height: 5),
              TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text("Zaten bir hesabınız mı var? Giriş yapın"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}