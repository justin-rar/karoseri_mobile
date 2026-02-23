import 'package:flutter/material.dart';

class UpdateProgressPage extends StatelessWidget {
  const UpdateProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Progress"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Ini untuk tombol kembali
        ),
      ),
      body: const Center(child: Text("Ini Halaman Update Progress")),
    );
  }
}
