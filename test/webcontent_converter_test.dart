import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webcontent_converter2/webcontent_converter2.dart';

void main() {
  const MethodChannel channel = MethodChannel('webcontent_converter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await WebcontentConverter2.platformVersion, '42');
    expect((await WebcontentConverter2.filePathToImage(path: '')).length, 0);
  });

  test("paper format", () {
    expect(PaperFormat.fromString("a5"), PaperFormat.a5);
  });
}
