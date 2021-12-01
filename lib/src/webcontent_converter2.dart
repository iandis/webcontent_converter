import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_logger/easy_logger.dart';
import 'package:flutter/services.dart' show MethodChannel, rootBundle;
import 'package:flutter/widgets.dart';
import 'package:puppeteer/puppeteer.dart' as pp;

import 'page.dart';
import 'webcontent_to_image_default.dart'
    if (dart.library.html) 'webcontent_to_image_web.dart' as _content_to_image;
import 'webview_widget.dart';

// ignore: avoid_classes_with_only_static_members
/// [WebcontentConverter2] will convert html, html file, web uri, into raw bytes image or pdf file
class WebcontentConverter2 {
  static const MethodChannel _channel = MethodChannel('webcontent_converter');

  static Future<String> get platformVersion async {
    final String version =
        await _channel.invokeMethod('getPlatformVersion') as String;
    return version;
  }

  /// ## `WebcontentConverter2.logger`
  /// `allow to pretty text`
  /// #### Example:
  /// ```
  /// WebcontentConverter2.logger('Your log text', level: LevelMessages.info);
  /// ```
  static final logger = EasyLogger(
    name: 'webcontent_converter',
    defaultLevel: LevelMessages.debug,
    enableBuildModes: [BuildMode.debug, BuildMode.profile, BuildMode.release],
    enableLevels: [
      LevelMessages.debug,
      LevelMessages.info,
      LevelMessages.error,
      LevelMessages.warning
    ],
  );

  /**
   * `IMAGE`
   * Convert html content, file, uri to image
   * Methods: [filePathToImage], [webUriToImage], [contentToImage]
   */

  /// ## `WebcontentConverter2.filePathToImage`
  /// `this method read content from file vai path then call contentToImage`
  /// #### Example:
  /// ```
  ///  var bytes = await WebcontentConverter2.filePathToImage(path: "assets/receipt.html");
  /// if (bytes.length > 0){
  ///   var dir = await getTemporaryDirectory();
  ///   var path = join(dir.path, "receipt.jpg");
  ///   File file = File(path);
  ///   await file.writeAsBytes(bytes);
  /// }
  /// ```
  static Future<Uint8List> filePathToImage({
    required String path,
    double duration = 2000,
    String? executablePath,
  }) async {
    Uint8List result = Uint8List.fromList([]);
    try {
      final String content = await rootBundle.loadString(path);

      result = await contentToImage(
        content: content,
        duration: duration,
        executablePath: executablePath,
      );
    } on Exception catch (e) {
      logger.error("[method:filePathToImage]: $e");
      throw Exception("Error: $e");
    }
    return result;
  }

  /// ## `WebcontentConverter2.webUriToImage`
  /// `This method read content from uri by using dio then call contentToImage`
  /// #### Example:
  /// ```
  /// var bytes = await WebcontentConverter2.webUriToImage(uri: "http://127.0.0.1:5500/example/assets/receipt.html");
  /// if (bytes.length > 0){
  ///   var dir = await getTemporaryDirectory();
  ///   var path = join(dir.path, "receipt.jpg");
  ///   File file = File(path);
  ///   await file.writeAsBytes(bytes);
  /// }
  /// ```
  static Future<Uint8List> webUriToImage({
    required String uri,
    double duration = 2000,
    String? executablePath,
  }) async {
    Uint8List result = Uint8List.fromList([]);
    try {
      final Response<dynamic> response = await Dio().get(uri);
      final String content = response.data.toString();
      result = await contentToImage(
        content: content,
        duration: duration,
        executablePath: executablePath,
      );
    } on Exception catch (e) {
      logger.error("[method:webUriToImage]: $e");
      throw Exception("Error: $e");
    }
    return result;
  }

  /// ## `WebcontentConverter2.contentToImage`
  /// `This method use html content directly to convert html to List<Int> image`
  /// ### Example:
  /// ```
  /// final content = Demo.getReceiptContent();
  /// var bytes = await WebcontentConverter2.contentToImage(content: content);
  /// if (bytes.length > 0){
  ///   var dir = await getTemporaryDirectory();
  ///   var path = join(dir.path, "receipt.jpg");
  ///   File file = File(path);
  ///   await file.writeAsBytes(bytes);
  /// }
  /// ```
  static Future<Uint8List> contentToImage({
    required String content,
    double duration = 2000,
    String? executablePath,
  }) {
    return _content_to_image.contentToImage(
      content: content,
      duration: duration,
      executablePath: executablePath,
    );
  }

  /**
   * `PDF`
   * Convert html content, file, uri to pdf
   * Methods: [filePathToPdf], [webUriToPdf], [contentToPDF]
   */

