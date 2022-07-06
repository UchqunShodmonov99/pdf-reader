import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/edit_pdf_bloc.dart';

class ChangePageWidget extends StatelessWidget {
  final EditPdfSuccess? state;
  const ChangePageWidget({Key? key, this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(
          height: 1,
          thickness: 1,
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 30, right: 30),
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buttonChangePage(next: false, state: state),
              const SizedBox(
                width: 30,
              ),
              Text((state!.currentIndex! + 1).toString()),
              const SizedBox(
                width: 30,
              ),
              _buttonChangePage(next: true, state: state)
            ],
          ),
        ),
      ],
    );
  }

  Widget _buttonChangePage({
    bool? next,
    EditPdfSuccess? state,
    BuildContext? context,
  }) {
    return IconButton(
      onPressed: state!.list![state.currentIndex!].isHaveQrCode!
          ? null
          : () {
              int index = 0;
              if (next!) {
                if (state.currentIndex! < state.list!.length - 1) {
                  index = state.currentIndex! + 1;
                }
              } else {
                if (state.currentIndex! - 1 >= 0) {
                  index = state.currentIndex! - 1;
                }
              }

              BlocProvider.of<EditPdfBloc>(context!).add(
                ChangePage(
                  currentIndex: index,
                ),
              );
            },
      icon: next!
          ? Transform.rotate(
              angle: pi,
              child: const Icon(
                Icons.arrow_back_ios,
                color: Color(0xFF313234),
                size: 20,
              ),
            )
          : const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF313234),
              size: 20,
            ),
    );
  }
}
