import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/register', (_) => false);
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

          final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final name = data['name'] ?? 'Pengguna';
          final email = data['email'] ??
              AuthService.currentUser?.email ??
              'user@email.com';
          final instagram = data['instagram'] ?? '-';
          final photoUrl = data['photoUrl'] ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Profile photo
                CircleAvatar(
                  radius: 56,
                  backgroundColor: const Color(0xFF1A2B3C),
                  backgroundImage:
                      photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                  child: photoUrl.isEmpty
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                              color: Color(0xFF00ACC1),
                              fontSize: 40,
                              fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 32),

                // Info cards
                _InfoCard(
                  icon: Icons.person_outline,
                  label: 'Nama Lengkap',
                  value: name,
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: email,
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.camera_alt_outlined,
                  label: 'Instagram',
                  value: instagram.isEmpty ? '-' : '@$instagram',
                ),
                const SizedBox(height: 40),

                // Log out button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _logout(context),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      const TextStyle(color: Colors.white38, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
