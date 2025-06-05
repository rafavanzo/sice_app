import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenQRCode extends StatefulWidget {
  const GenQRCode({Key? key}) : super(key: key);

  @override
  GenQRCodeState createState() => GenQRCodeState();
}

class GenQRCodeState extends State<GenQRCode> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext ctx) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            // margin: const EdgeInsets.all(20),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Enter Url:'),
            ),
          ),
          ElevatedButton(
              onPressed: () async {
                Navigator.push(context, MaterialPageRoute(builder: ((context) {
                  return QRImage(controller);
                })));
              },
              child: const Text('GENERATE QR'))
        ],
      ),
    );
  }
}

class QRImage extends StatelessWidget {
  final TextEditingController controller;

  const QRImage(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.white, size: 30),
          onPressed: () => Navigator.of(ctx).pop(),
        ),
      ),
      body: Center(
        child: QrImageView(
            data: controller.text,
            size: 280,
            embeddedImageStyle:
                QrEmbeddedImageStyle(size: const Size(100, 100))),
      ),
    );
  }
}
