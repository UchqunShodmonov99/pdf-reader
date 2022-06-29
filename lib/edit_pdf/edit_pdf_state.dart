part of 'edit_pdf_bloc.dart';

abstract class EditPdfState extends Equatable {
  final List<QrCodePostion>? list;
  const EditPdfState({this.list});

  @override
  List<Object> get props => [list!];
}

class EditPdfInitial extends EditPdfState {}

class EditPdfLoading extends EditPdfState {}

class EditPdfSuccess extends EditPdfState {
  const EditPdfSuccess({List<QrCodePostion>? list}) : super(list: list);
}

class QrCodePostion {
  final double? dx;
  final double? dy;
  final bool? isHaveQrCode;

  QrCodePostion({
    this.dx = 0,
    this.dy = 0,
    this.isHaveQrCode=false,
  });
}
