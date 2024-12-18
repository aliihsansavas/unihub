import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class CommunityPanelDetailsPage extends StatelessWidget {
  final Map<String, dynamic>? community;

  CommunityPanelDetailsPage({this.community});

  // Firestore referansları
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Onayla buton fonksiyonu
  Future<void> approveCommunity(BuildContext context) async {
    print("Community ID: ${community?['id']}");
    try {
      if (community != null) {
        // community id kontrolü
        String? communityId = community!['id'];
        
        // Eğer 'id' null ise işlem yapılmasın
        if (communityId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Topluluk ID'si bulunamadı")),
          );
          return;
        }

        DocumentReference communityInfoDoc = _firestore.collection('communityinfo').doc(communityId);

        DocumentSnapshot snapshot = await communityInfoDoc.get();
        if (snapshot.exists) {
          // community koleksiyonuna veri ekleme
          await _firestore.collection('community').doc(communityId).set(
            snapshot.data() as Map<String, dynamic>,
          );

          // communityinfo'dan sil
          await communityInfoDoc.delete();

          // Başarı mesajı ve sayfa güncelleme
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Topluluk onaylandı")),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Topluluk verisi bulunamadı")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e")),
      );
    }
  }

  // Reddet buton fonksiyonu
  Future<void> rejectCommunity(BuildContext context) async {
    print("Community ID: ${community?['id']}");
    try {
      if (community != null) {
        // community id kontrolü
        String? communityId = community!['id'];

        // Eğer 'id' null ise işlem yapılmasın
        if (communityId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Topluluk ID'si bulunamadı")),
          );
          return;
        }

        DocumentReference communityInfoDoc = _firestore.collection('communityinfo').doc(communityId);

        // communityinfo'dan veriyi sil
        await communityInfoDoc.delete();

        // Başarı mesajı ve sayfa güncelleme
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Topluluk reddedildi")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: community == null
            ? Center(child: Text("Topluluk verisi yok"))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipOval(
                          child: community!['image'] != null && File(community!['image']).existsSync()
                              ? Image.file(
                                  File(community!['image']),
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.cover,
                                )
                              : Icon(Icons.image, size: 100),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            community!['name'] ?? 'Bilinmiyor',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    _buildSection(
                      context,
                      title: "Topluluk Açıklaması",
                      content: community!['description'] ?? 'Açıklama yok',
                    ),
                    SizedBox(height: 20),
                    _buildSection(
                      context,
                      title: "Kategori",
                      content: community!['category'] ?? 'Kategori yok',
                    ),
                    SizedBox(height: 20),
                    _buildSection(
                      context,
                      title: "Kurallar",
                      content: community!['rules'] ?? 'Kurallar yok',
                    ),
                    SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => approveCommunity(context),
                            child: Text("Onayla"),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                              textStyle: TextStyle(fontSize: 18, color: Colors.white),
                              backgroundColor: Colors.green,
                            ),
                          ),
                          SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () => rejectCommunity(context),
                            child: Text("Reddet"),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                              textStyle: TextStyle(fontSize: 18, color: Colors.white),
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required String content}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(fontSize: 18, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
