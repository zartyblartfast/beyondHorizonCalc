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
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Beyond Horizon Calculator'),
            Text(
              'A horizon visibility calculator to show how much of a distant object is hidden by Earth\'s curvature',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showAboutDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Row(
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
      ),
    );
  }
}
