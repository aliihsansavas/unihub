import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final int userId;

  ProfilePage({required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final response = await http.get(
        Uri.parse('https://your-server.com/get_user.php?id=${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('error')) {
          setState(() {
            errorMessage = data['error'];
            isLoading = false;
          });
        } else {
          setState(() {
            userData = data;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Sunucu hatası: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Bağlantı hatası: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil Sayfası"),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/logo.png'),
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Kullanıcı Bilgileri',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 30),
                      InfoCard(
                        icon: Icons.person,
                        label: 'Ad Soyad',
                        info: userData?['name'] ?? 'Bilinmiyor',
                      ),
                      SizedBox(height: 15),
                      InfoCard(
                        icon: Icons.phone,
                        label: 'Telefon Numarası',
                        info: userData?['phone'] ?? 'Bilinmiyor',
                      ),
                      SizedBox(height: 15),
                      InfoCard(
                        icon: Icons.email,
                        label: 'E-posta',
                        info: userData?['email'] ?? 'Bilinmiyor',
                      ),
                    ],
                  ),
                ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String info;

  InfoCard({required this.icon, required this.label, required this.info});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(info, style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
