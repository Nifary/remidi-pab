import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/article.dart';
import '../services/news_service.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Article> _articles = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    setState(() { _loading = true; _error = null; });
    try {
      final articles = await NewsService.fetchArticles();
      setState(() => _articles = articles);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF00ACC1),
          onRefresh: _loadArticles,
          child: CustomScrollView(
            slivers: [
              // AppBar
              SliverAppBar(
                floating: true,
                backgroundColor: const Color(0xFF0D1B2A),
                title: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF1565C0), Color(0xFF00ACC1)],
                        ),
                      ),
                      child: const Icon(Icons.rocket_launch_rounded,
                          size: 20, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    const Text('SpaceNews Core',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ],
                ),
              ),

              if (_error != null)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off,
                            color: Colors.white38, size: 48),
                        const SizedBox(height: 16),
                        Text(_error!,
                            style: const TextStyle(color: Colors.white54),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loadArticles,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00ACC1)),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_loading)
                SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeadlineSkeleton(),
                    const SizedBox(height: 8),
                    ...(List.generate(5, (_) => _buildCardSkeleton())),
                  ]),
                )
              else ...[
                // ── Headline Banner ──────────────────────────────────────
                if (_articles.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _HeadlineBanner(article: _articles.first),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Row(
                      children: const [
                        Text('Latest News',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                // ── News Feed ─────────────────────────────────────────────
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final article = _articles[index + 1];
                      return _NewsCard(
                        article: article,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => DetailScreen(article: article)),
                        ),
                      );
                    },
                    childCount:
                        (_articles.length - 1).clamp(0, _articles.length),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeadlineSkeleton() => Shimmer.fromColors(
        baseColor: const Color(0xFF1A2B3C),
        highlightColor: const Color(0xFF243447),
        child: Container(
          height: 220,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );

  Widget _buildCardSkeleton() => Shimmer.fromColors(
        baseColor: const Color(0xFF1A2B3C),
        highlightColor: const Color(0xFF243447),
        child: Container(
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
}

// ── Headline Banner ──────────────────────────────────────────────────────────
class _HeadlineBanner extends StatelessWidget {
  const _HeadlineBanner({required this.article});
  final Article article;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailScreen(article: article)),
      ),
      child: Container(
        margin: const EdgeInsets.all(16),
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: article.imageUrl,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: const Color(0xFF1A2B3C)),
                errorWidget: (_, __, ___) => Container(
                  color: const Color(0xFF1A2B3C),
                  child: const Icon(Icons.rocket, color: Colors.white24, size: 60),
                ),
              ),
            ),
            // Gradient overlay
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.85),
                    ],
                  ),
                ),
              ),
            ),
            // Badge + title
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00ACC1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('HEADLINE',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.3),
                  ),
                  const SizedBox(height: 4),
                  Text(article.newsSite,
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── News Card ────────────────────────────────────────────────────────────────
class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.article, required this.onTap});
  final Article article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2B3C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: article.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: const Color(0xFF243447), width: 80, height: 80),
                errorWidget: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: const Color(0xFF243447),
                  child: const Icon(Icons.image_not_supported,
                      color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.newsSite,
                    style: const TextStyle(
                        color: Color(0xFF00ACC1),
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.3),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(article.publishedAt),
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
