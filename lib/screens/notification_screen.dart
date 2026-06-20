import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static final List<Map<String, dynamic>> _notifications = [
    {
      'icon': Icons.rocket_launch,
      'color': const Color(0xFF00ACC1),
      'title': 'Peluncuran SpaceX berhasil!',
      'body': 'Falcon 9 berhasil mendarat kembali setelah orbit ke-47.',
      'time': '2 menit lalu',
    },
    {
      'icon': Icons.star,
      'color': Colors.amber,
      'title': 'Berita pilihan minggu ini',
      'body': 'Lihat 10 artikel terpopuler dari berbagai sumber internasional.',
      'time': '1 jam lalu',
    },
    {
      'icon': Icons.public,
      'color': Colors.blueAccent,
      'title': 'NASA umumkan misi baru',
      'body': 'Artemis IV dijadwalkan membawa manusia kembali ke Bulan.',
      'time': '3 jam lalu',
    },
    {
      'icon': Icons.science,
      'color': Colors.purpleAccent,
      'title': 'Teleskop James Webb menemukan exoplanet',
      'body': 'Planet baru ditemukan di zona layak huni bintang TRAPPIST-1.',
      'time': '5 jam lalu',
    },
    {
      'icon': Icons.satellite_alt,
      'color': Colors.greenAccent,
      'title': 'ISS perpanjang misi hingga 2030',
      'body': 'NASA dan mitra internasional sepakat memperpanjang operasional ISS.',
      'time': '1 hari lalu',
    },
    {
      'icon': Icons.newspaper,
      'color': const Color(0xFF00ACC1),
      'title': 'Update aplikasi tersedia',
      'body': 'Versi 1.1.0 menghadirkan mode gelap dan performa lebih cepat.',
      'time': '2 hari lalu',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi',
            style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final n = _notifications[index];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2B3C),
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(
                  color: n['color'] as Color,
                  width: 3,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (n['color'] as Color).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(n['icon'] as IconData,
                      color: n['color'] as Color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              n['title'] as String,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            n['time'] as String,
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        n['body'] as String,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 13, height: 1.4),
                      ),
                    ],
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
