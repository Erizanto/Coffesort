import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HasilPage extends StatefulWidget {
  final String imagePath;
  final String quality;

  const HasilPage({
    Key? key,
    required this.imagePath,
    required this.quality,
  }) : super(key: key);

  @override
  State<HasilPage> createState() => _HasilPageState();
}

class _HasilPageState extends State<HasilPage> {
  final Map<String, int> labelIndex = {
    'dark': 0,
    'green': 1,
    'light': 2,
    'medium': 3,
  };

  @override
  void initState() {
    super.initState();
    _sendIndexToRTDB();
  }

  Future<void> _sendIndexToRTDB() async {
    try {
      final index = labelIndex[widget.quality.toLowerCase()];
      if (index != null) {
        final DatabaseReference ref = FirebaseDatabase.instance.ref('hasil');

        await ref.update({
          'index': index,
          'start': 1,
        });

        print('Index $index berhasil dikirim ke Realtime Database');
      } else {
        print('Label tidak dikenali: ${widget.quality}');
      }
    } catch (e) {
      print('Gagal mengirim data ke RTDB: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Color> labelColors = {
      'green': Colors.green,
      'light': Colors.orange,
      'medium': Colors.deepOrange,
      'dark': Colors.brown,
    };

    final Color qualityColor = labelColors[widget.quality.toLowerCase()] ?? Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hasil Deteksi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Foto yang Diambil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(widget.imagePath),
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: qualityColor.withOpacity(0.1),
                border: Border.all(color: qualityColor, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.verified,
                    color: qualityColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Kualitas Biji: ${widget.quality}',
                      style: TextStyle(
                        fontSize: 20,
                        color: qualityColor,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back),
              label: Text('Kembali'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                backgroundColor: Colors.brown[700],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
