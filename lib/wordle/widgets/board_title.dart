import 'package:flutter/cupertino.dart';
import 'package:wordleforgf/wordle/model/letter_model.dart';

class Boardtitle extends StatelessWidget {
  final Letter letter;
  const Boardtitle({super.key, required this.letter});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4),
      height: 60,
      width: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: letter.backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: letter.borderColor),
      ),
      child: Text(
        letter.val,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
      ),
    );
  }
}
