part of 'edit_pdf_bloc.dart';

abstract class EditPdfState extends Equatable {
  final List<QrCodePostion>? list;

  final int? currentIndex;
  const EditPdfState({
    this.list,
    this.currentIndex,
  });

  @override
  List<Object> get props => [list!, currentIndex!];
}

class EditPdfInitial extends EditPdfState {}

class EditPdfLoading extends EditPdfState {}

class EditPdfSuccess extends EditPdfState {
  const EditPdfSuccess({List<QrCodePostion>? list, int? currentIndex})
      : super(list: list, currentIndex: currentIndex);
}

class QrCodePostion {
  final double? dx;
  final double? dy;
  final bool? isHaveQrCode;
  final Uint8List? imageByte;

  QrCodePostion({
    this.dx = 100,
    this.dy = 100,
    this.isHaveQrCode = false,
    this.imageByte,
  });
}
