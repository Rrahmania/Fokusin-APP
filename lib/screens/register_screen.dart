import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 1. TAMBAHAN IMPORT FIRESTORE
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool hidePassword = true;
  bool hideConfirm = true;
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'The name cannot be empty.';
    if (value.trim().length < 2) return 'Name must be at least 2 characters long.';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email cannot be empty.';
    final email = value.trim();
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(email)) return 'Invalid email format';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password cannot be empty.';
    if (value.length < 6) return 'Password must be at least 6 characters long.';
    return null;
  }

  String? validateConfirm(String? value) {
    if (value == null || value.isEmpty) return 'Confirmation password cannot be empty';
    if (value != passwordController.text) return 'Passwords do not match';
    return null;
  }

  void register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      // 1. Buat akun di Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // 2. Simpan nama user ke profil Firebase Auth
      await userCredential.user?.updateDisplayName(nameController.text.trim());

      // 3. SIMPAN DATA KE CLOUD FIRESTORE (GUDANG DATABASE)
      // Data ini yang nanti akan muncul di menu Firestore Console
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'xp': 0, // XP awal
        'streak': 0, // Streak awal
        'created_at': FieldValue.serverTimestamp(), // Waktu pendaftaran
      });

      // 4. Simpan ke local storage (biar UI HomeScreen kamu yang lama tetap jalan)
      await StorageService.setCurrentUser(
          name: nameController.text.trim(),
          email: emailController.text.trim()
      );

      if (!mounted) return;
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Registration successful! Please log in.'), backgroundColor: AppTheme.darkTeal),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      });

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);

      String message = 'Terjadi kesalahan.';
      if (e.code == 'weak-password') {
        message = 'Password terlalu lemah (minimal 6 karakter).';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email sudah terdaftar. Silakan gunakan email lain.';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Fitur Google Sign-In bisa ditambahkan nanti
  void registerWithGoogle() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur Google Sign-In akan segera hadir!'), backgroundColor: Colors.orange),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/fokus.png',
                    width: 130,
                    height: 130,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(color: AppTheme.lightTeal, borderRadius: BorderRadius.circular(25)),
                        child: Center(child: Icon(Icons.image_not_supported, size: 40, color: AppTheme.primary)),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 15),
                Text('Create your account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.txt)),
                const SizedBox(height: 8),
                Text('Buat akun untuk mulai membangun kebiasaan fokusmu.', style: TextStyle(color: AppTheme.txtGrey)),
                const SizedBox(height: 30),
                TextFormField(
                  controller: nameController,
                  validator: validateName,
                  decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  validator: validatePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => hidePassword = !hidePassword),
                      icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmController,
                  obscureText: hideConfirm,
                  validator: validateConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => hideConfirm = !hideConfirm),
                      icon: Icon(hideConfirm ? Icons.visibility_off : Icons.visibility),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : register,
                    child: isLoading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('CREATE ACCOUNT'),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Divider(color: AppTheme.border, thickness: 1.5)),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('atau', style: TextStyle(color: AppTheme.txtGrey, fontSize: 13))),
                    Expanded(child: Divider(color: AppTheme.border, thickness: 1.5)),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: isLoading ? null : registerWithGoogle,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.txt,
                      backgroundColor: AppTheme.card,
                      side: BorderSide(color: AppTheme.border, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/google_logo.png',
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.g_mobiledata, size: 30, color: Color(0xFF4285F4));
                          },
                        ),
                        const SizedBox(width: 8),
                        Text('Sign up with Google', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.txt)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Sudah punya akun?', style: TextStyle(color: AppTheme.txt)),
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Login')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}