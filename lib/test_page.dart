import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:internet_file/internet_file.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdfx/pdfx.dart';

import 'package:flutter/material.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:test_pdf/edit_pdf/edit_pdf_bloc.dart';

class TestPage extends StatefulWidget {
const TestPage({Key? key}) : super(key: key);

@override
State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage>
  with AutomaticKeepAliveClientMixin {
final List<Uint8List> _listImage = [];
final pdfFile = pw.Document();
final pageController = PageController();
int _currenctIndex = 0;

void add() {
  pdfFile.addPage(
    pw.Page(
      pageFormat: pdf.PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Stack(
          children: [],
        );
      },
    ),
  );
}

@override
void initState() {
  getPdfToImage();
  super.initState();
}

@override
Widget build(BuildContext context) {
  super.build(context);
  return Scaffold(
    body: _listImage.isNotEmpty
        ? PdfPageImage(
            uint8list: _listImage[_currenctIndex],
            size: MediaQuery.of(context).size,
            index: _currenctIndex,
            count: _listImage.length,
            controller: pageController,
            nextPage: () {
              if (_currenctIndex < (_listImage.length - 1)) {
                _currenctIndex = _currenctIndex + 1;
                setState(() {});
              }
            },
            backPage: () {
              if (_currenctIndex > 0) {
                _currenctIndex = _currenctIndex - 1;
                setState(() {});
              }
            },
          )
        : const Center(
            child: CircularProgressIndicator(),
          ),
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

class PdfPageImage extends StatefulWidget {
final Uint8List? uint8list;
final Function()? nextPage;
final Function()? backPage;
final PageController? controller;
final int? index;
final int? count;
final Size? size;
final Function()? onExit;
final Function()? onSave;
const PdfPageImage({
  Key? key,
  this.uint8list,
  this.size,
  this.index,
  this.count,
  this.controller,
  this.onExit,
  this.onSave,
  this.nextPage,
  this.backPage,
}) : super(key: key);

@override
State<PdfPageImage> createState() => _PdfPageImageState();
}

class _PdfPageImageState extends State<PdfPageImage>
  with AutomaticKeepAliveClientMixin {
final double _size = 60;
Size? pageSize;
@override
void initState() {
  getSize();
  super.initState();
}

@override
Widget build(BuildContext context) {
  super.build(context);
  if (pageSize == null) {
    return Container();
  } else {
    return BlocBuilder<EditPdfBloc, EditPdfState>(
      builder: (context, state) {
        if (state is EditPdfSuccess) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 30, right: 10, left: 10),
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: widget.onExit,
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFF313234),
                        size: 30,
                      ),
                    ),
                    const Spacer(),
                    if (state.list![widget.index!].isHaveQrCode == false)
                      IconButton(
                        onPressed: () {
                          BlocProvider.of<EditPdfBloc>(context).add(
                            ChangePdf(
                              item: QrCodePostion(
                                dx: state.list![widget.index!].dx,
                                dy: state.list![widget.index!].dy,
                                isHaveQrCode: true,
                              ),
                              index: widget.index,
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.qr_code_2_sharp,
                          color: Color(0xFF313234),
                          size: 30,
                        ),
                      ),
                    if (state.list![widget.index!].isHaveQrCode!)
                      IconButton(
                        onPressed: widget.onSave,
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
              Expanded(
                child: SizedBox(
                  width: pageSize!.width,
                  height: pageSize!.height,
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                            ),
                          ),
                          child: Image(
                            width: pageSize!.width,
                            height: pageSize!.height,
                            image: MemoryImage(widget.uint8list!),
                          ),
                        ),
                      ),
                      if (state.list![widget.index!].isHaveQrCode!)
                        Positioned(
                          left: state.list![widget.index!].dx,
                          top: state.list![widget.index!].dy!,
                          child: Draggable(
                            child: Container(
                              color: Colors.green,
                              width: _size,
                              height: _size,
                            ),
                            feedback: Container(
                              color: Colors.green,
                              width: _size,
                              height: _size,
                            ),
                            childWhenDragging: Container(),
                            onDragEnd: (dragDetails) async {
                              BlocProvider.of<EditPdfBloc>(context).add(
                                ChangePdf(
                                  item: QrCodePostion(
                                    dx: dragDetails.offset.dx,
                                    dy: dragDetails.offset.dy - 90,
                                    isHaveQrCode: true,
                                  ),
                                  index: widget.index,
                                ),
                              );
                            },
                          ),
                        )
                    ],
                  ),
                ),
              ),
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
                      onPressed: state.list![widget.index!].isHaveQrCode!
                          ? null
                          : widget.backPage,
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFF313234),
                        size: 20,
                      ),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    Text((widget.index! + 1).toString()),
                    const SizedBox(
                      width: 30,
                    ),
                    IconButton(
                      onPressed: state.list![widget.index!].isHaveQrCode!
                          ? null
                          : widget.nextPage,
                      icon: Transform.rotate(
                        angle: pi,
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
        return Container();
      },
    );
  }
}

Future<Size> getSize() async {
  var decodedImage = await decodeImageFromList(widget.uint8list!);
  Size _size = Size(
    decodedImage.width * 1.0,
    decodedImage.height * 1.0,
  );

  pageSize = _size;
  setState(() {});
  return _size;
}

@override
bool get wantKeepAlive => true;
}
