import 'package:flutter/material.dart';
import 'package:webcontent_converter2/webcontent_converter2.dart';
import 'package:webcontent_converter_example/services/demo.dart';

class WebViewScreen extends StatefulWidget {
  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WebView Screen"),
      ),
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 400,
            child: WebViewWidget(Demo.getInvoiceContent()),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.replay_outlined),
        onPressed: _onPressed,
      ),
    );
  }

  _onPressed() {}
}
