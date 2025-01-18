import 'package:flutter/material.dart';
import 'widgets/calculator_form.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'models/menu_item.dart';
import 'widgets/dialogs/report_dialog.dart';

void main() {
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
  List<MenuItem> _menuItems = [];
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

  void _showMissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Our Mission'),
          content: const Text(
            'To provide an easy and accurate way to calculate what visible vs hidden height of beyond the horizon objects/structures',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
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

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $urlString')),
        );
      }
    }
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Contact Us'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => _launchURL('mailto:beyondhorizoncalc@gmail.com'),
              child: const Row(
                children: [
                  Icon(Icons.email),
                  SizedBox(width: 8),
                  Text('beyondhorizoncalc@gmail.com'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _launchURL('https://x.com/BeyondHorizon_1'),
              child: const Row(
                children: [
                  Icon(Icons.link),
                  SizedBox(width: 8),
                  Text('Follow us on X (Twitter)'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => const ReportDialog(),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/info/menu_items.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      setState(() {
        _menuItems = (jsonMap['menu_items'] as List)
            .map((item) => MenuItem.fromJson(item))
            .toList();
      });
    } catch (e) {
      debugPrint('Error loading menu items: $e');
    }
  }

  Future<void> _handleMenuSelection(MenuItem item) async {
    if (item.url != null) {
      await _launchURL(item.url!);
      return;
    }
    switch (item.id) {
      case 'about':
        _showAboutDialog();
        break;
      case 'mission':
        _showMissionDialog();
        break;
      case 'contact':
        _showContactDialog();
        break;
      case 'report':
        _showReportDialog();
        break;
    }
  }

  IconData _getIconData(String icon) {
    switch (icon) {
      case 'flag':
        return Icons.flag_outlined;
      case 'email':
        return Icons.email_outlined;
      case 'info':
        return Icons.info_outline;
      case 'share':
        return Icons.share;
      case 'list_alt':
        return Icons.list_alt;
      default:
        return Icons.error_outline;
    }
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
                // App bar actions (menu button)
                Positioned(
                  top: 0,
                  right: 0,
                  child: SafeArea(
                    child: PopupMenuButton<MenuItem>(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      itemBuilder: (BuildContext context) {
                        return _menuItems.map((MenuItem item) {
                          return PopupMenuItem<MenuItem>(
                            value: item,
                            child: ListTile(
                              leading: Icon(_getIconData(item.icon)),
                              title: Text(item.title),
                              subtitle: item.type == 'link'
                                  ? SelectionArea(
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () {
                                            if (item.url != null) {
                                              _launchURL(item.url!);
                                            }
                                          },
                                          child: Row(
                                            children: [
                                              if (item.id == 'social') ...[
                                                SvgPicture.asset(
                                                  'assets/icons/twitter_x.svg',
                                                  width: 14,
                                                  height: 14,
                                                  colorFilter: const ColorFilter.mode(
                                                    Colors.blue,
                                                    BlendMode.srcIn,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                              ],
                                              SelectableText(
                                                item.description,
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  decoration: TextDecoration.underline,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : Text(item.description),
                            ),
                          );
                        }).toList();
                      },
                      onSelected: (MenuItem item) {
                        _handleMenuSelection(item);
                      },
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
