import 'package:equatable/equatable.dart';

import 'letter_model.dart';

class Word extends Equatable {
  const Word({required this.letters, this.meaning = ''});

  factory Word.fromString(String word, [String meaning = '']) => Word(
      letters: word.split('').map((e) => Letter(val: e)).toList(),
      meaning: meaning);

  final List<Letter> letters;
  final String meaning;

  String get wordString => letters.map((e) => e.val).join();

  void addLetter(String val) {
    final currentIndex = letters.indexWhere((e) => e.val.isEmpty);
    if (currentIndex != -1) {
      letters[currentIndex] = Letter(val: val);
    }
  }

  void removeLetter() {
    final recentLetterIndex = letters.lastIndexWhere((e) => e.val.isNotEmpty);
    if (recentLetterIndex != -1) {
      letters[recentLetterIndex] = Letter.empty();
    }
  }

  @override
  List<Object?> get props => [letters, meaning];
}
