import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final namaController = TextEditingController();
  final noHpController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  // Samakan warna utama dengan Login Page
  final Color mainColor = const Color(0xFFD4B07E);

  Future<void> signUpProses() async {
    // 1. Validasi Kolom Kosong
    if (namaController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        noHpController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty) {
      _showSnackBar("Semua kolom harus diisi!", Colors.redAccent);
      return;
    }

    // 2. Validasi Konfirmasi Password
    if (passwordController.text != confirmPasswordController.text) {
      _showSnackBar(
        "Password dan Konfirmasi Password tidak cocok!",
        Colors.orange,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // 1. Daftar ke Supabase Auth
      final response = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        data: {
          'nama': namaController.text.trim(),
          'no_hp': noHpController.text.trim(),
          'role': 'Customer', // Otomatis Customer
        },
      );

      final user = response.user;

      if (user != null) {
        // 2. Simpan ke tabel 'Users'
        await supabase.from('Users').insert({
          'id_user': user.id,
          'email': emailController.text.trim(),
          'nama': namaController.text.trim(),
          'no_hp': noHpController.text.trim(),
          'role': 'Customer',
        });

        if (mounted) {
          _showSnackBar("Registrasi Berhasil! Silakan Login.", Colors.green);
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Error: ${e.toString()}", Colors.redAccent);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating, // Biar snackbar melayang modern
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    namaController.dispose();
    noHpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Latar belakang abu-abu terang
      appBar: AppBar(
        title: const Text(
          "Daftar Akun Baru",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Header Regist
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: mainColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 70,
                    color: mainColor,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "REGISTRASI",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Lengkapi formulir untuk membuat akun baru",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 35),

                // Kartu Formulir Registrasi
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: namaController,
                        label: "Nama Lengkap",
                        hint: "Contoh: Budi Santoso",
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 18),

                      _buildTextField(
                        controller: noHpController,
                        label: "Nomor WhatsApp",
                        hint: "Contoh: 081234567xxx",
                        icon: Icons.phone_android_rounded,
                        type: TextInputType.phone,
                      ),
                      const SizedBox(height: 18),

                      _buildTextField(
                        controller: emailController,
                        label: "Email",
                        hint: "nama@email.com",
                        icon: Icons.email_outlined,
                        type: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 18),

                      _buildTextField(
                        controller: passwordController,
                        label: "Password",
                        hint: "Minimal 6 karakter",
                        icon: Icons.lock_outline_rounded,
                        obscure: obscurePassword,
                        isPasswordField: true,
                        onToggleVisibility: () {
                          setState(() => obscurePassword = !obscurePassword);
                        },
                      ),
                      const SizedBox(height: 18),

                      _buildTextField(
                        controller: confirmPasswordController,
                        label: "Konfirmasi Password",
                        hint: "Tulis ulang password",
                        icon: Icons.lock_reset_rounded,
                        obscure: obscureConfirmPassword,
                        isPasswordField: true,
                        onToggleVisibility: () {
                          setState(
                            () => obscureConfirmPassword =
                                !obscureConfirmPassword,
                          );
                        },
                      ),
                      const SizedBox(height: 30),

                      // Tombol Daftar
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : signUpProses,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            disabledBackgroundColor: mainColor.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  "DAFTAR SEKARANG",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType type = TextInputType.text,
    bool isPasswordField = false,
    VoidCallback? onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey.withOpacity(0.5),
        ), // Memudarkan hintText
        prefixIcon: Icon(icon, color: mainColor),
        suffixIcon: isPasswordField
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: mainColor, width: 2),
        ),
      ),
    );
  }
}
