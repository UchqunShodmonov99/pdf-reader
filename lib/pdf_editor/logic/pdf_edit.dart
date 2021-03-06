import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart';

import '../bloc/edit_pdf_bloc.dart';

class PdfEdit {
  final double _a4Width = pdf.PdfPageFormat.a4.width;
  final double _a4Height = pdf.PdfPageFormat.a4.height;
  Future<bool> savePdf({
    required EditPdfSuccess? state,
    required GlobalKey? key,
    required BuildContext? context,
    required String? valueQrCode,
    required double? sizeQrCode,
    bool? back = false,
  }) async {
    final pdfFile = pw.Document();
    // final boundary =
    //     key!.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    // final image = await boundary?.toImage(pixelRatio: 10);
    // final byteData = await image?.toByteData(format: ImageByteFormat.png);
    // final imageBytes = byteData?.buffer.asUint8List();
    // if (imageBytes != null) {

    // }
    for (var item in state!.list!) {
      pdfFile.addPage(
        pw.Page(
          pageFormat: pdf.PdfPageFormat(
            getSize(key!).width,
            getSize(key).height,
          ),
          margin: pw.EdgeInsets.zero,
          build: (context) {
            return pw.Container(
              width: _a4Width,
              height: _a4Height,
              decoration: pw.BoxDecoration(
                image: pw.DecorationImage(
                  image: pw.MemoryImage(item.imageByte!),
                  fit: pw.BoxFit.contain,
                ),
              ),
              child: pw.Stack(
                children: [
                  if (item.isHaveQrCode!)
                    pw.Positioned(
                      top: getIndex(state).dy,
                      left: getIndex(state).dx,
                      child: pw.BarcodeWidget(
                        color: pdf.PdfColor.fromHex("#000000"),
                        barcode: pw.Barcode.qrCode(),
                        data: valueQrCode!,
                        height: sizeQrCode,
                        width: sizeQrCode,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      );
    }
    Uint8List _file = await pdfFile.save();
    if (back!) {
      Navigator.pop(context!, _file);
    } else {
      getPdfToImage(
        context: context,
        pdf: _file,
        currentIndex: state.currentIndex,
      );
    }
    return false;
  }

  Size getSize(GlobalKey key) {
    return key.currentContext!.size!;
  }

  Future<bool> getPdfToImage({
    BuildContext? context,
    Uint8List? pdf,
    int? currentIndex = 0,
    bool? isInit = false,
  }) async {
    List<QrCodePostion> _list = [];
    final document = await PdfDocument.openData(pdf!);

    for (int i = 1; i <= document.pagesCount; i++) {
      final page = await document.getPage(i);
      final pageImage = await page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: PdfPageImageFormat.png,
      );
      _list.add(QrCodePostion(
        imageByte: pageImage!.bytes,
        dx: 0,
        dy: 0,
        isHaveQrCode: false,
      ));
      await page.close();
    }
    if (isInit!) {
      BlocProvider.of<EditPdfBloc>(context!).add(InitPdf(
        list: _list,
        currentIndex: currentIndex,
      ));
    } else {
      BlocProvider.of<EditPdfBloc>(context!).add(ReloadPdf(
        list: _list,
        currentIndex: currentIndex,
      ));
    }

    document.close();
    return false;
  }

  QrCodePostion getIndex(EditPdfSuccess state) {
    return state.list![state.currentIndex!];
  }
}
