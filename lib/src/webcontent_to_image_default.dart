import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:puppeteer/puppeteer.dart' as pp;

import 'webcontent_converter2.dart';

Future<Uint8List> contentToImage({
  required String content,
  double duration = 2000,
  String? executablePath,
}) async {
  const MethodChannel _channel = MethodChannel('webcontent_converter');

  final Map<String, dynamic> arguments = {
    'content': content,
    'duration': duration
  };

  Uint8List results = Uint8List.fromList([]);
  try {
    if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      WebcontentConverter2.logger.info("Desktop support");
      final pp.Browser browser = await pp.puppeteer.launch(
        executablePath: executablePath,
      );
      final pp.Page page = await browser.newPage();
      await page.setContent(content, wait: pp.Until.load);
      await page.emulateMediaType(pp.MediaType.print);
      final num offsetHeight = await page.evaluate<num>(
        'document.body.offsetHeight',
      );
      final num offsetWidth = await page.evaluate<num>(
        'document.body.offsetWidth',
      );
      results = await page.screenshot(
        format: pp.ScreenshotFormat.png,
        clip: pp.Rectangle.fromPoints(
          const pp.Point(0, 0),
          pp.Point(offsetWidth, offsetHeight),
        ),
        fullPage: false,
        omitBackground: true,
      );
      await page.close();
    } else {
      WebcontentConverter2.logger.info("Mobile support");
      results = await _channel.invokeMethod(
        'contentToImage',
        arguments,
      ) as Uint8List;
    }
  } on Exception catch (e) {
    WebcontentConverter2.logger.error("[method:contentToImage]: $e");
    throw Exception("Error: $e");
  }
  return results;
}
