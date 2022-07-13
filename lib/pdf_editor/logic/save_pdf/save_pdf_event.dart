part of 'save_pdf_bloc.dart';

abstract class SavePdfEvent extends Equatable {
  const SavePdfEvent();

  @override
  List<Object> get props => [];
}

class ChangePdfSave extends SavePdfEvent {
  final EditPdfSuccess? state;
  final GlobalKey? key;
  final BuildContext? context;
  final bool? back;
  final String? valueQrCode;
  final double? sizeQrCode;

  const ChangePdfSave({
    this.valueQrCode,
    this.sizeQrCode,
    this.state,
    this.key,
    this.context,
    this.back,
  });
}
