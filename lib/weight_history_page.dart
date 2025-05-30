import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class WeightHistoryPage extends StatelessWidget {
  final String quality;

  const WeightHistoryPage({Key? key, required this.quality}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Riwayat $quality')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('weights')
            .where('quality', isEqualTo: quality)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(child: Text('Belum ada data untuk kategori ini.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final weight = (data['weight'] ?? 0).toDouble();
              final timestamp = data['timestamp'] != null
                  ? (data['timestamp'] as Timestamp).toDate()
                  : DateTime.now();

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: Icon(Icons.monitor_weight_outlined, color: Colors.brown),
                  title: Text('$weight gram', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(timestamp)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
