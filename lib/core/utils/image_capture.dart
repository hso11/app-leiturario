import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

/// Captures a widget identified by [key] as a PNG file.
/// [pixelRatio] controls resolution (3.0 = ~1200x1500px for a 400x500 card).
Future<File?> captureWidgetToFile(
  GlobalKey key, {
  double pixelRatio = 3.0,
}) async {
  try {
    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;

    final bytes = byteData.buffer.asUint8List();
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/book_share_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  } catch (_) {
    return null;
  }
}
