import 'package:flutter/material.dart';
import 'package:unihub/pages/database_helper.dart';
import 'package:unihub/pages/community_panel_details.dart';

class AdminPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Panel")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.getAllCommunities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Topluluk bulunmamaktadır"));
          } else {
            List<Map<String, dynamic>> communities = snapshot.data!;

            return ListView.builder(
              itemCount: communities.length,
              itemBuilder: (context, index) {
                var community = communities[index];
                return ListTile(
                  title: Text(community['name']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommunityPanelDetailsPage(community: community),
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
