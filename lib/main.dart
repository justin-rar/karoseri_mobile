import 'package:flutter/material.dart';
import 'package:karoseri_mobile/auth/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nsyttzfvlblsqmfzjyxf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5zeXR0emZ2bGJsc3FtZnpqeXhmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE4MTU4NjEsImV4cCI6MjA4NzM5MTg2MX0.fVfHyT3Xw4ioGrYmYS9mwB3zSuFxrdL8AdvIl0V3Cso',
  );

  runApp(const KaroseriApp());
}

class KaroseriApp extends StatelessWidget {
  const KaroseriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Manajemen Karoseri',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 150, 113, 99),
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
