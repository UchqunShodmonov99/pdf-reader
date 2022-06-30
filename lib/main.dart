import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_file/internet_file.dart';
import 'package:pdfx/pdfx.dart';
import 'package:test_pdf/device_info.dart';
import 'package:test_pdf/edit_pdf/edit_pdf_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditPdfBloc(),
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const TestPage(),
      ),
    );
  }
}

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage>
    with AutomaticKeepAliveClientMixin {
  final List<Uint8List> _listImage = [];
  final pageController = PageController();
  int _currenctIndex = 2;

  @override
  void initState() {
    getPdfToImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      body: _listImage.isNotEmpty
          ? Drag(
              image: _listImage[_currenctIndex],
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

class Drag extends StatefulWidget {
  final Uint8List? image;
  const Drag({
    Key? key,
    this.image,
  }) : super(key: key);
  @override
  _DragState createState() => _DragState();
}

class _DragState extends State<Drag> {
  double top = 0;
  double left = 0;
  final double _sizeQrCode = 50;
  final double _a4Width = 2480;
  final double _a4Height = 3508;

  double getWidth() {
    return MediaQuery.of(context).size.height * _a4Width / _a4Height;
  }

  double getHeight() {
    return MediaQuery.of(context).size.height;
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: ((context, orientation) {
      return Center(
        child: Container(
          width: orientation == Orientation.portrait ? getHeight() : getWidth(),
          height:
              orientation == Orientation.portrait ? getWidth() : getHeight(),
          margin: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
              image: MemoryImage(widget.image!),
            ),
          ),
          child: GestureDetector(
            child: Stack(
              children: [
                Positioned(
                  top: top,
                  left: left,
                  child: DragItem(
                    sizeQrCode: _sizeQrCode,
                  ),
                ),
              ],
            ),
            onVerticalDragUpdate: (drage) {
              double height = orientation == Orientation.portrait
                  ? getWidth()
                  : getHeight();
              double width = orientation == Orientation.portrait
                  ? getHeight()
                  : getWidth();

              setState(() {
                if (drage.localPosition.dy >= 0 &&
                    (drage.localPosition.dy + _sizeQrCode) <= height) {
                  top = drage.localPosition.dy;
                } else if (drage.localPosition.dy + _sizeQrCode > height) {
                  if (DeviceInfo().isPhone() == false &&
                      orientation == Orientation.landscape) {
                    top = height - _sizeQrCode * 2.1;
                  } else {
                    top = height - _sizeQrCode;
                  }
                } else {
                  top = 0;
                }

                if (drage.localPosition.dx >= 0 &&
                    drage.localPosition.dx + _sizeQrCode <= width) {
                  left = drage.localPosition.dx;
                } else if (drage.localPosition.dx + _sizeQrCode > width) {
                  left = width - _sizeQrCode;
                } else {
                  left = 0;
                }
              });
            },
          ),
        ),
      );
    }));
  }
}

class DragItem extends StatelessWidget {
  final double? sizeQrCode;
  const DragItem({Key? key, this.sizeQrCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sizeQrCode,
      height: sizeQrCode,
      color: Colors.amber,
    );
  }
}
