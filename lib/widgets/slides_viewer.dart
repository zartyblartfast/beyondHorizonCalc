import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui' as ui;

class SlidesViewer extends StatefulWidget {
  const SlidesViewer({super.key});

  @override
  State<SlidesViewer> createState() => _SlidesViewerState();
}

class _SlidesViewerState extends State<SlidesViewer> {
  late final String viewId;

  @override
  void initState() {
    super.initState();
    // Generate a unique ID for the iframe element
    viewId = 'slides-viewer-${DateTime.now().millisecondsSinceEpoch}';
    
    // Register the view factory with the unique ID
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) => html.IFrameElement()
        ..src = 'https://docs.google.com/presentation/d/e/2PACX-1vRXAF4baQhMYiahTk_WcoVoO9ldEhRSIQrWnZkm5s6_Dkm32YJYMHuPJXK3hzB3hOKhEVBDvENq9VPl/embed?start=false&loop=false'
        ..style.border = 'none'
        ..allowFullscreen = true
        ..allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
        ..width = '100%'
        ..height = '100%',
    );
  }

  @override
  Widget build(BuildContext context) {
    // Using 16:9 aspect ratio for the slides
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: SizedBox(
        width: double.infinity,
        child: HtmlElementView(viewType: viewId),
      ),
    );
  }
}
