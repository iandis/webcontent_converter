import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'webcontent_converter2.dart';

// ignore: avoid_classes_with_only_static_members
Future<String> _toBlob() async {
  final html.CanvasElement canvas = html.CanvasElement();
  canvas.innerHtml = """
    <!DOCTYPE html>
      <html>
      <head>
      <style>
      body{
        width: 300px;
        height:300px;
        background-color:blue;
      }
      </style>
      </head>
      <body>


      <h1>My First Heading</h1>

      <p>My first paragraph.</p>

      </body>
      </html>
    """;
  canvas.context2D;
  final String image = canvas.toDataUrl();
  // var img = new html.ImageElement();
  // img.src = image;
  // html.document.body.children.add(img);
  return image;

  // final blob = await canvas.toBlob('image/jpeg', 1);
  // return blob;
}

Future<Uint8List?> _getBlobData(html.Blob blob) async {
  final completer = Completer<Uint8List?>();
  final reader = html.FileReader();
  reader.readAsArrayBuffer(blob);
  reader.onLoad.listen((_) => completer.complete(reader.result as Uint8List?));
  return completer.future;
}

Future<Uint8List> contentToImage({
  required String content,
  double duration = 2000,
  String? executablePath,
}) async {
  try {
    // TODO: web
    String blob = await _toBlob();
    blob = blob.replaceAll("data:image/png;base64,", "");

    return base64.decode(blob);
  } on Exception catch (e) {
    WebcontentConverter2.logger.error("[method:contentToImage]: $e");
    throw Exception("Error: $e");
  }
}
