import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EventsPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventsPage> {
  String? userId;
  List<String> userJoinedCommunities = [];  // Kullanıcının katıldığı topluluklar
  bool isLoading = true;
  List<Map<String, dynamic>> events = [];  // Etkinlik verileri
  String? errorMessage;  // Hata mesajı

  @override
  void initState() {
    super.initState();
    fetchUserId();  // Kullanıcı ID'sini al
  }

  // Kullanıcının ID'sini almak
  Future<void> fetchUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      fetchUserJoinedCommunities();  // Kullanıcının katıldığı toplulukları al
    } else {
      setState(() {
        isLoading = false;
        errorMessage = "Kullanıcı oturum açmamış.";
      });
    }
  }

  // Kullanıcının katıldığı toplulukları almak
  Future<void> fetchUserJoinedCommunities() async {
    if (userId == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        setState(() {
          userJoinedCommunities = List<String>.from(userDoc['joinedCommunities'] ?? []);
        });
        fetchEvents();  // Etkinlikleri al
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Kullanıcı verisi bulunamadı.";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Kullanıcı verisi alınırken hata oluştu: $e";
      });
    }
  }

  // Kullanıcının katıldığı toplulukların etkinliklerini almak
  Future<void> fetchEvents() async {
    if (userJoinedCommunities.isEmpty) return;

    List<Map<String, dynamic>> eventList = [];

    try {
      for (String communityId in userJoinedCommunities) {
        QuerySnapshot eventSnapshot = await FirebaseFirestore.instance
            .collection('communities')
            .doc(communityId)
            .collection('events')
            .get();

        for (var doc in eventSnapshot.docs) {
          eventList.add({
            'eventId': doc.id,
            'communityId': communityId,
            'eventDetails': doc.data(),
          });
        }
      }

      setState(() {
        events = eventList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Etkinlikler alınırken hata oluştu: $e";
      });
    }
  }

  // Etkinliğe katılma işlemi
  Future<void> joinEvent(String eventId, String communityId) async {
    try {
      // Etkinlik bilgilerini güncelle
      await FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .collection('events')
          .doc(eventId)
          .update({
        'participants': FieldValue.arrayUnion([userId]),
      });

      // Kullanıcının katıldığı etkinlikleri güncelle
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'joinedEvents': FieldValue.arrayUnion([eventId]),
      });

      // Etkinlik katılımcıları listesine ekle
      setState(() {
        events = events.map((event) {
          if (event['eventId'] == eventId) {
            event['eventDetails']['participants'].add(userId);
          }
          return event;
        }).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Etkinliğe katıldınız!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bir hata oluştu: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Etkinlikler")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())  // Yükleniyor durumu
          : errorMessage != null
              ? Center(child: Text(errorMessage!))  // Hata mesajı
              : events.isEmpty
                  ? Center(child: Text("Katıldığınız topluluklarda etkinlik bulunmuyor."))
                  : ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        var event = events[index];
                        return ListTile(
                          title: Text(event['eventDetails']['title'] ?? 'Başlık Yok'),
                          subtitle: Text(event['eventDetails']['description'] ?? 'Açıklama Yok'),
                          trailing: ElevatedButton(
                            onPressed: () => joinEvent(event['eventId'], event['communityId']),
                            child: Text("Katıl"),
                          ),
                        );
                      },
                    ),
    );
  }
}
