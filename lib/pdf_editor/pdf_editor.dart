import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_pdf/device_info.dart';

import 'bloc/edit_pdf_bloc.dart';
import 'logic/pdf_edit.dart';
import 'logic/save_pdf/save_pdf_bloc.dart';
import 'widget/change_page.dart';
import 'widget/pdf_item.dart';

class PdfEditorPage extends StatelessWidget {
  final Uint8List? pdf;
  final String? numberDoc;
  const PdfEditorPage({
    Key? key,
    required this.pdf,
    required this.numberDoc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => EditPdfBloc(),
        ),
        BlocProvider(
          create: (context) => SavePdfBloc(),
        ),
      ],
      child: PdfEditor(
        numberDoc: numberDoc,
        pdf: pdf,
      ),
    );
  }
}

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
    PdfEdit().getPdfToImage(
      pdf: widget.pdf,
      context: context,
      isInit: true,
    );
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
    return BlocBuilder<SavePdfBloc, SavePdfState>(
      builder: (context, stateSave) {
        return Scaffold(
          backgroundColor: const Color(0xFFF0F1F2),
          body: Stack(
            children: [
              BlocBuilder<EditPdfBloc, EditPdfState>(
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
              if (stateSave is SavePdfLoading)
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
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
