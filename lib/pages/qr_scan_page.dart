import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:qr_code_reader/models/page.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:synchronized/synchronized.dart';
import 'package:url_launcher/url_launcher.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => QRScanPageState();
}

class QRScanPageState extends State<QRScanPage> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  Logger logger = Logger();
  QRViewController? controller;
  Decoration controlsDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8), color: Colors.white24);
  Barcode? barcode;
  Barcode? barcodeold;
  String? qrScanResult;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Future<void> reassemble() async {
    super.reassemble();
    /*
    if ( Platform.isAndroid) {
      await controller!.pauseCamera();
    }
    */
    controller!.resumeCamera();
  }

  void addPage(String pageContent) async {
    setState(() async {
      DatabaseHelper.instance.add(VisitedPage(content: pageContent));
    });
  }

  @override
  Widget build(BuildContext context) => SafeArea(
          child: Scaffold(
              body: Stack(alignment: Alignment.center, children: <Widget>[
        buildQRView(context),
        Positioned(
          bottom: 10,
          child: buildResult(),
        ),
        Positioned(
          top: 10,
          child: buildControlButtons(),
        ),
      ])));

  Widget buildQRView(BuildContext context) => QRView(
      key: qrKey,
      onQRViewCreated: onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Theme.of(context).colorScheme.secondary,
          borderWidth: 10,
          borderLength: 20,
          borderRadius: 10,
          cutOutSize: MediaQuery.of(context).size.width * 0.8));

  void onQRViewCreated(QRViewController controller) {
    setState(() => this.controller = controller);

    controller.scannedDataStream
        .listen((scanData) => setState(() => barcode = scanData));
  }

  Container buildResult() => Container(
      padding: const EdgeInsets.all(12),
      decoration: controlsDecoration,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (barcode != null && barcode != barcodeold) {
            //setState(() => barcodeold = barcode);
            barcodeold = barcode;

            _launchURL(barcode!.code);
            extractData(barcode!.code);
            return Text(
              //'Result : ${barcode!.code}',
              'Result : $qrScanResult',
              maxLines: 3,
            );
          } else {
            return Text(
              AppLocalizations.of(context)!.scanACode,
              maxLines: 3,
            );
          }
        },
      ));
  String titleHtmlTag = 'CGqCRe';

  Future<void> extractData(final String url) async {
    logger.d("-------------------url---------------------");
    logger.d(url);
    try {
      final response = await http.Client().get(Uri.parse(url));
      //Status Code 200 means response has been received successfully
      if (response.statusCode == 200) {
        var lock = Lock();
        await lock.synchronized(() async {
          logger.d("-----------------title-----------------------");

          var title = parser
              .parse(response.body)
              .getElementsByClassName("${titleHtmlTag}");
          String name = title.map((e) => e.text).join("");
          addPage(name);
          setState(() {
            qrScanResult = name;
          });
          logger.d(name);
        });
      } else {
        setState(() {
          qrScanResult = 'ERROR: ${response.statusCode}.';
        });
      }
    } catch (e) {
      logger.e(e);
    }
  }

  _launchURL(String url) async {
    //if (await   (url)) {
    logger.d("-------------------url---------------------");
    logger.d(url);
    await launch(url);
    //} else {
    //  throw 'Could not launch $url';
    //}
  }

  Widget buildControlButtons() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: controlsDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          IconButton(
            onPressed: () async {
              await controller?.toggleFlash();
              setState(() {});
            },
            icon: FutureBuilder<bool?>(
              future: controller?.getFlashStatus(),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  return Icon(snapshot.data! ? Icons.flash_on : Icons.flash_on);
                } else {
                  return Container();
                }
              },
            ),
          ),
          IconButton(
            onPressed: () async {
              await controller?.flipCamera();
              setState(() {});
            },
            icon: FutureBuilder(
              future: controller?.getCameraInfo(),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  return const Icon(Icons.switch_camera);
                } else {
                  return Container();
                }
              },
            ),
          ),
        ],
      ));
}
