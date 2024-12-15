import 'package:flutter/material.dart';

class CommunityPanelDetailsPage extends StatelessWidget {
  final Map<String, dynamic>? community; // Bu parametre nullable

  CommunityPanelDetailsPage({this.community}); // 'required' ifadesini kaldırıyoruz

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(community?['name'] ?? 'Topluluk Detayları'), // Topluluk adı veya varsayılan metin
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: community == null
            ? Center(child: Text("Topluluk verisi yok"))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Topluluk Adı: ${community!['name']}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Açıklama: ${community!['description']}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Kategori: ${community!['category']}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Kurallar: ${community!['rules']}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 32),
                  // Onayla ve Reddet butonları
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: Text("Onayla"),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text("Reddet"),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
