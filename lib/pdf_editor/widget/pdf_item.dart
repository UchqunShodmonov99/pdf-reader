import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:test_pdf/pdf_editor/logic/pdf_edit.dart';

import '../bloc/edit_pdf_bloc.dart';
import 'qr_code_gen.dart';

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
  final double _sizeQrCode = 75;
  final double _a4Width = pdf.PdfPageFormat.a4.width;
  final double _a4Height = pdf.PdfPageFormat.a4.height;
  final _key = GlobalKey();
  bool _loading = false;

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
                onPressed: () async {
                  if (getIndex(state).isHaveQrCode!) {
                    BlocProvider.of<EditPdfBloc>(context).add(
                      EditQrCode(
                        index: state.currentIndex!,
                        isHave: false,
                      ),
                    );
                  } else {
                    if (state.listOld != state.list) {
                      _loading = true;
                      setState(() {});
                      var mm = await PdfEdit().savePdf(
                        state: state,
                        key: _key,
                        context: context,
                        back: true,
                      );
                      _loading = mm;
                      setState(() {});
                    } else {
                      Navigator.pop(context);
                    }
                  }
                },
                icon: const Icon(
                  Icons.close,
                  color: Color(0xFF313234),
                  size: 30,
                ),
              ),
              const Spacer(),
              if (getIndex(state).isHaveQrCode == false)
                IconButton(
                  onPressed: () {
                    BlocProvider.of<EditPdfBloc>(context).add(
                      EditQrCode(
                        index: state.currentIndex!,
                        isHave: true,
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.qr_code_2_sharp,
                    color: Color(0xFF313234),
                    size: 30,
                  ),
                ),
              if (getIndex(state).isHaveQrCode!)
                IconButton(
                  onPressed: () async {
                    _loading = true;
                    setState(() {});
                    var mm = await PdfEdit().savePdf(
                      state: state,
                      key: _key,
                      context: context,
                    );
                    setState(() {
                      _loading = mm;
                    });
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
    return BlocBuilder<EditPdfBloc, EditPdfState>(
      builder: (context, state) {
        if (state is EditPdfSuccess) {
          return Stack(
            children: [
              Column(
                children: [
                  _appBar(state, context),
                  Expanded(
                    child: Center(
                      child: RepaintBoundary(
                        key: _key,
                        child: Container(
                          width: _a4Width,
                          height: _a4Height,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            image: DecorationImage(
                              image: MemoryImage(
                                getIndex(state).imageByte!,
                              ),
                              fit: BoxFit.contain,
                            ),
                          ),
                          child: getIndex(state).isHaveQrCode == false
                              ? Container()
                              : GestureDetector(
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: getIndex(state).dy!,
                                        left: getIndex(state).dx!,
                                        child: QrGeneration(
                                          sizeQrCode: _sizeQrCode,
                                          value: widget.url,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onHorizontalDragUpdate: (drage) => dragged(
                                    drag: drage,
                                    state: state,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_loading)
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    color: Colors.black.withOpacity(0.2),
                    child: const Center(
                      child: CupertinoActivityIndicator(
                        color: Colors.white,
                        radius: 20,
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
  }

  void dragged({EditPdfSuccess? state, DragUpdateDetails? drag}) {
    double top = getIndex(state!).dy!;
    double left = getIndex(state).dx!;
    double _dx = drag!.localPosition.dx - _sizeQrCode / 2;
    double _dy = drag.localPosition.dy - _sizeQrCode / 2;
    if (_dy >= 0 && (_dy + _sizeQrCode) <= getSize().height) {
      top = _dy;
    } else if (_dy + _sizeQrCode > getSize().height) {
      top = getSize().height - _sizeQrCode;
    } else {
      top = 0;
    }
    if (_dx >= 0 && (_dx + _sizeQrCode) <= getSize().width) {
      left = _dx;
    } else if (_dx + _sizeQrCode > getSize().width) {
      left = getSize().width - _sizeQrCode;
    } else {
      left = 0;
    }
    BlocProvider.of<EditPdfBloc>(context).add(
      ChangePdf(
        item: QrCodePostion(
          dx: left,
          dy: top,
          isHaveQrCode: true,
          imageByte: getIndex(state).imageByte,
        ),
        index: state.currentIndex!,
      ),
    );
  }

  Size getSize() {
    return _key.currentContext!.size!;
  }

  QrCodePostion getIndex(EditPdfSuccess state) {
    return state.list![state.currentIndex!];
  }
}
