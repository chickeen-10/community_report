import 'package:flutter/material.dart';
import '../../db/database_helper.dart';
import '../../models/user_model.dart';
import '../auth/register_screen.dart';
import '../admin/admin_home_screen.dart';
import '../user/user_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final UserModel? user = await DatabaseHelper.instance.login(
        email,
        password,
      );

      if (user != null) {
        if (user.email == "admin@email.com") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
          );
        } else {
          // Pass user name and email to UserHomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => UserHomeScreen(user: user)),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid email or password")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),

            // Icon
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue[100],
              child: const Icon(Icons.login, color: Colors.blue, size: 40),
            ),

            const SizedBox(height: 20),

            // Title
            const Text(
              "Community Report",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Sign in to your account",
              style: TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 35),

            // Email
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Email",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: "Enter your email",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Password
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Password",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Enter your password",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Sign In Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: isLoading ? null : login,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Sign In",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),

            const SizedBox(height: 15),

            // Create Account Text Button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account? ",
                  style: TextStyle(fontSize: 15),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    "Sign up",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Tips Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tips:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  SizedBox(height: 5),
                  Text("- Sign in to report community issues quickly."),
                  Text(
                    "- Admins can view all reports and mark them as resolved.",
                  ),
                  Text("- Stay engaged and help improve your community!"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
