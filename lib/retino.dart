import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_switch/flutter_switch.dart';

class ImageUploadPage extends StatefulWidget {
  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  File? _image;
  String _predictionResult = '';
  int _selectedSample = 1;
  bool _groundTruthEnabled = false;
  Map<int, String> sampleImages = {
    1: '10_left.jpeg',
    2: '10_right.jpeg',
    3: '4723_left.jpeg',
    4: '4723_right.jpeg',
  };
  Map<int, String> groundTruthLabels = {
    1: 'Non Diabetic',
    2: 'Non Diabetic',
    3: 'Diabetic',
    4: 'Diabetic',
  };

  Future<void> _sendImage(String imagePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.184.231:8080/predict'),
      );
      final byteData = await rootBundle.load('assets/images/$imagePath');
      final file = File('${(await getTemporaryDirectory()).path}/$imagePath');
      await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

      request.files.add(await http.MultipartFile.fromPath('image', file.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var result = await response.stream.bytesToString();
        setState(() {
          _predictionResult = 'DL model prediction: $result';
        });
      } else {
        print('Failed to send image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending image: $e');
    }
  }

  void _selectSample(int sampleNumber) {
    setState(() {
      _selectedSample = sampleNumber;
      _image = null;
      _predictionResult = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 147, 201, 225),
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FlutterSwitch(
              width: 60.0,
              height: 30.0,
              valueFontSize: 12.0,
              toggleSize: 20.0,
              value: _groundTruthEnabled,
              borderRadius: 30.0,
              padding: 2.0,
              activeToggleColor: Colors.purple,
              activeSwitchBorder: Border.all(
                color: Colors.purple,
                width: 2.0,
              ),
              inactiveToggleColor: Colors.grey,
              inactiveSwitchBorder: Border.all(
                color: Colors.grey,
                width: 2.0,
              ),
              onToggle: (value) {
                setState(() {
                  _groundTruthEnabled = value;
                });
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Dropdown for selecting samples
            DropdownButton<int>(
              value: _selectedSample,
              onChanged: (value) => _selectSample(value!),
              items: List.generate(
                sampleImages.length,
                    (index) => DropdownMenuItem<int>(
                  value: index + 1,
                  child: Text('Sample ${index + 1}'),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Display selected image or default text
            _image == null
                ? Image.asset(
              'assets/images/${sampleImages[_selectedSample]!}',
              height: 200,
              width: 200,
            )
                : Image.file(
              _image!,
              height: 200,
              width: 200,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _sendImage(sampleImages[_selectedSample]!),
              child: Text('Predict'),
            ),
            SizedBox(height: 20),
            // Display Ground Truth if enabled
            if (_groundTruthEnabled)
              Text('Ground Truth: ${groundTruthLabels[_selectedSample]}'),
            SizedBox(height: 20),
            // Display the prediction result
            Text(_predictionResult),
          ],
        ),
      ),
    );
  }
}
