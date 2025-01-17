import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../services/info_service.dart';

class InfoIcon extends StatelessWidget {
  final String infoKey;
  final double size;
  
  const InfoIcon({
    super.key,
    required this.infoKey,
    this.size = 20,
  });
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tight(Size(size + 8, size + 8)),
      icon: Icon(Icons.info_outline, size: size),
      onPressed: () async {
        final content = await InfoService.getInfo(infoKey);
        if (content != null && context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(content['title'] as String),
              content: SingleChildScrollView(
                child: content['content_type'] == 'html'
                    ? Html(data: content['content'] as String)
                    : Text(content['content'] as String),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
