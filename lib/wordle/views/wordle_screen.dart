import 'dart:math';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wordleforgf/app_colors.dart';
import 'package:wordleforgf/wordle/model/letter_model.dart';
import 'package:wordleforgf/wordle/widgets/board.dart';
import 'package:wordleforgf/wordle/widgets/keyboard.dart';
import 'package:confetti/confetti.dart';
import '../data/word_list.dart';
import '../model/word_model.dart';

enum GameStatus { playing, submitting, lost, won }

class WordleScreen extends StatefulWidget {
  const WordleScreen({super.key});

  @override
  State<WordleScreen> createState() => _WordleScreenState();
}

class _WordleScreenState extends State<WordleScreen> {
  GameStatus _gameStatus = GameStatus.playing;
  final List<Word> _board = List.generate(
      6, (_) => Word(letters: List.generate(5, (_) => Letter.empty())));
  final List<List<GlobalKey<FlipCardState>>> _flipCardKeys = List.generate(
    6,
    (_) => List.generate(
      5,
      (_) => GlobalKey<FlipCardState>(),
    ),
  );
  int _currentWordIndex = 0;

  Word? get _currentWord =>
      _currentWordIndex < _board.length ? _board[_currentWordIndex] : null;

  late Word _solution;
  final Set<Letter> _keyboardLetters = {};
  final ConfettiController _confettiController = ConfettiController(
      duration: const Duration(seconds: 1)); // Create a ConfettiController

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    final randomIndex = Random().nextInt(fiveLetterWords.length);
    _solution = Word.fromString(
      fiveLetterWords[randomIndex].word.toUpperCase(),
      fiveLetterWords[randomIndex].meaning,
    );
  }

  @override
  void dispose() {
    _confettiController.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "CRUMBS",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 3),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 4,
              ),
              Board(
                board: _board,
                FlipCardKeys: _flipCardKeys,
              ),
              Container(
                height: 8,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _gameStatus == GameStatus.won ||
                          _gameStatus == GameStatus.lost
                      ? _solution.meaning
                      : "Guess the word!",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Spacer(),
              Keyboard(
                onKeyTapped: _onKeyTapped,
                onDeleteTapped: _onDeleteTapped,
                onEnterTapped: _onEnterTapped,
                letters: _keyboardLetters,
              )
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              shouldLoop: false,
              numberOfParticles: 100,
              colors: const [
                Color(0xff065E39),
                Color(0xff179769),
                Color(0xff62FFC7),
                Color(0xff30CA89),
                Color(0xff217803),
                Color(0xff308B39),
                Color(0xffA1FA82),
                Color(0xffA1FA82),
                Color(0xff6ACD07),
                Color(0xff5AAF45),
                Color(0xff30CA89),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onKeyTapped(String val) {
    if (_gameStatus == GameStatus.playing) {
      setState(() {
        _currentWord?.addLetter(val);
      });
    }
  }

  void _onDeleteTapped() {
    if (_gameStatus == GameStatus.playing) {
      setState(() {
        _currentWord?.removeLetter();
      });
    }
  }

  Future<void> _onEnterTapped() async {
    if (_gameStatus == GameStatus.playing &&
        _currentWord != null &&
        !_currentWord!.letters.contains(Letter.empty())) {
      _gameStatus = GameStatus.submitting;

      for (var i = 0; i < _currentWord!.letters.length; i++) {
        final currentWordLetter = _currentWord!.letters[i];
        final currentSolutionLetter = _solution.letters[i];

        setState(() {
          if (currentWordLetter == currentSolutionLetter) {
            _currentWord!.letters[i] =
                currentWordLetter.copyWith(status: LetterStatus.correct);
          } else if (_solution.letters.contains(currentWordLetter)) {
            _currentWord!.letters[i] =
                currentWordLetter.copyWith(status: LetterStatus.inword);
          } else {
            _currentWord!.letters[i] =
                currentWordLetter.copyWith(status: LetterStatus.notinword);
          }
        });
        final letter = _keyboardLetters.firstWhere(
          (e) => e.val == currentWordLetter.val,
          orElse: () => Letter.empty(),
        );

        if (letter.status != LetterStatus.correct) {
          _keyboardLetters.removeWhere((e) => e.val == currentWordLetter.val);
          _keyboardLetters.add(_currentWord!.letters[i]);
        }
        await Future.delayed(
          const Duration(milliseconds: 300),
          () => _flipCardKeys[_currentWordIndex][i].currentState?.toggleCard(),
        );
      }
      _checkIfWinOrLoss();
    }
  }

  void _checkIfWinOrLoss() {
    setState(() {
      if (_currentWord!.wordString == _solution.wordString) {
        _gameStatus = GameStatus.won;
        _confettiController.play(); // Trigger the confetti animation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            dismissDirection: DismissDirection.none,
            duration: const Duration(days: 1),
            backgroundColor: correctcolor,
            content: const Text(
              'You won!',
              style: TextStyle(color: Colors.white),
            ),
            action: SnackBarAction(
              onPressed: _restart,
              textColor: Colors.white,
              label: 'New Game',
            ),
          ),
        );
      } else if (_currentWordIndex + 1 >= _board.length) {
        _gameStatus = GameStatus.lost;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            dismissDirection: DismissDirection.none,
            duration: const Duration(days: 1),
            backgroundColor: Colors.redAccent[200],
            content: Text(
              'You lost! Solution: ${_solution.wordString}',
              style: const TextStyle(color: Colors.white),
            ),
            action: SnackBarAction(
              onPressed: _restart,
              textColor: Colors.white,
              label: 'New Game',
            ),
          ),
        );
      } else {
        _gameStatus = GameStatus.playing;
      }
      _currentWordIndex += 1;
    });
  }

  void _restart() {
    setState(() {
      _gameStatus = GameStatus.playing;
      _currentWordIndex = 0;

      _board.clear();
      _board.addAll(
        List.generate(
          6,
          (_) => Word(letters: List.generate(5, (_) => Letter.empty())),
        ),
      );

      final randomIndex = Random().nextInt(fiveLetterWords.length);
      _solution = Word.fromString(
        fiveLetterWords[randomIndex].word.toUpperCase(),
        fiveLetterWords[randomIndex].meaning,
      );
      _flipCardKeys
        ..clear()
        ..addAll(List.generate(
            6, (_) => List.generate(5, (_) => GlobalKey<FlipCardState>())));
      _keyboardLetters.clear();
    });
  }
}
