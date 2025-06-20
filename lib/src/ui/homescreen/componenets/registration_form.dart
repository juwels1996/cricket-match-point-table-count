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
  final bkashAccountController = TextEditingController();
  final bkashTransactionIdController = TextEditingController();

  // Variables to store image data for web and mobile
  XFile? _chosenImage; // For mobile
  String? _webImageDataUrl; // For web
  final List<String> areaOptions = ['Local', 'Semi-Local', 'Overseas'];
  String? selectedArea;

  final List<String> categoryOptions = ['A', 'B', 'C'];
  final List<String> specialityOptions = ['Bowler', 'Batsman', 'All-Rounder'];

// ───── currently chosen items ────────────────────────────────────────────────
  String? selectedCategory;
  String? selectedSpeciality;

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
      if (selectedCategory == null ||
          selectedSpeciality == null ||
          selectedArea == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Please select Area, Category, and Speciality')),
        );
        return;
      }

      final uri = Uri.parse('https://backend.dplt10.org/register_user/');
      var request = http.MultipartRequest('POST', uri);

      request.fields['name'] = nameController.text;
      request.fields['bkash_number'] = bkashAccountController.text;
      request.fields['bkash_transaction_id'] =
          bkashTransactionIdController.text;
      request.fields['phone_number'] = phoneController.text;
      request.fields['address'] = addressController.text;
      request.fields['district'] = districtController.text;
      request.fields['nid_or_birth_certificate_no'] = nidController.text;
      request.fields['date_of_birth'] = birthDateController.text;
      request.fields['area'] =
          selectedArea!; // Still string, but backend should allow it
      request.fields['player_category'] = selectedCategory!;
      request.fields['speciality'] = selectedSpeciality!;

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
      backgroundColor: Colors.white,
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
                    buildTextField(bkashAccountController, 'Bkash Account No'),
                    buildTextField(
                        bkashTransactionIdController, 'Bkash Transaction ID'),
                    buildTextField(nameController, 'Name'),
                    buildTextField(phoneController, 'Phone Number'),
                    buildTextField(addressController, 'Address'),
                    buildTextField(districtController, 'District'),
                    buildTextField(nidController, 'NID/Birth Certificate No'),
                    buildDatePickerField(birthDateController, 'Date of Birth'),

                    // buildTextField(
                    //     areaController, 'Area (Local/Semi-Local/Overseas)'),
                    buildDropdownField(
                      selectedValue: selectedArea,
                      items: areaOptions,
                      label: 'Area',
                      onChanged: (val) {
                        setState(() {
                          selectedArea = val;
                        });
                      },
                    ),

                    buildDropdownField<String>(
                      selectedValue: selectedCategory,
                      items: categoryOptions,
                      label: 'category',
                      onChanged: (val) =>
                          setState(() => selectedCategory = val),
                    ),

                    buildDropdownField<String>(
                      selectedValue: selectedSpeciality,
                      items: specialityOptions,
                      label: 'Speciality',
                      onChanged: (val) =>
                          setState(() => selectedSpeciality = val),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blueAccent),
                ),
                onPressed: submitForm,
                child: Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget buildDropdownField<T>({
    required T? selectedValue,
    required List<T> items,
    required String label,
    required void Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: DropdownButtonFormField<T>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        items: items
            .map((item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(item is Map
                      ? item['label'] // Map → show label
                      : item.toString()), // String/int → show itself
                ))
            .toList(),
        onChanged: onChanged,
        validator: (val) => val == null ? 'Required' : null,
      ),
    );
  }

  Widget buildDatePickerField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        onTap: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime(now.year - 18), // sensible default
            firstDate: DateTime(1900),
            lastDate: now,
          );
          if (picked != null) {
            controller.text =
                '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
          }
        },
      ),
    );
  }
}
