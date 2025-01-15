import 'package:flutter/material.dart';

class SlidesViewer extends StatefulWidget {
  const SlidesViewer({super.key});

  @override
  State<SlidesViewer> createState() => _SlidesViewerState();
}

class _SlidesViewerState extends State<SlidesViewer> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'title': 'Earth\'s Curvature',
      'description': 'The Earth\'s curvature affects how far we can see. Objects beyond the horizon appear to sink below it due to the planet\'s spherical shape.',
      'image': 'assets/slides/curvature_basic.png',
    },
    {
      'title': 'Observer Height',
      'description': 'The higher your viewing position, the further you can see. This is because being elevated increases your distance to the horizon.',
      'image': 'assets/slides/observer_height.png',
    },
    {
      'title': 'Hidden Height (h2, XC)',
      'description': 'Objects beyond the horizon are partially hidden. The amount hidden depends on their distance and the observer\'s height.',
      'image': 'assets/slides/hidden_height.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Text(
                      _slides[index]['title']!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Image.asset(
                      _slides[index]['image']!,
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _slides[index]['description']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _slides.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
