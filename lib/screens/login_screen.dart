import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../widgets/bottom_nav.dart';
import 'register_screen.dart';

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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // VALIDASI EMAIL — SIMPLE
  // ============================================================
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email cannot be empty.';
    }
    final email = value.trim();
    // Cukup cek ada @ dan ada titik setelah @
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(email)) {
      return 'Couldn\'t find this account';
    }
    return null;
  }

  // ============================================================
  // VALIDASI PASSWORD — MINIMAL 6, BEBAS
  // ============================================================
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    return null;
  }

  // ============================================================
  // LOGIN
  // ============================================================
  void login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    final name = await StorageService.loginUser(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (name == null) {
      // Cek apakah email ada di sistem
      final emailExists = await StorageService.isEmailRegistered(
        emailController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            emailExists
                ? 'Wrong password'
                : 'Couldn\'t find this account',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Welcome, $name! 👋'),
        backgroundColor: AppTheme.darkTeal,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const BottomNav()),
    );
  }

  // ============================================================
  // LOGIN GOOGLE
  // ============================================================
  void loginWithGoogle() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));

    const googleName = 'Google User';
    const googleEmail = 'user@gmail.com';

    await StorageService.registerUser(
      name: googleName,
      email: googleEmail,
      password: 'google123',
    );
    await StorageService.setCurrentUser(
      name: googleName,
      email: googleEmail,
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Google login successful! 🎉'),
        backgroundColor: AppTheme.darkTeal,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const BottomNav()),
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

                // LOGO
                Center(
                  child: Image.asset(
                    'assets/images/fokus.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTeal,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Icon(Icons.image_not_supported,
                              size: 60, color: AppTheme.darkTeal),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),

                Center(
                  child: Text(
                    'Focus better. Live better.',
                    style: TextStyle(color: AppTheme.txtGrey, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 40),

                Text(
                  'Welcome back!',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.txt),
                ),
                const SizedBox(height: 8),
                Text('Log in to continue focusing..',
                    style: TextStyle(color: AppTheme.txtGrey)),
                const SizedBox(height: 30),

                // EMAIL
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // PASSWORD
                TextFormField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  validator: validatePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => hidePassword = !hidePassword),
                      icon: Icon(hidePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                    ),
                  ),
                ),
                const SizedBox(height: 5),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => showMessage(
                      'The password reset feature will be available once the backend is added..',
                    ),
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 15),

                // LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
                    child: isLoading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                        : const Text('LOGIN',
                        style:
                        TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),

                // DIVIDER
                Row(
                  children: [
                    Expanded(
                        child: Divider(
                            color: AppTheme.txtGrey.withOpacity(0.3))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('atau',
                          style: TextStyle(
                              color: AppTheme.txtGrey, fontSize: 13)),
                    ),
                    Expanded(
                        child: Divider(
                            color: AppTheme.txtGrey.withOpacity(0.3))),
                  ],
                ),
                const SizedBox(height: 20),

                // GOOGLE LOGIN
                _GoogleButton(
                  onPressed: isLoading ? null : loginWithGoogle,
                  text: 'Continue with Google',
                ),
                const SizedBox(height: 25),

                // REGISTER LINK
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?",
                        style: TextStyle(color: AppTheme.txt)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen()),
                        );
                      },
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
          side: BorderSide(
              color: AppTheme.txtGrey.withOpacity(0.3), width: 1.2),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.g_mobiledata,
                size: 30, color: Color(0xFF4285F4)),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.txt,
              ),
            ),
          ],
        ),
      ),
    );
  }
}