import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_file/internet_file.dart';
import 'package:pdfx/pdfx.dart';
import 'package:test_pdf/device_info.dart';
import 'package:test_pdf/edit_pdf/edit_pdf_bloc.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;

class PdfEditor extends StatefulWidget {
  const PdfEditor({Key? key}) : super(key: key);

  @override
  State<PdfEditor> createState() => _PdfEditorState();
}

class _PdfEditorState extends State<PdfEditor>
    with AutomaticKeepAliveClientMixin {
  final List<Uint8List> _listImage = [];
  final pageController = PageController();

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
                      _appBar(state, context),
                      Expanded(
                        child: PdfItem(image: _listImage[state.currentIndex!]),
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

  Widget _appBar(EditPdfSuccess state, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 30, right: 10, left: 10),
          height: 60,
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
                  onPressed: () {},
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
      _list.add(QrCodePostion());
      await page.close();
    }
    BlocProvider.of<EditPdfBloc>(context).add(InitilPdf(list: _list));
    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;
}

class PdfItem extends StatefulWidget {
  final Uint8List? image;
  const PdfItem({
    Key? key,
    this.image,
  }) : super(key: key);
  @override
  _PdfItemState createState() => _PdfItemState();
}

class _PdfItemState extends State<PdfItem> {
  final double _sizeQrCode = 85;
  final double _a4Width = pdf.PdfPageFormat.a4.width;
  final double _a4Height = pdf.PdfPageFormat.a4.height;

  double getWidth() {
    return MediaQuery.of(context).size.height * _a4Width / _a4Height;
  }

  double getHeight() {
    return MediaQuery.of(context).size.height;
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: ((context, orientation) {
      return BlocBuilder<EditPdfBloc, EditPdfState>(
        builder: (context, state) {
          if (state is EditPdfSuccess) {
            return Center(
              child: Container(
                width: orientation == Orientation.portrait
                    ? getHeight()
                    : getWidth(),
                height: orientation == Orientation.portrait
                    ? getWidth()
                    : getHeight(),
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                    image: MemoryImage(widget.image!),
                  ),
                ),
                child: state.list![state.currentIndex!].isHaveQrCode == false
                    ? Container()
                    : GestureDetector(
                        child: Stack(
                          children: [
                            Positioned(
                              top: state.list![state.currentIndex!].dy!,
                              left: state.list![state.currentIndex!].dx!,
                              child: DragItem(
                                sizeQrCode: _sizeQrCode,
                                value: 'www.syncfusion.com',
                              ),
                            ),
                          ],
                        ),
                        onHorizontalDragUpdate: (drage) {
                          double top = state.list![state.currentIndex!].dy!;
                          double left = state.list![state.currentIndex!].dx!;
                          double height = orientation == Orientation.portrait
                              ? getWidth()
                              : getHeight();
                          double width = orientation == Orientation.portrait
                              ? getHeight()
                              : getWidth();

                          double _dx = drage.localPosition.dx - _sizeQrCode / 2;
                          double _dy = drage.localPosition.dy - _sizeQrCode / 2;

                          if (_dy >= 0 && (_dy + _sizeQrCode) <= height) {
                            top = _dy;
                          } else if (_dy + _sizeQrCode > height) {
                            if (DeviceInfo().isPhone() == false &&
                                orientation == Orientation.landscape) {
                              top = height - _sizeQrCode * 2.1;
                            } else {
                              top = height - _sizeQrCode;
                            }
                          } else {
                            top = 0;
                          }

                          if (_dx >= 0 && _dx + _sizeQrCode <= width) {
                            left = _dx;
                          } else if (_dx + _sizeQrCode > width) {
                            left = width - _sizeQrCode;
                          } else {
                            left = 0;
                          }
                          BlocProvider.of<EditPdfBloc>(context).add(
                            ChangePdf(
                              item: QrCodePostion(
                                dx: left,
                                dy: top,
                                isHaveQrCode: true,
                              ),
                              index: state.currentIndex!,
                            ),
                          );
                        },
                      ),
              ),
            );
          } else {
            return const CupertinoActivityIndicator();
          }
        },
      );
    }));
  }

  void savePdf(EditPdfSuccess state) {
    final pdfFile = pw.Document();
    for (var item in state.list!) {
      pdfFile.addPage(
        pw.Page(
          pageFormat: pdf.PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Container(
              decoration: pw.BoxDecoration(
                image: pw.DecorationImage(
                  image: pw.MemoryImage(widget.image!),
                ),
              ),
            );
          },
        ),
      );
    }
  }
}

class DragItem extends StatelessWidget {
  final double? sizeQrCode;
  final String? value;
  const DragItem({Key? key, this.sizeQrCode, this.value}) : super(key: key);

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
