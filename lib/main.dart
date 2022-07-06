import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_file/internet_file.dart';

import 'pdf_editor/bloc/edit_pdf_bloc.dart';
import 'pdf_editor/pdf_editor.dart';
import 'pdf_viewer/pdf_viewer.dart';

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
        home: const GetPdf(),
      ),
    );
  }
}

class GetPdf extends StatefulWidget {
  const GetPdf({Key? key}) : super(key: key);

  @override
  State<GetPdf> createState() => _GetPdfState();
}

class _GetPdfState extends State<GetPdf> {
  Uint8List? _file;
  @override
  void initState() {
    getFile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _file == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: TextButton(
                child: const Text('Press'),
                onPressed: () async {
                  var args = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PdfEditor(
                        numberDoc: '32352345235',
                        pdf: _file,
                      ),
                    ),
                  );
                  if (args != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfViewerWidget(
                          pdfImage: args['pdf'],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
    );
  }

  Future<void> getFile() async {
    _file = await InternetFile.get(
      'https://juventudedesporto.cplp.org/files/sample-pdf_9359.pdf',
      process: ((percentage) {}),
    );
    setState(() {});
  }
}
