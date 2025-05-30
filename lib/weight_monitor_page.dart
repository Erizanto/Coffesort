import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class WeightMonitoringPage extends StatefulWidget {
  const WeightMonitoringPage({Key? key}) : super(key: key);

  @override
  State<WeightMonitoringPage> createState() => _WeightMonitoringPageState();
}

class _WeightMonitoringPageState extends State<WeightMonitoringPage> {
  final List<String> categories = ['dark', 'green', 'light', 'medium'];
  final Map<String, String> rtdbKeys = {
    'dark': 'total1',
    'green': 'total2',
    'light': 'total3',
    'medium': 'total4',
  };

  final Map<String, Color> categoryColors = {
    'dark': Colors.brown,
    'green': Colors.green,
    'light': Colors.orange,
    'medium': Colors.deepOrange,
  };

  Map<String, double> totalWeights = {
    'dark': 0.0,
    'green': 0.0,
    'light': 0.0,
    'medium': 0.0,
  };

  late DatabaseReference _ref;

  @override
  void initState() {
    super.initState();
    _ref = FirebaseDatabase.instance.ref('dody');
    _ref.onValue.listen(_onDataChanged);
  }

  void _onDataChanged(DatabaseEvent event) {
    final data = event.snapshot.value;
    if (data is! Map) return;

    final updatedWeights = <String, double>{
      'dark': (data[rtdbKeys['dark']] ?? 0.0).toDouble(),
      'green': (data[rtdbKeys['green']] ?? 0.0).toDouble(),
      'light': (data[rtdbKeys['light']] ?? 0.0).toDouble(),
      'medium': (data[rtdbKeys['medium']] ?? 0.0).toDouble(),
    };

    setState(() => totalWeights = updatedWeights);
  }

  double get total => totalWeights.values.fold(0.0, (sum, w) => sum + w);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monitoring Berat Biji Kopi'),
        centerTitle: true,
        backgroundColor: Colors.brown[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Icon(Icons.scale, size: 64, color: Colors.brown[400]),
                  SizedBox(height: 8),
                  Text(
                    'Pantau Berat Setiap Kategori',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            ...categories.map((category) {
              final weight = totalWeights[category]!;
              final color = categoryColors[category]!;
              final percentage = total == 0 ? 0.0 : (weight / total).toDouble();

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 5,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category[0].toUpperCase() + category.substring(1),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percentage,
                      color: color,
                      backgroundColor: color.withOpacity(0.2),
                      minHeight: 10,
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Berat: ${weight.toStringAsFixed(3)} g'),
                        Text('${(percentage * 100).toStringAsFixed(1)} %'),
                      ],
                    )
                  ],
                ),
              );
            }),

            Divider(height: 40, thickness: 1.5),

            Center(
              child: Column(
                children: [
                  Text(
                    'Total Berat',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${total.toStringAsFixed(3)} gram',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.brown[800]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
