import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../db/database_report_helper.dart';
import '../../models/report_model.dart';

class CreateReportScreen extends StatefulWidget {
  final String loggedInUser; // email of logged-in user
  final VoidCallback? onReportAdded;

  const CreateReportScreen({
    super.key,
    required this.loggedInUser,
    this.onReportAdded,
  });

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final List<Map<String, dynamic>> categories = [
    {"label": "Infrastructure", "icon": Icons.handyman, "color": Colors.orange},
    {"label": "Safety", "icon": Icons.shield, "color": Colors.red},
    {"label": "Environment", "icon": Icons.eco, "color": Colors.green},
    {"label": "Public Space", "icon": Icons.apartment, "color": Colors.blue},
    {"label": "Traffic", "icon": Icons.directions_car, "color": Colors.amber},
    {"label": "Other", "icon": Icons.help_outline, "color": Colors.grey},
  ];

  int? _selectedIndex;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Widget _buildTextField(String label, String hint,
      {int maxLines = 1, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            hintText: hint,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Future<void> _submitReport() async {
    if (_isSubmitting) return;
    _isSubmitting = true;

    try {
      if (_selectedIndex == null ||
          _titleController.text.isEmpty ||
          _descController.text.isEmpty ||
          _selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please fill all required fields")));
        return;
      }

      final report = ReportModel(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: categories[_selectedIndex!]["label"],
        location: _locationController.text.trim(),
        imagePath: _selectedImage!.path,
        status: "Pending",
        date: DateTime.now(),
        user: widget.loggedInUser, // store creator's email
      );

      final id = await ReportDBHelper.instance.insertReport(report);

      if (id > 0) {
        widget.onReportAdded?.call();

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Report submitted successfully!")));

        setState(() {
          _selectedIndex = null;
          _selectedImage = null;
          _titleController.clear();
          _descController.clear();
          _locationController.clear();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error submitting report: $e")));
    } finally {
      _isSubmitting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Help improve your community by reporting issues",
                  style: TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 25),
              const Text("Category *",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1),
                itemBuilder: (context, index) {
                  final item = categories[index];
                  final isSelected = _selectedIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: isSelected
                                ? item["color"]
                                : item["color"].withOpacity(0.4),
                            width: isSelected ? 2.5 : 1.2),
                        color: isSelected
                            ? item["color"].withOpacity(0.1)
                            : Colors.transparent,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                              radius: 26,
                              backgroundColor: item["color"]
                                  .withOpacity(isSelected ? 0.25 : 0.15),
                              child: Icon(item["icon"],
                                  size: 28, color: item["color"])),
                          const SizedBox(height: 10),
                          Text(item["label"],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? item["color"]
                                      : Colors.black87)),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 25),
              const Text("Photo *",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _selectedImage == null
                      ? const Center(
                          child: Text("Tap to upload image",
                              style: TextStyle(color: Colors.black54)))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_selectedImage!,
                              fit: BoxFit.cover, width: double.infinity),
                        ),
                ),
              ),
              const SizedBox(height: 25),
              _buildTextField("Title *", "Enter report title",
                  controller: _titleController),
              const SizedBox(height: 20),
              _buildTextField("Description *", "Describe the issue",
                  maxLines: 4, controller: _descController),
              const SizedBox(height: 20),
              _buildTextField("Location", "Enter location",
                  controller: _locationController),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Submit Report",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
