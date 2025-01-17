import 'package:flutter/material.dart';
import '../../services/preset_info_service.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailReportDialog extends StatefulWidget {
  const EmailReportDialog({super.key});

  @override
  State<EmailReportDialog> createState() => _EmailReportDialogState();
}

class _EmailReportDialogState extends State<EmailReportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    }
    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Future<void> _sendReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final emailContent = await PresetInfoService.generatePresetReport();
      final subject = 'Long Line of Sight Examples Report';
      final body = '''
$emailContent

Visit us:
Website: https://www.beyondhorizoncalc.com
Twitter/X: https://x.com/BeyondHorizon_1

Thank you for your interest in Beyond Horizon Calculator!
''';

      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: _emailController.text,
        query: 'subject=${Uri.encodeComponent(subject)}'
            '&body=${Uri.encodeComponent(body)}',
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        if (mounted) Navigator.of(context).pop();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open email client'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error generating report'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Email Me Report'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your email address to receive a detailed report of long line of sight examples.',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'your.email@example.com',
              ),
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _sendReport,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Send Report'),
        ),
      ],
    );
  }
}
