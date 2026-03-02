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

  Future<void> signUpProses() async {
    // 1. Validasi Kolom Kosong
    if (namaController.text.isEmpty ||
        emailController.text.isEmpty ||
        noHpController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua kolom harus diisi!")));
      return;
    }

    // 2. Validasi Konfirmasi Password
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password dan Konfirmasi Password tidak cocok!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // 1. Daftar ke Supabase Auth
      // Role diset otomatis di 'data' (User Metadata)
      final response = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        data: {
          'nama': namaController.text.trim(),
          'no_hp': noHpController.text.trim(),
          'role': 'Customer', // <--- OTOMATIS CUSTOMER
        },
      );

      final user = response.user;

      if (user != null) {
        // 2. Simpan data ke tabel 'Users' di Database
        await supabase.from('Users').insert({
          'id_user': user.id,
          'email': emailController.text.trim(),
          'nama': namaController.text.trim(),
          'no_hp': noHpController.text.trim(),
          'role': 'Customer', // <--- OTOMATIS CUSTOMER
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registrasi Berhasil! Silakan Login."),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Daftar Akun Baru",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.person_add, size: 80, color: Color(0xFFD4B07E)),
            const SizedBox(height: 30),

            _buildTextField(namaController, "Nama Lengkap", Icons.person),
            const SizedBox(height: 15),

            _buildTextField(
              noHpController,
              "Nomor WhatsApp/HP",
              Icons.phone_android,
              type: TextInputType.phone,
            ),
            const SizedBox(height: 15),

            _buildTextField(
              emailController,
              "Email",
              Icons.email,
              type: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),

            _buildTextField(
              passwordController,
              "Password",
              Icons.lock,
              obscure: true,
            ),
            const SizedBox(height: 15),

            _buildTextField(
              confirmPasswordController,
              "Konfirmasi Password",
              Icons.lock_reset,
              obscure: true,
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : signUpProses,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4B07E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "DAFTAR SEKARANG",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }
}
