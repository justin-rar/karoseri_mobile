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
  final namaController = TextEditingController();

  // Variabel untuk menampung pilihan Role
  String? selectedRole;
  final List<String> roles = ['Project Manager', 'Direktur', 'Customer'];

  bool isLoading = false;

  Future<void> signUpProses() async {
    // if (selectedRole == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text("Pilih role terlebih dahulu!")),
    //   );
    //   return;
    // }
    if (namaController.text.isEmpty || selectedRole == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua kolom harus diisi!")));
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1. Daftar ke Supabase Auth
      final response = await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = response.user;

      if (user != null) {
        // 2. Simpan data tambahan ke tabel 'Users'
        await Supabase.instance.client.from('Users').insert({
          'id_user': user.id, // UUID dari Auth
          'email': emailController.text.trim(),
          'role': selectedRole, // Role yang dipilih di dropdown
          'nama': namaController.text.trim(), // Tambahkan ini
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registrasi Berhasil! Silakan Login."),
            ),
          );
          Navigator.pop(context); // Kembali ke halaman Login
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
      appBar: AppBar(title: const Text("Daftar Akun Baru")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.person_add, size: 80, color: Color(0xFFD4B07E)),
            const SizedBox(height: 20),
            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: "Nama Lengkap",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // DROPDOWN PILIHAN ROLE
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Daftar Sebagai",
                border: OutlineInputBorder(),
              ),
              value: selectedRole,
              items: roles.map((role) {
                return DropdownMenuItem(value: role, child: Text(role));
              }).toList(),
              onChanged: (val) => setState(() => selectedRole = val),
            ),

            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : signUpProses,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4B07E),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "DAFTAR SEKARANG",
                        style: TextStyle(color: Colors.black),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
