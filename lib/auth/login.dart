// Di bagian atas login_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:karoseri_mobile/dashboard/manager/dashboard_page.dart'; // Import file dashboard admin
import 'package:karoseri_mobile/dashboard/direktur/dashboard_direktur.dart'; // Import file dashboard direktur
import 'package:karoseri_mobile/dashboard/customer/dashboard_cust.dart'; // Import file dashboard direktur
import 'user.dart';
import 'regist.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // --- TAMBAHKAN DUA BARIS INI ---
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Future<void> loginProses() async {
  //   try {
  //     // 1. Login ke Auth Supabase
  //     final response = await Supabase.instance.client.auth.signInWithPassword(
  //       email: emailController.text,
  //       password: passwordController.text,
  //     );

  //     // 2. Ambil Role dari tabel 'Users'
  //     final data = await Supabase.instance.client
  //         .from('Users')
  //         .select()
  //         .eq('id_user', response.user!.id) // ID UUID otomatis dari login
  //         .single();

  //     UserModel user = UserModel.fromJson(data);

  //     // 3. Pindah Halaman sesuai Role
  //     if (user.role == 'Project Manager') {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => const DashboardPage()),
  //       );
  //     } else if (user.role == 'direktur') {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => const DashboardDirektur()),
  //       );
  //     } else {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => const DashboardCustomer()),
  //       );
  //     }
  //   } catch (e) {
  //     print("Error Login: $e");
  //     // Tampilkan pesan error ke user
  //   }
  // }

  Future<void> loginProses() async {
    // 1. Tampilkan loading agar user tahu aplikasi sedang bekerja
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 2. Login ke Auth Supabase
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: emailController.text
            .trim(), // Tambahkan .trim() untuk hapus spasi typo
        password: passwordController.text,
      );

      // 3. Ambil Role dari tabel 'Users'
      final data = await Supabase.instance.client
          .from('Users')
          .select()
          .eq('id_user', response.user!.id)
          .single();

      UserModel user = UserModel.fromJson(data);

      // Tutup dialog loading sebelum pindah halaman
      if (!mounted) return;
      Navigator.pop(context);

      // 4. Pindah Halaman sesuai Role (Gunakan Huruf Kecil agar Aman)
      String role = user.role.toLowerCase();

      if (role == 'project manager' || role == 'project manager') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      } else if (role == 'direktur') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardDirektur()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardCustomer()),
        );
      }
    } catch (e) {
      // Tutup loading jika error
      if (mounted) Navigator.pop(context);

      // Tampilkan pesan error ke layar HP user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal Masuk: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Karoseri"),
        backgroundColor: const Color(
          0xFFD4B07E,
        ), // Warna emas/cokelat seperti sasis
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shutter_speed, size: 80, color: Color(0xFFD4B07E)),
            const SizedBox(height: 20),

            // Input Email
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 15),

            // Input Password
            TextField(
              controller: passwordController,
              obscureText: true, // Biar password jadi bintang-bintang
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 25),

            // Tombol Login
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loginProses, // Memanggil fungsi backend kamu
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4B07E),
                  foregroundColor: Colors.black,
                ),
                child: const Text(
                  "MASUK",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
              child: const Text(
                "Belum punya akun? Daftar di sini",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
