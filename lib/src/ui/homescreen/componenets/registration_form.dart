import 'dart:convert';
import 'dart:io';
import 'package:cricket_scorecard/src/ui/homescreen/componenets/success_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final categoryController = TextEditingController();
  final specialityController = TextEditingController();
  final areaController = TextEditingController();
  final districtController = TextEditingController();
  final nidController = TextEditingController();
  final birthDateController = TextEditingController();

  // Variables to store image data for web and mobile
  XFile? _chosenImage; // For mobile
  String? _webImageDataUrl; // For web

  // Image picker instance
  final ImagePicker picker = ImagePicker();

  Future<void> selectImage() async {
    // Pick an image (this works for both mobile and web)
    XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        Uint8List imageBytes = await pickedFile.readAsBytes();
        String base64Image =
            "data:image/jpeg;base64," + base64Encode(imageBytes);

        setState(() {
          _webImageDataUrl = base64Image;
        });
      } else {
        setState(() {
          _chosenImage = pickedFile; // Store the XFile for mobile
        });
      }
    }
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      final uri = Uri.parse(
          'http://192.168.68.102:8000/register_user/'); // Your API endpoint

      var request = http.MultipartRequest('POST', uri);
      request.fields['name'] = nameController.text;
      request.fields['phone_number'] = phoneController.text;
      request.fields['address'] = addressController.text;
      request.fields['district'] = districtController.text;
      request.fields['nid_or_birth_certificate_no'] = nidController.text;
      request.fields['date_of_birth'] = birthDateController.text;
      request.fields['area'] = areaController.text;
      request.fields['player_category'] = categoryController.text;
      request.fields['speciality'] = specialityController.text;

      // Add image file (only if it's available)
      if (_chosenImage != null) {
        var photo = await http.MultipartFile.fromPath(
            'player_photo', _chosenImage!.path);
        request.files.add(photo);
      } else if (_webImageDataUrl != null) {
        request.fields['player_photo'] = _webImageDataUrl!;
      }

      try {
        var response = await request.send();

        // Get the raw response body
        var responseBody = await response.stream.bytesToString();
        print('Raw response body: $responseBody');

        // Try to decode it as JSON
        try {
          var data = jsonDecode(responseBody);

          if (data is Map) {
            var id = data['id']; // assuming 'id' is a field in your response
            if (id != null && id is int) {
              print('Successfully registered with id: $id');
              // Navigate to the success screen with the user ID
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SuccessScreen(userId: id),
                ),
              );
            } else {
              print('ID is missing or not an integer');
            }
          } else {
            print('Expected Map but received something else');
          }
        } catch (e) {
          print('Error decoding response: $e');
        }
      } catch (e) {
        print('Error submitting form: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error occurred: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(title: Text('Player Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Show selected image (either web or mobile)
              _webImageDataUrl != null
                  ? Image.network(_webImageDataUrl!,
                      height: 200, width: 200, fit: BoxFit.cover)
                  : _chosenImage != null
                      ? Image.file(File(_chosenImage!.path))
                      : Icon(Icons.image,
                          size: 50), // Placeholder icon if no image is selected

              ElevatedButton(
                onPressed: selectImage,
                child: Text('Select Image'),
              ),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    buildTextField(nameController, 'Name'),
                    buildTextField(phoneController, 'Phone Number'),
                    buildTextField(addressController, 'Address'),
                    buildTextField(districtController, 'District'),
                    buildTextField(nidController, 'NID/Birth Certificate No'),
                    buildTextField(birthDateController, 'Date of Birth'),
                    buildTextField(
                        areaController, 'Area (Local/Semi-Local/Overseas)'),
                    buildTextField(categoryController,
                        'Category (Batsman/Bowler/All-Rounder)'),
                    buildTextField(specialityController, 'Speciality'),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      ),
    );
  }
}
