class UserModel {
  final String id;
  final String email;
  final String role;
  final String nama;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.nama,
  });

  // Fungsi untuk mengubah data dari Supabase ke bentuk Object
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id_user'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'customer',
      nama: json['nama'] ?? 'Tanpa Nama',
    );
  }
}
