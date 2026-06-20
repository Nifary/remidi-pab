import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/article.dart';
import '../services/auth_service.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.article});
  final Article article;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isFavorite = false;
  bool _togglingFav = false;

  Future<void> _toggleFavorite() async {
    if (_togglingFav) return;
    setState(() => _togglingFav = true);
    try {
      if (_isFavorite) {
        await AuthService.removeFavorite(widget.article.id);
        setState(() => _isFavorite = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dihapus dari favorit'),
              backgroundColor: Colors.grey,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        await AuthService.addFavorite(
            widget.article.id, widget.article.title);
        setState(() => _isFavorite = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ditambahkan ke favorit ❤️'),
              backgroundColor: Color(0xFF00ACC1),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _togglingFav = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── App Bar with Hero image ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF0D1B2A),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _togglingFav
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _isFavorite ? Colors.red : Colors.white,
                            size: 22,
                          ),
                  ),
                  onPressed: _toggleFavorite,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: article.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: const Color(0xFF1A2B3C)),
                    errorWidget: (_, __, ___) => Container(
                      color: const Color(0xFF1A2B3C),
                      child: const Icon(Icons.rocket,
                          color: Colors.white24, size: 80),
                    ),
                  ),
                  // Bottom gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF0D1B2A).withOpacity(0.9),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Article body ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Publisher badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00ACC1).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFF00ACC1).withOpacity(0.5)),
                        ),
                        child: Text(
                          article.newsSite,
                          style: const TextStyle(
                              color: Color(0xFF00ACC1),
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatDate(article.publishedAt),
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    article.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Divider
                  Container(
                    height: 1,
                    color: Colors.white12,
                  ),
                  const SizedBox(height: 20),

                  // Summary
                  const Text('Ringkasan',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1)),
                  const SizedBox(height: 10),
                  Text(
                    article.summary.isNotEmpty
                        ? article.summary
                        : 'Tidak ada ringkasan tersedia.',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Favorite CTA
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _toggleFavorite,
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : const Color(0xFF00ACC1),
                      ),
                      label: Text(
                        _isFavorite ? 'Hapus dari Favorit' : 'Simpan ke Favorit',
                        style: TextStyle(
                            color: _isFavorite
                                ? Colors.red
                                : const Color(0xFF00ACC1)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: _isFavorite
                                ? Colors.red
                                : const Color(0xFF00ACC1)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
