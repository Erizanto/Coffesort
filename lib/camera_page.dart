import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'hasil_page.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late List<CameraDescription> cameras;
  bool _isInitialized = false;
  bool _isLoading = false;
  int _selectedCameraIndex = 0;
  Interpreter? _interpreter;

  FlashMode _flashMode = FlashMode.auto;
  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 4.0;

  @override
  void initState() {
    super.initState();
    _loadModel();
    _initializeCamera();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      print('Model loaded');
    } catch (e) {
      print("Model loading error: $e");
    }
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      _controller = CameraController(
        cameras[_selectedCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller.initialize();
      _minZoom = await _controller.getMinZoomLevel();
      _maxZoom = await _controller.getMaxZoomLevel();
      _flashMode = _controller.value.flashMode;

      setState(() => _isInitialized = true);
    } catch (e) {
      print("Camera Error: $e");
    }
  }

  Future<void> _switchCamera() async {
    if (cameras.length < 2) return;

    setState(() {
      _isInitialized = false;
      _selectedCameraIndex = (_selectedCameraIndex + 1) % cameras.length;
    });

    await _controller.dispose();
    await _initializeCamera();
  }

  Future<void> _toggleFlash() async {
    FlashMode nextMode;
    if (_flashMode == FlashMode.auto) {
      nextMode = FlashMode.always;
    } else if (_flashMode == FlashMode.always) {
      nextMode = FlashMode.off;
    } else {
      nextMode = FlashMode.auto;
    }

    await _controller.setFlashMode(nextMode);
    setState(() {
      _flashMode = nextMode;
    });
  }

  Widget _buildFlashIcon() {
    switch (_flashMode) {
      case FlashMode.auto:
        return Icon(Icons.flash_auto);
      case FlashMode.always:
        return Icon(Icons.flash_on);
      case FlashMode.off:
        return Icon(Icons.flash_off);
      default:
        return Icon(Icons.flash_auto);
    }
  }

  Future<List<List<List<List<double>>>>?> _preprocessImage(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return null;

    final resized = img.copyResize(image, width: 256, height: 256);
    final input = List.generate(
      1,
      (_) => List.generate(
        256,
        (y) => List.generate(
          256,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );
    return input;
  }

  Future<void> _captureAndDetect() async {
    if (_controller.value.isTakingPicture || _interpreter == null) return;

    setState(() => _isLoading = true);

    try {
      final image = await _controller.takePicture();
      final input = await _preprocessImage(image.path);

      if (input != null) {
        final output = List.filled(1 * 4, 0.0).reshape([1, 4]);
        _interpreter!.run(input, output);

        final maxValue = output[0].reduce((double a, double b) => a > b ? a : b);
        final maxIndex = output[0].indexOf(maxValue);
        final labels = ['Dark', 'Green', 'Light', 'Medium'];
        final result = labels[maxIndex];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HasilPage(
              imagePath: image.path,
              quality: result,
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HasilPage(
              imagePath: image.path,
              quality: 'Gagal Preprocessing',
            ),
          ),
        );
      }
    } catch (e) {
      print("Error capturing image: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isInitialized
          ? Stack(
              children: [
                GestureDetector(
                  onTapDown: (details) async {
                    final offset = Offset(
                      details.localPosition.dx, 
                      details.localPosition.dy
                      );
                    await _controller.setFocusPoint(offset);
                  },
                  onScaleUpdate: (details) async {
                    final zoom = (_currentZoom * details.scale)
                        .clamp(_minZoom, _maxZoom);
                    setState(() {
                      _currentZoom = zoom;
                    });
                    await _controller.setZoomLevel(_currentZoom);
                  },
                  child: CameraPreview(_controller),
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                  top: 50,
                  right: 20,
                  child: Column(
                    children: [
                      IconButton(
                        icon: _buildFlashIcon(),
                        color: Colors.white,
                        iconSize: 28,
                        onPressed: _toggleFlash,
                      ),
                      SizedBox(height: 12),
                      IconButton(
                        icon: Icon(Icons.cameraswitch),
                        color: Colors.white,
                        iconSize: 28,
                        onPressed: _switchCamera,
                      ),
                    ],
                  ),
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black45,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _isLoading ? null : _captureAndDetect,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 36,
                          color: Colors.brown[600],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
