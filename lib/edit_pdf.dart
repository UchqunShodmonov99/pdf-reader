import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_file/internet_file.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:test_pdf/device_info.dart';
import 'package:test_pdf/edit_pdf/edit_pdf_bloc.dart';

class PdfEditor extends StatefulWidget {
  const PdfEditor({Key? key}) : super(key: key);

  @override
  State<PdfEditor> createState() => _PdfEditorState();
}

class _PdfEditorState extends State<PdfEditor>
    with AutomaticKeepAliveClientMixin {
  final List<Uint8List> _listImage = [];
  final String url = 'www.syncfusion.com';

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    getPdfToImage();
    super.initState();
  }

  @override
  void dispose() {
    if (DeviceInfo().isPhone()) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      body: _listImage.isNotEmpty
          ? BlocBuilder<EditPdfBloc, EditPdfState>(
              builder: (context, state) {
                if (state is EditPdfSuccess) {
                  return Column(
                    children: [
                      Expanded(
                        child: PdfItem(
                          url: url,
                        ),
                      ),
                      _pageChange(state, context),
                    ],
                  );
                } else {
                  return const CupertinoActivityIndicator();
                }
              },
            )
          : const Center(
              child: CupertinoActivityIndicator(),
            ),
    );
  }

  Widget _pageChange(EditPdfSuccess state, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(
          height: 1,
          thickness: 1,
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 30, right: 30),
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: state.list![state.currentIndex!].isHaveQrCode!
                    ? null
                    : () {
                        if (state.currentIndex! - 1 >= 0) {
                          BlocProvider.of<EditPdfBloc>(context).add(
                            ChangePdf(
                              item: QrCodePostion(
                                dx: state.list![state.currentIndex!].dx,
                                dy: state.list![state.currentIndex!].dy,
                                isHaveQrCode: false,
                                imageByte:
                                    state.list![state.currentIndex!].imageByte,
                              ),
                              index: state.currentIndex! - 1,
                            ),
                          );
                        }
                      },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xFF313234),
                  size: 20,
                ),
              ),
              const SizedBox(
                width: 30,
              ),
              Text((state.currentIndex! + 1).toString()),
              const SizedBox(
                width: 30,
              ),
              IconButton(
                onPressed: state.list![state.currentIndex!].isHaveQrCode!
                    ? null
                    : () {
                        if (state.currentIndex! < state.list!.length - 1) {
                          BlocProvider.of<EditPdfBloc>(context).add(
                            ChangePdf(
                              item: QrCodePostion(
                                dx: state.list![state.currentIndex!].dx,
                                dy: state.list![state.currentIndex!].dy,
                                isHaveQrCode: false,
                                imageByte:
                                    state.list![state.currentIndex!].imageByte,
                              ),
                              index: state.currentIndex! + 1,
                            ),
                          );
                        }
                      },
                icon: Transform.rotate(
                  angle: math.pi,
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Color(0xFF313234),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void getPdfToImage() async {
    List<QrCodePostion> _list = [];
    final document = await PdfDocument.openData(
      await InternetFile.get(
        'https://juventudedesporto.cplp.org/files/sample-pdf_9359.pdf',
      ),
    );

    for (int i = 1; i <= document.pagesCount; i++) {
      final page = await document.getPage(i);
      final pageImage = await page.render(
        width: page.width,
        height: page.height,
      );
      _listImage.add(pageImage!.bytes);
      _list.add(QrCodePostion(
        imageByte: pageImage.bytes,
        dx: 100,
        dy: 100,
        isHaveQrCode: false,
      ));
      await page.close();
    }
    BlocProvider.of<EditPdfBloc>(context).add(InitilPdf(list: _list));
    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;
}

class PdfItem extends StatefulWidget {
  final String? url;
  const PdfItem({
    Key? key,
    this.url,
  }) : super(key: key);
  @override
  _PdfItemState createState() => _PdfItemState();
}

class _PdfItemState extends State<PdfItem> {
  final double _sizeQrCode = 85;
  final double _a4Width = pdf.PdfPageFormat.a4.width;
  final double _a4Height = pdf.PdfPageFormat.a4.height;
  final _key = GlobalKey();

  double getWidth() {
    return MediaQuery.of(context).size.height * _a4Width / _a4Height;
  }

  double getHeight() {
    return MediaQuery.of(context).size.height;
  }

  Widget _appBar(EditPdfSuccess state, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 30, right: 10, left: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.close,
                  color: Color(0xFF313234),
                  size: 30,
                ),
              ),
              const Spacer(),
              if (state.list![state.currentIndex!].isHaveQrCode == false)
                IconButton(
                  onPressed: () {
                    BlocProvider.of<EditPdfBloc>(context).add(
                      ChangePdf(
                        item: QrCodePostion(
                          dx: state.list![state.currentIndex!].dx,
                          dy: state.list![state.currentIndex!].dy,
                          isHaveQrCode: true,
                          imageByte: state.list![state.currentIndex!].imageByte,
                        ),
                        index: state.currentIndex!,
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.qr_code_2_sharp,
                    color: Color(0xFF313234),
                    size: 30,
                  ),
                ),
              if (state.list![state.currentIndex!].isHaveQrCode!)
                IconButton(
                  onPressed: () {
                    savePdf(state);
                  },
                  icon: const Icon(
                    Icons.done,
                    color: Color(0xFF313234),
                    size: 30,
                  ),
                ),
            ],
          ),
        ),
        const Divider(
          height: 1,
          thickness: 1,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: ((context, orientation) {
      return BlocBuilder<EditPdfBloc, EditPdfState>(
        builder: (context, state) {
          if (state is EditPdfSuccess) {
            return Column(
              children: [
                _appBar(state, context),
                Expanded(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.all(15),
                      child: RepaintBoundary(
                        key: _key,
                        child: Container(
                          width: _a4Width,
                          height: _a4Height,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            image: DecorationImage(
                              image: MemoryImage(
                                state.list![state.currentIndex!].imageByte!,
                              ),
                            ),
                          ),
                          child: state.list![state.currentIndex!]
                                      .isHaveQrCode ==
                                  false
                              ? Container()
                              : GestureDetector(
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: state
                                            .list![state.currentIndex!].dy!,
                                        left: state
                                            .list![state.currentIndex!].dx!,
                                        child: QrGeneration(
                                          sizeQrCode: _sizeQrCode,
                                          value: widget.url,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onHorizontalDragUpdate: (drage) {
                                    double top =
                                        state.list![state.currentIndex!].dy!;
                                    double left =
                                        state.list![state.currentIndex!].dx!;
                                    double height = _a4Height;
                                    double width = _a4Width;
                                    double _dx = drage.localPosition.dx -
                                        _sizeQrCode / 2;
                                    double _dy = drage.localPosition.dy -
                                        _sizeQrCode / 2;

                                    if (_dy >= 0 &&
                                        (_dy + _sizeQrCode) <= height) {
                                      top = _dy;
                                    } else if (_dy + _sizeQrCode > height) {
                                      if (DeviceInfo().isPhone() == false &&
                                          orientation ==
                                              Orientation.landscape) {
                                        top = height - _sizeQrCode * 2.1;
                                      } else {
                                        top = height - _sizeQrCode;
                                      }
                                    } else {
                                      top = 0;
                                    }
                                    if (_dx >= 0 &&
                                        _dx + calculateWidth(_sizeQrCode) <=
                                            width &&
                                        (_key.currentContext!.size!.width >=
                                            _dx +
                                                calculateWidth(_sizeQrCode))) {
                                      left = _dx;
                                    } else if (_dx +
                                                calculateWidth(_sizeQrCode) >
                                            width &&
                                        (_key.currentContext!.size!.width >
                                            _dx +
                                                calculateWidth(_sizeQrCode))) {
                                      left = width - _sizeQrCode;
                                    } else if (_dx + _sizeQrCode >= width &&
                                        (_key.currentContext!.size!.width <
                                            _dx +
                                                calculateWidth(_sizeQrCode))) {
                                      left = _key.currentContext!.size!.width -
                                          calculateWidth(_sizeQrCode);
                                    } else {
                                      left = 0;
                                    }
                                    BlocProvider.of<EditPdfBloc>(context).add(
                                      ChangePdf(
                                        item: QrCodePostion(
                                          dx: left,
                                          dy: top,
                                          isHaveQrCode: true,
                                          imageByte: state
                                              .list![state.currentIndex!]
                                              .imageByte,
                                        ),
                                        index: state.currentIndex!,
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const CupertinoActivityIndicator();
          }
        },
      );
    }));
  }

  void savePdf(EditPdfSuccess state) async {
    final pdfFile = pw.Document();
    final boundary =
        _key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    final image = await boundary?.toImage();
    final byteData = await image?.toByteData(format: ImageByteFormat.png);
    final imageBytes = byteData?.buffer.asUint8List();

    for (var item in state.list!) {
      pdfFile.addPage(
        pw.Page(
          pageFormat: pdf.PdfPageFormat.a4,
          build: (context) {
            return pw.Expanded(
              child: pw.Container(
                padding: pw.EdgeInsets.zero,
                margin: pw.EdgeInsets.zero,
                width: getWidth(),
                height: getHeight(),
                decoration: pw.BoxDecoration(
                  image: pw.DecorationImage(
                    image: pw.MemoryImage(
                      item.isHaveQrCode! ? imageBytes! : item.imageByte!,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    Uint8List _file = await pdfFile.save();
    showDialog(
      context: context,
      builder: (context) => ShowDialog(
        uint8list: _file,
      ),
    );
  }

  double calculateWidth(double width) {
    return width * _a4Width / _a4Height;
  }

  double calculateHeight(double height) {
    return height * _a4Height / _a4Width;
  }
}

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

class ShowDialog extends StatefulWidget {
  final Uint8List? uint8list;
  const ShowDialog({Key? key, this.uint8list}) : super(key: key);

  @override
  State<ShowDialog> createState() => _ShowDialogState();
}

class _ShowDialogState extends State<ShowDialog> {
  PdfController? controllerPdf;
  @override
  void initState() {
    controllerPdf = PdfController(
      document: PdfDocument.openData(widget.uint8list!),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(50),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
            ),
          ),
          child: PdfView(
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
        ),
      ),
    );
  }
}
