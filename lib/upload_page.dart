import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({Key? key}) : super(key: key);

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _image;
  String? _label;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  Future<void> _loadModel() async {
    await Tflite.loadModel(
      model: 'assets/model.tflite', // ganti sesuai path model kamu
      labels: 'assets/labels.txt',
    );
  }

  Future<void> _classifyImage(File image) async {
    final output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 1,
      threshold: 0.1,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    print('Hasil Model: $output');

    if (output != null && output.isNotEmpty) {
      setState(() {
        _label = output[0]['label']
            .toString()
            .replaceAll(RegExp(r'[0-9]'), '')
            .replaceAll(RegExp(r'[^a-zA-Z ]'), '')
            .trim();
      });
    } else {
      setState(() {
        _label = "Tidak terdeteksi";
      });
    }
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final imageTemp = File(pickedFile.path);
      setState(() {
        _image = imageTemp;
        _label = null;
      });
      await _classifyImage(imageTemp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Gambar"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_image != null)
              Container(
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _image!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              (_image != null && _label != null && _label!.isNotEmpty)
                  ? 'Hasil Deteksi: $_label'
                  : 'Pilih gambar untuk mendeteksi kualitas biji kopi.',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _getImage(ImageSource.gallery),
              icon: const Icon(Icons.image),
              label: const Text("Pilih dari Galeri"),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _getImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text("Ambil dari Kamera"),
            ),
          ],
        ),
      ),
    );
  }
}
