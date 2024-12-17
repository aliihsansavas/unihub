import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommunityManagementPage extends StatefulWidget {
  final String communityId;  // Yönetilecek topluluğun ID'si

  CommunityManagementPage({required this.communityId});

  @override
  _CommunityManagementPageState createState() => _CommunityManagementPageState();
}

class _CommunityManagementPageState extends State<CommunityManagementPage> {
  String? leaderId;
  List<Map<String, dynamic>> members = [];
  bool isLoading = true;
  int? quota;

  @override
  void initState() {
    super.initState();
    fetchCommunityData();
  }

  // Topluluk bilgilerini ve üyeleri çekme
  Future<void> fetchCommunityData() async {
    try {
      // Topluluk belgesini çek
      DocumentSnapshot communityDoc = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .get();

      if (communityDoc.exists) {
        setState(() {
          leaderId = communityDoc['leaderId'];
          quota = communityDoc['quota'];
        });

        // Üyeleri çek
        QuerySnapshot membersSnapshot = await FirebaseFirestore.instance
            .collection('communities')
            .doc(widget.communityId)
            .collection('members')
            .get();

        setState(() {
          members = membersSnapshot.docs.map((doc) {
            return {
              'userId': doc.id,
              'name': doc['name'],
            };
          }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Topluluk verisi alınırken hata oluştu: $e')),
      );
    }
  }

  // Üyeyi topluluktan çıkarma
  Future<void> removeMember(String userId) async {
    try {
      // Üyeyi topluluktan sil
      await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .collection('members')
          .doc(userId)
          .delete();

      setState(() {
        members.removeWhere((member) => member['userId'] == userId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Üye topluluktan çıkarıldı.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Üye çıkarılırken hata oluştu: $e')),
      );
    }
  }

  // Kotayı güncelleme
  Future<void> updateQuota(int newQuota) async {
    try {
      await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .update({'quota': newQuota});

      setState(() {
        quota = newQuota;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Topluluk kotası güncellendi.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kota güncellenirken hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Topluluk Yönetimi')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Kota Güncelleme Alanı
                ListTile(
                  title: Text('Topluluk Kotası: $quota'),
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      int newQuota = quota ?? 0;
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Kotayı Güncelle'),
                          content: TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              newQuota = int.tryParse(value) ?? newQuota;
                            },
                            decoration: InputDecoration(hintText: 'Yeni kota değeri'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                updateQuota(newQuota);
                                Navigator.pop(context);
                              },
                              child: Text('Güncelle'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Divider(),
                // Üye Listesi
                Expanded(
                  child: ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      var member = members[index];
                      return ListTile(
                        title: Text(member['name']),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => removeMember(member['userId']),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
