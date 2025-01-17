import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'widgets/calculator_form.dart';

void main() {
  // Disable DevTools in debug mode for web
  if (kDebugMode && kIsWeb) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
  
  runApp(const EarthCurvatureApp());
}

class EarthCurvatureApp extends StatelessWidget {
  const EarthCurvatureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beyond Horizon Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About Beyond Horizon Calculator'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: [
                Text('A horizon visibility calculator to show how much of a distant object is hidden by Earth\'s curvature'),
                SizedBox(height: 16),
                Text('Features:'),
                Text('• Real-time calculations'),
                Text('• Atmospheric refraction adjustment'),
                Text('• Metric measurements'),
                SizedBox(height: 16),
                Text('Created by: Your Name'),
                Text('Source code available on GitHub'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // Ensure all resources are cleaned up
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Clean up any pending resources
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // Image
                SizedBox(
                  height: 160, // Made slightly taller to accommodate text
                  width: double.infinity,
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.center,
                      heightFactor: 0.3,
                      child: Image.asset(
                        'assets/images/Kangchenjunga_520_km.jpg',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // Title and description overlay
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withOpacity(0.65),  // Darker on left
                        Colors.black.withOpacity(0.48),  // Current opacity in middle
                        Colors.black.withOpacity(0.05),  // Almost transparent on right
                      ],
                      stops: const [0.0, 0.5, 1.0],  // Even distribution
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Beyond Horizon Calculator',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'A horizon visibility calculator to show how much of a distant object is hidden by Earth\'s curvature',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // App bar actions (info button)
                Positioned(
                  top: 0,
                  right: 0,
                  child: SafeArea(
                    child: IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.white),
                      onPressed: _showAboutDialog,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Calculator
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        CalculatorForm(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
