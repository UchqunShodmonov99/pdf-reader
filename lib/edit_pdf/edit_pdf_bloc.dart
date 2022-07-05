import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'edit_pdf_event.dart';
part 'edit_pdf_state.dart';

class EditPdfBloc extends Bloc<EditPdfEvent, EditPdfState> {
  EditPdfBloc() : super(EditPdfInitial()) {
    on<EditPdfEvent>((event, emit) {
      if (event is InitilPdf) {
        emit(EditPdfLoading());
        emit(
            EditPdfSuccess(list: event.list, currentIndex: event.currentIndex));
      }
      if (event is ChangePdf) {
        List<QrCodePostion>? list = state.list!;

        emit(EditPdfLoading());
        list[event.index!] = event.item!;
        emit(EditPdfSuccess(list: list,currentIndex: event.index));
      }
    });
  }
}
