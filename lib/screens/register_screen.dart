import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'login_screen.dart';

class RegisterScreen
    extends StatefulWidget {

  const RegisterScreen({
    super.key,
  });

  @override
  State<RegisterScreen>
  createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {

  final nameController =
  TextEditingController();

  final emailController =
  TextEditingController();

  final passwordController =
  TextEditingController();

  final confirmController =
  TextEditingController();

  bool hidePassword = true;

  bool hideConfirm = true;

  void register() {

    if (nameController
        .text
        .trim()
        .isEmpty) {

      showMessage(
        'Nama harus diisi.',
      );

      return;
    }

    if (emailController
        .text
        .trim()
        .isEmpty) {

      showMessage(
        'Email harus diisi.',
      );

      return;
    }

    if (passwordController
        .text
        .isEmpty) {

      showMessage(
        'Password harus diisi.',
      );

      return;
    }

    if (passwordController.text !=
        confirmController.text) {

      showMessage(
        'Password tidak sama.',
      );

      return;
    }

    showMessage(
      'Registrasi berhasil! Silakan login.',
    );

    Future.delayed(
      const Duration(
        milliseconds: 800,
      ),
          () {

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
            const LoginScreen(),
          ),
        );
      },
    );
  }

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

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
        const Text('Create Account'),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 20),

              const Text(
                'Create your account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Buat akun untuk mulai membangun kebiasaan fokusmu.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller:
                nameController,

                decoration:
                const InputDecoration(
                  labelText:
                  'Full Name',

                  prefixIcon:
                  Icon(
                    Icons.person_outline,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller:
                emailController,

                keyboardType:
                TextInputType.emailAddress,

                decoration:
                const InputDecoration(
                  labelText:
                  'Email',

                  prefixIcon:
                  Icon(
                    Icons.email_outlined,
                  ),
                ),
              ),

              const SizedBox(height: 16),

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

              const SizedBox(height: 16),

              TextField(
                controller:
                confirmController,

                obscureText:
                hideConfirm,

                decoration:
                InputDecoration(
                  labelText:
                  'Confirm Password',

                  prefixIcon:
                  const Icon(
                    Icons.lock_outline,
                  ),

                  suffixIcon:
                  IconButton(
                    onPressed: () {

                      setState(() {
                        hideConfirm =
                        !hideConfirm;
                      });

                    },

                    icon: Icon(
                      hideConfirm
                          ? Icons
                          .visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width:
                double.infinity,

                height: 54,

                child:
                ElevatedButton(
                  onPressed:
                  register,

                  child:
                  const Text(
                    'CREATE ACCOUNT',
                    style:
                    TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}