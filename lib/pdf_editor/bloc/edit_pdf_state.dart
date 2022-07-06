part of 'edit_pdf_bloc.dart';

abstract class EditPdfState extends Equatable {
  final List<QrCodePostion>? list;
  final List<QrCodePostion>? listOld;
  final int? currentIndex;

  const EditPdfState({
    this.list,
    this.currentIndex,
    this.listOld,
  });

  @override
  List<Object> get props => [list!, currentIndex!, listOld!];
}

class EditPdfInitial extends EditPdfState {}

class EditPdfLoading extends EditPdfState {}

class EditPdfSuccess extends EditPdfState {
  const EditPdfSuccess({
    List<QrCodePostion>? list,
    int? currentIndex,
    List<QrCodePostion>? listOld,
  }) : super(list: list, currentIndex: currentIndex, listOld: listOld);
}

class QrCodePostion {
  double? dx;
  double? dy;
  bool? isHaveQrCode;
  Uint8List? imageByte;

  QrCodePostion({
    this.dx = 100,
    this.dy = 100,
    this.isHaveQrCode = false,
    this.imageByte,
  });
}
