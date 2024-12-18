import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'community_management_page.dart';

class CommunitiesPage extends StatefulWidget {
  @override
  _CommunitiesPageState createState() => _CommunitiesPageState();
}

class _CommunitiesPageState extends State<CommunitiesPage> {
  List<Map<String, dynamic>> communities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCommunities();
  }

  // Firestore'dan toplulukları çekme
  Future<void> fetchCommunities() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('communities').get();

      setState(() {
        communities = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['name'],
            'leaderId': doc['leaderId'],
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Topluluklar yüklenirken hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Topluluklar")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : communities.isEmpty
              ? Center(child: Text("Hiç topluluk bulunmuyor."))
              : ListView.builder(
                  itemCount: communities.length,
                  itemBuilder: (context, index) {
                    var community = communities[index];
                    return ListTile(
                      title: Text(community['name']),
                      trailing: community['leaderId'] == FirebaseAuth.instance.currentUser?.uid
                          ? ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CommunityManagementPage(
                                      communityId: community['id'],
                                    ),
                                  ),
                                );
                              },
                              child: Text('Yönet'),
                            )
                          : null,
                    );
                  },
                ),
    );
  }
}
