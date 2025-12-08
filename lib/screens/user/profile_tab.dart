import 'dart:io';
import 'package:community_report/db/database_helper.dart';
import 'package:community_report/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../auth/login_screen.dart';

class ProfileTab extends StatefulWidget {
  final UserModel user;

  const ProfileTab({super.key, required this.user});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  late UserModel _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _loadLatestUser();
  }

  Future<void> _loadLatestUser() async {
    final db = DatabaseHelper.instance;
    final latestUser = await db.login(_user.email, _user.password);
    if (latestUser != null) {
      setState(() => _user = latestUser);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final updatedUser = UserModel(
        id: _user.id,
        name: _user.name,
        email: _user.email,
        password: _user.password,
        profileImage: pickedFile.path,
      );

      // Save to database
      await DatabaseHelper.instance.updateUser(updatedUser);

      // Update local state
      setState(() {
        _user = updatedUser;
        _imageFile = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayImage = _imageFile != null
        ? FileImage(File(_imageFile!.path))
        : (_user.profileImage != null
            ? FileImage(File(_user.profileImage!))
            : null);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: displayImage,
                  child: displayImage == null
                      ? const Icon(Icons.person, size: 55, color: Colors.grey)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _user.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "User Profile",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Account Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _infoRow(Icons.email_outlined, "Email", _user.email),
                      const SizedBox(height: 15),
                      _infoRow(Icons.person_outline, "Username", _user.name),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 28, color: Colors.blue),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
