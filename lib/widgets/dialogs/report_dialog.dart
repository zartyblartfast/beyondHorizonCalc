import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../services/preset_info_service.dart';
import 'dart:html' as html;

class ReportDialog extends StatefulWidget {
  const ReportDialog({super.key});

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  bool _isLoading = true;
  String _reportContent = '';

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    try {
      final content = await PresetInfoService.generatePresetReport();
      setState(() {
        _reportContent = content;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _reportContent = '<p>Error generating report.</p>';
          _isLoading = false;
        });
      }
    }
  }

  void _downloadHtmlFile() {
    final htmlDocument = '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
  body { font-family: Arial, sans-serif; margin: 20px; }
  h2 { font-size: 24px; margin: 16px 0; }
  h3 { font-size: 20px; margin: 14px 0; }
  h4 { font-size: 16px; margin: 12px 0; }
  p { margin: 8px 0; }
  .case { margin: 16px 0; padding: 8px; }
  .location-details { margin-left: 16px; }
  .conditions { margin: 8px 0; }
  .notes { margin: 8px 0; font-style: italic; }
  .footer { margin-top: 24px; border-top: 1px solid #ccc; padding-top: 16px; }
</style>
</head>
<body>
$_reportContent
</body>
</html>
''';

    // Create a blob from the HTML content
    final blob = html.Blob([htmlDocument], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    // Create a link element and trigger download
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'long_line_of_sight_report.html')
      ..click();

    // Clean up
    html.Url.revokeObjectUrl(url);
  }

  Future<void> _copyToClipboard() async {
    // Copy plain text version to clipboard
    await Clipboard.setData(ClipboardData(
      text: _reportContent
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll('&nbsp;', ' ')
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .trim(),
    ));

    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Report Copied'),
          content: const Text(
            'The report has been copied to your clipboard. For best formatting:\n\n'
            '1. Click "Download HTML" below\n'
            '2. Open the downloaded file in Microsoft Word\n\n'
            'Or to paste as plain text:\n'
            'Simply use Ctrl+V in any text editor.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                _downloadHtmlFile();
                Navigator.of(context).pop();
              },
              child: const Text('Download HTML'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Long Line of Sight Report'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Html(
                        data: _reportContent,
                        style: {
                          "body": Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                          ),
                          "h4": Style(
                            margin: Margins.only(bottom: 8),
                            fontSize: FontSize(18),
                          ),
                          "p": Style(
                            margin: Margins.only(bottom: 8),
                          ),
                          "ul": Style(
                            margin: Margins.only(left: 20),
                          ),
                          "li": Style(
                            margin: Margins.only(bottom: 16),
                          ),
                          ".preset-details": Style(
                            margin: Margins.only(left: 16, top: 4, bottom: 8),
                            fontSize: FontSize(14),
                            color: Colors.black87,
                          ),
                        },
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _copyToClipboard,
                  child: const Row(
                    children: [
                      Icon(Icons.copy),
                      SizedBox(width: 8),
                      Text('Copy to Clipboard'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
