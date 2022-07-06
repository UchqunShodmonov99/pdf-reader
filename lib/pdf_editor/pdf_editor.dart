import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_pdf/device_info.dart';
import 'package:test_pdf/pdf_editor/bloc/edit_pdf_bloc.dart';

import 'logic/pdf_edit.dart';
import 'widget/change_page.dart';
import 'widget/pdf_item.dart';

class PdfEditor extends StatefulWidget {
  final Uint8List? pdf;
  final String? numberDoc;
  const PdfEditor({
    Key? key,
    required this.pdf,
    required this.numberDoc,
  }) : super(key: key);

  @override
  State<PdfEditor> createState() => _PdfEditorState();
}

class _PdfEditorState extends State<PdfEditor>
    with AutomaticKeepAliveClientMixin {
  String url = 'https://check.ijro.uz/d/';

  @override
  void initState() {
    url = 'https://check.ijro.uz/d/${widget.numberDoc}';
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    PdfEdit().getPdfToImage(pdf: widget.pdf, context: context);
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
      backgroundColor: const Color(0xFFF0F1F2),
      body: BlocBuilder<EditPdfBloc, EditPdfState>(
        builder: (context, state) {
          if (state is EditPdfSuccess) {
            if (state.list!.isEmpty) {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            }
            return Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: PdfItem(
                    url: url,
                  ),
                ),
                ChangePageWidget(state: state),
              ],
            );
          } else {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
