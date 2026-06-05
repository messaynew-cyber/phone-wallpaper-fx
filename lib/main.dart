import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() => runApp(const WallpaperApp());

class WallpaperApp extends StatelessWidget {
  const WallpaperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallpaper FX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
      ),
      home: const WallpaperHome(),
    );
  }
}

// Curated high-quality wallpaper URLs (Unsplash, free to use)
const List<Map<String, String>> _wallpapers = [
  {
    'url': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1080&q=80',
    'title': 'Mountain Sunrise'
  },
  {
    'url': 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=1080&q=80',
    'title': 'Forest Path'
  },
  {
    'url': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=1080&q=80',
    'title': 'Sunlight Forest'
  },
  {
    'url': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=1080&q=80',
    'title': 'Mountain Lake'
  },
  {
    'url': 'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=1080&q=80',
    'title': 'Autumn Road'
  },
  {
    'url': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1080&q=80',
    'title': 'Tropical Beach'
  },
  {
    'url': 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1080&q=80',
    'title': 'Starry Mountains'
  },
  {
    'url': 'https://images.unsplash.com/photo-1501854140801-50d01698950b?w=1080&q=80',
    'title': 'Golden Field'
  },
  {
    'url': 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=1080&q=80',
    'title': 'Aurora Borealis'
  },
  {
    'url': 'https://images.unsplash.com/photo-1540206395-68808572332f?w=1080&q=80',
    'title': 'Purple Sky'
  },
  {
    'url': 'https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=1080&q=80',
    'title': 'Ocean Wave'
  },
  {
    'url': 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=1080&q=80',
    'title': 'Misty Valley'
  },
];

class WallpaperHome extends StatelessWidget {
  const WallpaperHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallpaper FX'),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _wallpapers.length,
        itemBuilder: (context, index) {
          final wp = _wallpapers[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WallpaperPreview(
                    url: wp['url']!,
                    title: wp['title']!,
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: wp['url']!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.grey[900]),
                    errorWidget: (_, __, ___) =>
                        Container(color: Colors.grey[900], child: const Icon(Icons.broken_image)),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                        ),
                      ),
                      child: Text(
                        wp['title']!,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class WallpaperPreview extends StatefulWidget {
  final String url;
  final String title;

  const WallpaperPreview({super.key, required this.url, required this.title});

  @override
  State<WallpaperPreview> createState() => _WallpaperPreviewState();
}

class _WallpaperPreviewState extends State<WallpaperPreview> {
  bool _loading = false;
  String _status = '';

  Future<void> _setWallpaper(int location) async {
    setState(() {
      _loading = true;
      _status = 'Downloading...';
    });

    try {
      final response = await http.get(Uri.parse(widget.url));
      if (response.statusCode != 200) {
        setState(() => _status = 'Failed to download');
        return;
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/wallpaper_temp.jpg');
      await file.writeAsBytes(response.bodyBytes);

      setState(() => _status = 'Applying...');
      await WallpaperManagerPlus().setWallpaper(file.path, location);

      setState(() {
        _loading = false;
        _status = 'Done! 🎉';
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _status = '');
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _status = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: CachedNetworkImage(
                imageUrl: widget.url,
                fit: BoxFit.contain,
                placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                errorWidget: (_, __, ___) =>
                    const Center(child: Icon(Icons.error, size: 48)),
              ),
            ),
          ),
          if (_status.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _status,
                style: const TextStyle(color: Colors.amber, fontSize: 16),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : () => _setWallpaper(WallpaperManagerPlus.HOME_SCREEN),
                      icon: const Icon(Icons.home),
                      label: const Text('Home'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : () => _setWallpaper(WallpaperManagerPlus.LOCK_SCREEN),
                      icon: const Icon(Icons.lock),
                      label: const Text('Lock'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : () => _setWallpaper(WallpaperManagerPlus.BOTH_SCREEN),
                      icon: const Icon(Icons.wallpaper),
                      label: const Text('Both'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
}
