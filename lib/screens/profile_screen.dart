import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _uploadingPhoto = false;

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/register', (_) => false);
  }

  // ── Pilih & upload foto ────────────────────────────────────────────────────
  Future<void> _pickAndUpload(ImageSource source) async {
    Navigator.pop(context); // tutup bottom sheet

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 75,
      maxWidth: 800,
    );
    if (picked == null) return;

    setState(() => _uploadingPhoto = true);
    try {
      await AuthService.uploadProfilePhoto(File(picked.path));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil diperbarui ✅'),
            backgroundColor: Color(0xFF00ACC1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal upload: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  // ── Bottom sheet sumber foto ───────────────────────────────────────────────
  void _showPhotoSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2B3C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ganti Foto Profil',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Kamera
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00ACC1).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: Color(0xFF00ACC1)),
                ),
                title: const Text('Kamera',
                    style: TextStyle(color: Colors.white)),
                subtitle: const Text('Ambil foto baru',
                    style: TextStyle(color: Colors.white38, fontSize: 12)),
                onTap: () => _pickAndUpload(ImageSource.camera),
              ),
              // Galeri
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_rounded,
                      color: Colors.purpleAccent),
                ),
                title: const Text('Galeri',
                    style: TextStyle(color: Colors.white)),
                subtitle: const Text('Pilih dari galeri foto',
                    style: TextStyle(color: Colors.white38, fontSize: 12)),
                onTap: () => _pickAndUpload(ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: AuthService.profileStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00ACC1)),
            );
          }

          final data =
              snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final name = data['name'] ?? 'Pengguna';
          final email = data['email'] ??
              AuthService.currentUser?.email ??
              'user@email.com';
          final instagram = data['instagram'] ?? '';
          final photoUrl = data['photoUrl'] ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ── Avatar dengan tombol edit ──────────────────────────────
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    GestureDetector(
                      onTap: _uploadingPhoto ? null : _showPhotoSourceSheet,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 56,
                            backgroundColor: const Color(0xFF1A2B3C),
                            backgroundImage: photoUrl.isNotEmpty
                                ? NetworkImage(photoUrl)
                                : null,
                            child: photoUrl.isEmpty
                                ? Text(
                                    name.isNotEmpty
                                        ? name[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                        color: Color(0xFF00ACC1),
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                          // Overlay saat uploading
                          if (_uploadingPhoto)
                            Container(
                              width: 112,
                              height: 112,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black54,
                              ),
                              child: const CircularProgressIndicator(
                                color: Color(0xFF00ACC1),
                                strokeWidth: 3,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Tombol edit kecil
                    if (!_uploadingPhoto)
                      GestureDetector(
                        onTap: _showPhotoSourceSheet,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00ACC1),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF0D1B2A), width: 2),
                          ),
                          child: const Icon(Icons.edit,
                              size: 16, color: Colors.white),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),
                // Hint tap
                if (!_uploadingPhoto)
                  GestureDetector(
                    onTap: _showPhotoSourceSheet,
                    child: const Text(
                      'Tap foto untuk mengubah',
                      style: TextStyle(
                          color: Color(0xFF00ACC1),
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF00ACC1)),
                    ),
                  ),

                const SizedBox(height: 12),
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(email,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 14)),
                const SizedBox(height: 32),

                // Info cards
                _InfoCard(
                    icon: Icons.person_outline,
                    label: 'Nama Lengkap',
                    value: name),
                const SizedBox(height: 12),
                _InfoCard(
                    icon: Icons.email_outlined, label: 'Email', value: email),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.camera_alt_outlined,
                  label: 'Instagram',
                  value: instagram.isEmpty ? '-' : '@$instagram',
                ),
                const SizedBox(height: 40),

                // Log out
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Log Out',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Info Card ─────────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2B3C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00ACC1), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
