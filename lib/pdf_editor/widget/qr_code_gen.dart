import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

class QrGeneration extends StatelessWidget {
  final double? sizeQrCode;
  final String? value;
  const QrGeneration({Key? key, this.sizeQrCode, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarcodeWidget(
      barcode: Barcode.qrCode(
        errorCorrectLevel: BarcodeQRCorrectionLevel.high,
      ),
      height: sizeQrCode,
      width: sizeQrCode,
      data: value!,
    );
  }
}
