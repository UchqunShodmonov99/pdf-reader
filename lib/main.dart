import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_file/internet_file.dart';
import 'package:pdfx/pdfx.dart';
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
  var widgetKey = GlobalKey();
  final List<Uint8List> _listImage = [];
  final pageController = PageController();
  int _currenctIndex = 2;

  Widget image() {
    return Container(
      key: widgetKey,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: MemoryImage(_listImage[_currenctIndex]),
        ),
        border: Border.all(
          color: Colors.grey,
        ),
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
    if (_listImage.isNotEmpty) {
      image();
    }
    super.build(context);
    return Scaffold(
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

  Size getSize() {
    return widgetKey.currentContext!.size!;
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
  var widgetKey = GlobalKey();
  Size? _size;

  @override
  void initState() {
    getImageSize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _size == null
        ? Container()
        : Container(
            key: widgetKey,
            height: _size!.height,
            width: _size!.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: MemoryImage(widget.image!),
              ),
              border: Border.all(
                color: Colors.grey,
              ),
            ),
            alignment: Alignment.topLeft,
            margin: const EdgeInsets.all(50),
            child: Draggable(
              child: Container(
                padding: EdgeInsets.only(top: top, left: left),
                child: DragItem(),
              ),
              feedback: Container(
                padding: EdgeInsets.only(top: top, left: left),
                child: DragItem(),
              ),
              childWhenDragging: Container(
                padding: EdgeInsets.only(top: top, left: left),
                child: DragItem(),
              ),
              onDragCompleted: () {},
              onDragEnd: (drag) {
                setState(() {
                  if ((top + drag.offset.dy) > (getSize().height - 30.0)) {
                    top = (getSize().height - 30.0);
                  } else if ((top + drag.offset.dy - 30.0) < 0.0) {
                    top = 0;
                  } else {
                    top = top + drag.offset.dy - 30.0;
                  }
                  if ((left + drag.offset.dx) > (getSize().width - 30.0)) {
                    left = (getSize().width - 30.0);
                  } else if ((left + drag.offset.dx - 30.0) < 0.0) {
                    left = 0;
                  } else {
                    left = left + drag.offset.dx - 30.0;
                  }
                });
              },
            ),
          );
  }

  Size getSize() {
    return widgetKey.currentContext!.size!;
  }

  getImageSize() async {
    var decodedImage = await decodeImageFromList(widget.image!);
    _size = Size(
      decodedImage.width.toDouble(),
      decodedImage.height.toDouble(),
    );
    setState(() {});
  }
}

class DragItem extends StatelessWidget {
  const DragItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Icon(
      IconData(57744, fontFamily: 'MaterialIcons'),
      size: 30,
    );
  }
}
