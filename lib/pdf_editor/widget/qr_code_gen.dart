import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

class QrGeneration extends StatelessWidget {
  final double? sizeQrCode;
  final String? value;
  const QrGeneration({Key? key, this.sizeQrCode, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: sizeQrCode,
      height: sizeQrCode,
      child: SfBarcodeGenerator(
        value: value,
        symbology: QRCode(),
      ),
    );
  }
}
