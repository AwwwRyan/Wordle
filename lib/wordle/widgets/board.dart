import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:wordleforgf/wordle/model/word_model.dart';

import '../model/letter_model.dart';
import 'board_title.dart';

class Board extends StatelessWidget {
  final List<Word> board;
  final List<List<GlobalKey<FlipCardState>>> FlipCardKeys;

  const Board({Key? key,
  required this.board,required this.FlipCardKeys}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: board.asMap().map((i, word) => MapEntry(
        i,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: word.letters.asMap().map((j, letter) => MapEntry(
            j,
            FlipCard(
              key: FlipCardKeys[i][j],
              flipOnTouch: false,
              direction: FlipDirection.VERTICAL,
              front: Boardtitle(
                letter: Letter(
                  val: letter.val,
                  status: LetterStatus.initial,
                ), // Letter
              ), // BoardTile
              back: Boardtitle(letter: letter),
            ), // FlipCard
          )).values.toList(),
        ),
      )).values.toList(),
    );
  }
}