  /// ## `WebcontentConverter2.filePathToPdf`
  /// `This method read content from file vai path`
  /// #### Example:
  /// ```
  /// var dir = await getApplicationDocumentsDirectory();
  /// var savedPath = join(dir.path, "sample.pdf");
  /// var result = await WebcontentConverter2.filePathToPdf(
  ///   path: "assets/invoice.html",
  ///   savedPath: savedPath,
  ///   format: PaperFormat.a4,
  ///   margins: PdfMargins.px(top: 35, bottom: 35, right: 35, left: 35),
  /// );
  ///```

  static Future<String?> filePathToPdf({
    required String path,
    double duration = 2000,
    required String savedPath,
    PdfMargins? margins,
    PaperFormat format = PaperFormat.a4,
    String? executablePath,
  }) async {
    String? result;
    try {
      final String content = await rootBundle.loadString(path);
      result = await contentToPDF(
        content: content,
        duration: duration,
        savedPath: savedPath,
        margins: margins,
        format: format,
        executablePath: executablePath,
      );
    } on Exception catch (e) {
      logger.error("[method:filePathToPdf]: $e");
      throw Exception("Error: $e");
    }
    return result;
  }

  /// ## WebcontentConverter2.webUriToPdf
  /// `This method read content from uri by using dio`
  /// #### Example:
  /// ```
  /// var dir = await getApplicationDocumentsDirectory();
  /// var savedPath = join(dir.path, "sample.pdf");
  /// var result = await WebcontentConverter2.webUriToPdf(
  ///     uri: "http://127.0.0.1:5500/example/assets/invoice.html",
  ///     savedPath: savedPat,
  /// );
  /// ```
  static Future<String?> webUriToPdf({
    required String uri,
    double duration = 2000,
    required String savedPath,
    PdfMargins? margins,
    PaperFormat format = PaperFormat.a4,
    String? executablePath,
  }) async {
    String? result;
    try {
      final Response<dynamic> response = await Dio().get(uri);
      final String content = response.data.toString();
      result = await contentToPDF(
        content: content,
        duration: duration,
        savedPath: savedPath,
        margins: margins,
        format: format,
        executablePath: executablePath,
      );
    } on Exception catch (e) {
      logger.error("[method:webUriToImage]: $e");
      throw Exception("Error: $e");
    }
    return result;
  }

  /// ## `WebcontentConverter2.contentToPDF`
  /// `This method use html content directly to convert html to pdf then return path`
  /// #### Example:
  /// ```
  /// final content = Demo.getInvoiceContent();
  /// var dir = await getApplicationDocumentsDirectory();
  /// var savedPath = join(dir.path, "sample.pdf");
  /// var result = await WebcontentConverter2.contentToPDF(
  ///     content: content,
  ///     savedPath: savedPath,
  ///     format: PaperFormat.a4,
  ///     margins: PdfMargins.px(top: 55, bottom: 55, right: 55, left: 55),
  /// );
  /// ```
  static Future<String?> contentToPDF({
    required String content,
    double duration = 2000,
    required String savedPath,
    PdfMargins? margins,
    PaperFormat format = PaperFormat.a4,
    String? executablePath,
  }) async {
    final PdfMargins _margins = margins ?? PdfMargins.zero;
    final Map<String, dynamic> arguments = {
      'content': content,
      'duration': duration,
      'savedPath': savedPath,
      'margins': _margins.toMap(),
      'format': format.toMap(),
    };
    logger.info(arguments['savedPath'] as String);
    logger.info(arguments['margins'] as Map<String, num>);
    logger.info(arguments['format'] as Map<String, num>);
    String? result;
    try {
      if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
        logger.info("Desktop support");
        final pp.Browser browser = await pp.puppeteer.launch(
          executablePath: executablePath,
        );
        final pp.Page page = await browser.newPage();
        await page.setContent(
          content,
          wait: pp.Until.all([
            pp.Until.load,
            pp.Until.domContentLoaded,
            pp.Until.networkAlmostIdle,
            pp.Until.networkIdle,
          ]),
        );
        await page.pdf(
          format: pp.PaperFormat.inches(
            width: format.width,
            height: format.height,
          ),
          margins: pp.PdfMargins.inches(
            top: _margins.top,
            bottom: _margins.bottom,
            left: _margins.left,
            right: _margins.right,
          ),
          printBackground: true,
          output: File(savedPath).openWrite(),
        );
        await page.close();
        result = savedPath;
      } else if (Platform.isAndroid || Platform.isIOS) {
        logger.info("Mobile support");
        result = await _channel.invokeMethod(
          'contentToPDF',
          arguments,
        ) as String;
      } else {
        // todo web
        result = null;
      }
    } on Exception catch (e) {
      logger.error("[method:contentToPDF]: $e");
      throw Exception("Error: $e");
    }
    return result;
  }

  /// [WevView]
  static Widget webivew(String content, {double? width, double? height}) =>
      WebViewWidget(
        content,
        width: width,
        height: height,
      );
}
