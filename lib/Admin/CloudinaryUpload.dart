import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CloudinaryUploadExample extends StatefulWidget {
  @override
  _CloudinaryUploadExampleState createState() => _CloudinaryUploadExampleState();
}

class _CloudinaryUploadExampleState extends State<CloudinaryUploadExample> {
  File? _selectedImage;
  String? _uploadedImageUrl;

  final picker = ImagePicker();

  final String cloudName = 'djl5esa98'; // 👈 Your cloud name
  final String uploadPreset = 'fix_my_trip'; // 👈 Your preset name

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      _uploadImageToCloudinary(File(pickedFile.path));
    }
  }

  Future<void> _uploadImageToCloudinary(File image) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final data = json.decode(resStr);
      setState(() {
        _uploadedImageUrl = data['secure_url'];
      });
      print('Uploaded to: ${data['secure_url']}');
    } else {
      print('Failed to upload. Status: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Image')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedImage != null)
              Image.file(_selectedImage!, height: 200),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick and Upload Image'),
            ),
            if (_uploadedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Uploaded URL:\n$_uploadedImageUrl'),
              ),
          ],
        ),
      ),
    );
  }
}
