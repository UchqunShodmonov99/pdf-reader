part of 'save_pdf_bloc.dart';

abstract class SavePdfState extends Equatable {
  const SavePdfState();

  @override
  List<Object> get props => [];
}

class SavePdfInitial extends SavePdfState {}

class SavePdfLoading extends SavePdfState {}

class SavePdfSuccess extends SavePdfState {}
