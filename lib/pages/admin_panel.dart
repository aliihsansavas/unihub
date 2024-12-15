import 'package:flutter/material.dart';
import 'package:UniHub/pages/database_helper.dart'; // Database helper importu
import 'package:UniHub/pages/community_panel_details.dart';
class AdminPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Panel")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.getAllCommunities(), // Veritabanından toplulukları al
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Veriler yükleniyor
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}')); // Hata durumu
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Topluluk bulunmamaktadır")); // Veri yoksa
          } else {
            List<Map<String, dynamic>> communities = snapshot.data!;

            return ListView.builder(
              itemCount: communities.length,
              itemBuilder: (context, index) {
                var community = communities[index];
                return ListTile(
                  title: Text(community['name']), // Topluluk adı
                  onTap: () {
                    // Tıklanıldığında CommunityDetailsPage'e geçiş yap, ancak community parametresini opsiyonel gönder
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommunityPanelDetailsPage(community: community), // Seçilen topluluk gönderiliyor
                      ),
                    );

                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}