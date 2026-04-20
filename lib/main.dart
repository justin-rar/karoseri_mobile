import 'package:flutter/material.dart';
import 'package:karoseri_mobile/auth/login.dart';
// Pastikan kamu sudah buat file ini atau sesuaikan namanya
import 'package:karoseri_mobile/auth/update_password_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Key untuk navigasi global
final navigatorKey = GlobalKey<NavigatorState>();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nsyttzfvlblsqmfzjyxf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5zeXR0emZ2bGJsc3FtZnpqeXhmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE4MTU4NjEsImV4cCI6MjA4NzM5MTg2MX0.fVfHyT3Xw4ioGrYmYS9mwB3zSuFxrdL8AdvIl0V3Cso',
  );

  runApp(const KaroseriApp());
}

class KaroseriApp extends StatefulWidget {
  const KaroseriApp({super.key});

  @override
  State<KaroseriApp> createState() => _KaroseriAppState();
}

class _KaroseriAppState extends State<KaroseriApp> {
  @override
  void initState() {
    super.initState();

    // Mendengarkan perubahan status Auth (seperti klik link reset password)
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;

      if (event == AuthChangeEvent.passwordRecovery) {
        // Jika link diklik, arahkan ke halaman Update Password
        // Pastikan route '/update-password' sudah ada atau gunakan MaterialPageRoute
        navigatorKey.currentState?.pushNamed('/update-password');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Pasang key di sini
      debugShowCheckedModeBanner: false,
      title: 'Manajemen Karoseri',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 150, 113, 99),
        ),
        useMaterial3: true,
      ),
      // Definisikan routes agar navigasi lebih mudah
      routes: {
        '/': (context) => const LoginPage(),
        '/update-password': (context) => const UpdatePasswordPage(),
      },
      initialRoute: '/',
    );
  }
}
