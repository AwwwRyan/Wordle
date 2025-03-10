import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:wordleforgf/app_colors.dart';

enum LetterStatus{initial, notinword,inword,correct}
class Letter extends Equatable{
  const Letter({required this.val,
this.status=LetterStatus.initial});

  factory Letter.empty() =>const Letter(val:"");
  final String val;

  final LetterStatus status;

  Color get backgroundColor {
    switch (status) {
      case LetterStatus.initial:
        return Colors.transparent;
      case LetterStatus.notinword:
        return notinwordcolor;
      case LetterStatus.inword:
        return inwordcolor;
      case LetterStatus.correct:
        return correctcolor;
    }
  }

  Color get borderColor {
    switch (status) {
      case LetterStatus.initial:
        return Colors.grey;
      default:
        return Colors.transparent;
    }
  }

  Letter copyWith({
    String? val,
    LetterStatus? status,
  }) {
    return Letter(
      val: val ?? this.val,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [val,status];

}