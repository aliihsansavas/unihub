import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Yardım & Destek")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sıkça Sorulan Sorular Başlığı
              Text(
                "Sıkça Sorulan Sorular",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              
              // Sıkça Sorulan Sorular Listesi
              FAQItem(
                question: "Bu uygulama hangi amaçla kullanılır?",
                answer: "Bu uygulama üniversite topluluklarını keşfetmenizi ve onlarla etkileşim kurmanızı sağlar.",
                questionColor: Colors.red, // Sorunun rengini kırmızı yapar
              ),
              FAQItem(
                question: "Kendi topluluğumu nasıl oluştururum?",
                answer: "Menüden 'Topluluk Oluştur' seçeneğini seçerek topluluğunuzu oluşturabilirsiniz.",
                questionColor: Colors.purple, // Sorunun rengini mor yapar
              ),
              FAQItem(
                question: "Etkinliklere nasıl katılabilirim?",
                answer: "Etkinlikler sayfasından katılmak istediğiniz etkinliği seçerek detaylarını görebilir ve katılım sağlayabilirsiniz.",
                questionColor: Colors.orange, // Sorunun rengini turuncu yapar
              ),
              FAQItem(
                question: "Profil bilgilerimi nasıl güncellerim?",
                answer: "Profil sayfasına giderek bilgilerinizi düzenleyebilirsiniz.",
                questionColor: Colors.green, // Sorunun rengini yeşil yapar
              ),
              FAQItem(
                question: "Yönetim paneline kimler erişebilir?",
                answer: "Yönetim paneli yalnızca admin yetkisine sahip kullanıcılar tarafından erişilebilir.",
                questionColor: Colors.blue, // Sorunun rengini mavi yapar
              ),

              SizedBox(height: 30),

              // Bize Ulaşın Başlığı
              Text(
                "Bize Ulaşın",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),

              // Email ve Telefon Bilgileri
              Row(
                children: [
                  Icon(Icons.email),
                  SizedBox(width: 8),
                  Text("support@example.com"),
                ],
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Icon(Icons.phone),
                  SizedBox(width: 8),
                  Text("+90 123 456 7890"),
                ],
              ),
              SizedBox(height: 30),

               // Soru Sorun Başlığı
              Text(
                "Soru Sorun",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),

              // Metin Kutusu
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Mesajınızı buraya yazabilirsiniz...",
                ),
              ),
              SizedBox(height: 30),

              // Gönder Butonu
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    // Şu an için bir işlem yapmıyor
                  },
                  child: Text("Gönder"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Sıkça Sorulan Sorular Bileşeni
class FAQItem extends StatefulWidget {
  final String question;
  final String answer;
  final Color questionColor; // Soru rengi için eklenen yeni özellik

  FAQItem({required this.question, required this.answer, this.questionColor = Colors.blue});

  @override
  _FAQItemState createState() => _FAQItemState();
}

class _FAQItemState extends State<FAQItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.question,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.questionColor,
                  ),
                ),
              ),
              Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            ],
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
            child: Text(
              widget.answer,
              style: TextStyle(fontSize: 16),
            ),
          ),
      ],
    );
  }
}
