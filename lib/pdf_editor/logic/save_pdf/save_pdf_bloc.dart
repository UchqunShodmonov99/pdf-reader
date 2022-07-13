import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_pdf/pdf_editor/bloc/edit_pdf_bloc.dart';
import 'package:test_pdf/pdf_editor/logic/pdf_edit.dart';

part 'save_pdf_event.dart';

part 'save_pdf_state.dart';

class SavePdfBloc extends Bloc<SavePdfEvent, SavePdfState> {
  SavePdfBloc() : super(SavePdfInitial()) {
    on<ChangePdfSave>((event, emit) async {
      emit(SavePdfLoading());
      bool mm = true;
      if (event.back!) {
        if (event.state!.listOld != event.state!.list) {
          mm = await PdfEdit().savePdf(
            state: event.state,
            key: event.key,
            context: event.context,
            back: event.back,
            sizeQrCode: event.sizeQrCode,
            valueQrCode: event.valueQrCode,
          );
        } else {
          Navigator.pop(event.context!);
        }
      } else {
        mm = await PdfEdit().savePdf(
          state: event.state,
          key: event.key,
          context: event.context,
          sizeQrCode: event.sizeQrCode,
          valueQrCode: event.valueQrCode,
        );
      }
      if (mm == false) {
        emit(SavePdfSuccess());
      }
    });
  }
}
