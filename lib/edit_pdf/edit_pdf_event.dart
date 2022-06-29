part of 'edit_pdf_bloc.dart';

abstract class EditPdfEvent extends Equatable {
  const EditPdfEvent();

  @override
  List<Object> get props => [];
}

class InitilPdf extends EditPdfEvent {
  final List<QrCodePostion>? list;
  const InitilPdf({this.list});
}

class ChangePdf extends EditPdfEvent {
  final QrCodePostion? item;
  final List<QrCodePostion>? list;
  final int? index;
  const ChangePdf({
    this.list,
    this.item,
    this.index,
  });
}
