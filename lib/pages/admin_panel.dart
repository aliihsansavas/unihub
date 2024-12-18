import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:UniHub/pages/community_panel_details.dart';
import 'dart:io';

class AdminPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Panel"),
        backgroundColor: Colors.teal, // AppBar arka plan rengi
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('communityinfo').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Veriler yükleniyor
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}')); // Hata durumu
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Topluluk bulunmamaktadır")); // Veri yoksa
          } else {
            List<QueryDocumentSnapshot> communities = snapshot.data!.docs;

            return ListView.builder(
              itemCount: communities.length,
              itemBuilder: (context, index) {
                // Belge verilerini ve ID'sini alın
                var communityDoc = communities[index];
                var community = communityDoc.data() as Map<String, dynamic>;
                community['id'] = communityDoc.id; // Document ID'yi manuel olarak ekle

                 String imagePath = community['image'] ?? ''; // Resim yolunu alın

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      try {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommunityPanelDetailsPage(community: community), // Seçilen topluluk gönderiliyor
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: imagePath.isNotEmpty && File(imagePath).existsSync()
                                ? Image.file(
                                    File(imagePath),
                                    height: 60,
                                    width: 60,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(Icons.image, size: 50, color: Colors.grey),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.teal, width: 1.5),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.teal.withOpacity(0.1),
                              ),
                              child: Text(
                                community['name'] ?? 'Bilinmiyor',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
