import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final emailController =
  TextEditingController();

  final passwordController =
  TextEditingController();

  bool hidePassword = true;

  bool isLoading = false;

  // ==========================================================
  // LOGIN
  // ==========================================================

  void login() async {

    if (emailController
        .text
        .trim()
        .isEmpty ||
        passwordController
            .text
            .trim()
            .isEmpty) {

      showMessage(
        'Email dan password harus diisi.',
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    await Future.delayed(
      const Duration(
        milliseconds: 700,
      ),
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const BottomNav(),
      ),
    );
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void showMessage(
      String message) {

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        AppTheme.darkTeal,
      ),
    );
  }

  // ==========================================================
  // UI
  // ==========================================================

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 35),

              // LOGO
              Center(
                child: Container(
                  width: 82,
                  height: 82,

                  decoration:
                  BoxDecoration(
                    color:
                    AppTheme.primaryTeal,
                    borderRadius:
                    BorderRadius.circular(
                      25,
                    ),
                  ),

                  child:
                  const Icon(
                    Icons.timer_rounded,
                    color: Colors.white,
                    size: 46,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  'Fokusin',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight:
                    FontWeight.bold,
                    color:
                    AppTheme.darkTeal,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              const Center(
                child: Text(
                  'Focus better. Live better.',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 50),

              const Text(
                'Welcome back!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Login untuk melanjutkan fokusmu.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 30),

              // EMAIL
              TextField(
                controller:
                emailController,

                keyboardType:
                TextInputType.emailAddress,

                decoration:
                const InputDecoration(
                  labelText: 'Email',

                  prefixIcon:
                  Icon(
                    Icons
                        .email_outlined,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // PASSWORD
              TextField(
                controller:
                passwordController,

                obscureText:
                hidePassword,

                decoration:
                InputDecoration(
                  labelText:
                  'Password',

                  prefixIcon:
                  const Icon(
                    Icons.lock_outline,
                  ),

                  suffixIcon:
                  IconButton(
                    onPressed: () {

                      setState(() {
                        hidePassword =
                        !hidePassword;
                      });

                    },

                    icon: Icon(
                      hidePassword
                          ? Icons
                          .visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 5),

              Align(
                alignment:
                Alignment.centerRight,

                child: TextButton(
                  onPressed: () {
                    showMessage(
                      'Fitur reset password akan tersedia setelah backend ditambahkan.',
                    );
                  },

                  child:
                  const Text(
                    'Forgot Password?',
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // LOGIN BUTTON
              SizedBox(
                width:
                double.infinity,
                height: 54,

                child:
                ElevatedButton(
                  onPressed:
                  isLoading
                      ? null
                      : login,

                  child:
                  isLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child:
                    CircularProgressIndicator(
                      strokeWidth:
                      2,
                      color:
                      Colors.white,
                    ),
                  )
                      : const Text(
                    'LOGIN',
                    style:
                    TextStyle(
                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // REGISTER
              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,

                children: [

                  const Text(
                    "Don't have an account?",
                  ),

                  TextButton(
                    onPressed: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const RegisterScreen(),
                        ),
                      );

                    },

                    child:
                    const Text(
                      'Register',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}