import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class PdfViewerWidget extends StatefulWidget {
  final Uint8List? pdfImage;
  const PdfViewerWidget({
    Key? key,
    this.pdfImage,
  }) : super(key: key);

  @override
  State<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
  PdfController? controllerPdf;

  @override
  void initState() {
    controllerPdf = PdfController(
      document: PdfDocument.openData(widget.pdfImage!),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PdfView(
        builders: PdfViewBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: (_) => const Center(
            child: CupertinoActivityIndicator(
              radius: 12,
            ),
          ),
          pageLoaderBuilder: (_) => const Center(
            child: CupertinoActivityIndicator(
              radius: 12,
            ),
          ),
        ),
        scrollDirection: Axis.vertical,
        controller: controllerPdf!,
        onDocumentLoaded: (document) {},
        onPageChanged: (page) {},
      ),
    );
  }

  @override
  void dispose() {
    if (controllerPdf != null) {
      controllerPdf!.dispose();
    }
    super.dispose();
  }
}
