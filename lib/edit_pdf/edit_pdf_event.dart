part of 'edit_pdf_bloc.dart';

abstract class EditPdfEvent extends Equatable {
  const EditPdfEvent();

  @override
  List<Object> get props => [];
}

class InitilPdf extends EditPdfEvent {
  final List<QrCodePostion>? list;
  final int? currentIndex;
  const InitilPdf({
    this.list,
    this.currentIndex = 0,
  });
}

class ChangePage extends EditPdfEvent {
  final List<QrCodePostion>? list;
  final int? currentIndex;
  const ChangePage({this.list, this.currentIndex});
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
