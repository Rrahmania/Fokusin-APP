import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // TAMBAHAN
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../widgets/bottom_nav.dart';
import 'register_screen.dart';
import 'admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool hidePassword = true;
  bool isLoading = false;

  // Inisialisasi Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email cannot be empty.';
    final email = value.trim();
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(email)) return 'Format email tidak valid';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
    if (value.length < 6) return 'Password minimal 6 karakter.';
    return null;
  }

  void login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      // 1. Login menggunakan Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // 2. Ambil nama user dari Firebase
      String name = userCredential.user?.displayName ?? 'User';

      // 3. Update local storage agar UI HomeScreen kamu kebaca
      await StorageService.setCurrentUser(
          name: name,
          email: emailController.text.trim()
      );

      if (!mounted) return;
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome, $name! 👋'), backgroundColor: AppTheme.darkTeal),
      );

      // 4. Cek apakah admin (kamu bisa buat logika khusus email admin di sini)
      if (emailController.text.trim().toLowerCase() == 'admin@fokusin.app') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BottomNav()));
      }

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);

      String message = 'Terjadi kesalahan.';
      if (e.code == 'user-not-found') {
        message = 'Akun tidak ditemukan. Silakan register.';
      } else if (e.code == 'wrong-password') {
        message = 'Password salah. Silakan coba lagi.';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid.';
      } else if (e.code == 'user-disabled') {
        message = 'Akun ini telah dinonaktifkan.';
      } else if (e.code == 'invalid-credential') {
        message = 'Email atau password salah.';
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

  void loginWithGoogle() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur Google Sign-In akan segera hadir!'), backgroundColor: Colors.orange),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.darkTeal),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Image.asset(
                    'assets/images/fokus.png',
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(color: AppTheme.lightTeal, borderRadius: BorderRadius.circular(30)),
                        child: Center(child: Icon(Icons.image_not_supported, size: 60, color: AppTheme.primary)),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Center(child: Text('Focus better. Live better.', style: TextStyle(color: AppTheme.txtGrey, fontSize: 14))),
                const SizedBox(height: 40),
                Text('Welcome back!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.txt)),
                const SizedBox(height: 8),
                Text('Log in to continue focusing...', style: TextStyle(color: AppTheme.txtGrey)),
                const SizedBox(height: 30),
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
                const SizedBox(height: 5),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => showMessage('Fitur lupa password akan segera hadir.'),
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
                    child: isLoading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('LOGIN'),
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
                _GoogleButton(onPressed: isLoading ? null : loginWithGoogle, text: 'Continue with Google'),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?", style: TextStyle(color: AppTheme.txt)),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  const _GoogleButton({required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
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
            Text(text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.txt)),
          ],
        ),
      ),
    );
  }
}