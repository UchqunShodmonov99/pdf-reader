import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:internet_file/internet_file.dart';

import 'pdf_editor/pdf_editor.dart';
import 'pdf_viewer/pdf_viewer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GetPdf(),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    child: const Text('Edit Pdf'),
                    onPressed: () async {
                      var args = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PdfEditorPage(
                            numberDoc: 'KQ41745638',
                            pdf: _file,
                          ),
                        ),
                      );
                      if (args != null) {
                        showDialog(
                          context: context,
                          builder: (context) => Container(
                            margin: const EdgeInsets.all(20),
                            child: PdfViewerWidget(
                              pdfImage: args,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextButton(
                    child: const Text('Priview Pdf'),
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (context) => Container(
                          margin: const EdgeInsets.all(20),
                          child: PdfViewerWidget(
                            pdfImage: _file,
                          ),
                        ),
                      );
                    },
                  ),
                ],
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
