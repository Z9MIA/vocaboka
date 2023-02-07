import 'package:flutter/material.dart';
import 'package:vocaboka/src/home.dart';
import 'package:vocaboka/src/model/vocabulary.dart';
import 'package:vocaboka/src/repository/sql_voca_repository.dart';

class DetailsScreenArguments {
  final String title;
  final int? vocaId;
  final String? initialValue;

  DetailsScreenArguments(this.title, this.vocaId, this.initialValue);
}

class DetailsScreen extends StatefulWidget {
  const DetailsScreen(
      {super.key, required this.title, this.id, this.initialValue});

  final String title;
  final int? id;
  final String? initialValue;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

typedef OnChangeWord = void Function(String? voca);
typedef OnChangeMeaning = void Function(String? description);
typedef OnChangeExample = void Function(String? example);
typedef OnSwap = void Function();

class _DetailsScreenState extends State<DetailsScreen> {
  String _word = "";
  String _meaning = "";
  String? _example;
  bool _isWordInput = true;
  final _formKey = GlobalKey<FormState>();
  final _snackBar = SnackBar(
    content: Text("저장이 완료되었습니다."),
    backgroundColor: Colors.purple[800],
    duration: Duration(milliseconds: 1000),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), side: BorderSide(width: 0)),
    dismissDirection: DismissDirection.down,
  );

  void _setWord(String? word) {
    setState(() {
      if (word?.isNotEmpty == true) {
        _word = word!;
      }
    });
  }

  void _setMeaning(String? meaning) {
    setState(() {
      if (meaning?.isNotEmpty == true) {
        _meaning = meaning!;
      }
    });
  }

  void _setExample(String? example) {
    setState(() {
      _example = example;
    });
  }

  void _onSwap() {
    setState(() {
      String meaning = _meaning;
      _meaning = _word;
      _word = meaning;
      print("meaning: ${_meaning}, word: ${_word}");
      _isWordInput = !_isWordInput;
    });
  }

  void _onSave(int? id) async {
    print("onSave: ${id} / ${_formKey.currentState?.validate()}");
    if (_formKey.currentState?.validate() == true) {
      _formKey.currentState?.save();

      Vocabulary vocabulary =
          Vocabulary(word: _word, meaning: _meaning, example: _example);

      if (id != null) {
        await SqlVocaRepository.update(vocabulary);
      } else {
        await SqlVocaRepository.create(vocabulary);
      }

      ScaffoldMessenger.of(context).showSnackBar(_snackBar);
      Navigator.pop(context, true);
    }
  }

  Future<Vocabulary?> _load(int id) async {
    return SqlVocaRepository.getOne(id);
  }

  Widget renderFormWidget(int? id) {
    if (widget.initialValue != null || id == null) {
      if (widget.initialValue != null) {
        _setWord(widget.initialValue!);
      }
      return Form(
          key: _formKey,
          child: VocabularyInputWidget(
            onChangeWord: _setWord,
            onChangeMeaning: _setMeaning,
            onChangeExample: _setExample,
            onSwap: _onSwap,
            word: _word,
            meaning: _meaning,
            example: _example,
            isWordInput: _isWordInput,
          ));
    } else {
      return FutureBuilder<Vocabulary?>(
          future: _load(id),
          builder: (context, snapshot) {
            print(snapshot);
            if (snapshot.hasError) {
              return Center(child: Text('Not Support Sqflite'));
            }

            if (snapshot.hasData && snapshot.data != null) {
              Vocabulary vocabulary = snapshot.data!;
              _word = vocabulary.word;
              _meaning = vocabulary.meaning;
              _example = vocabulary.example;
              return Form(
                  key: _formKey,
                  child: VocabularyInputWidget(
                    onChangeWord: _setWord,
                    onChangeMeaning: _setMeaning,
                    onChangeExample: _setExample,
                    onSwap: _onSwap,
                    word: _word,
                    meaning: _meaning,
                    example: _example,
                    isWordInput: _isWordInput,
                  ));
            }

            return Center(child: CircularProgressIndicator());
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: Row(
            children: [
              Text(widget.title,
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              Spacer(),
              Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                  child: InkWell(
                      onTap: () {
                        _onSave(widget.id);
                      },
                      child: Text("저장",
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold))))
            ],
          ),
          backgroundColor: Colors.grey[200],
          elevation: 0.0,
        ),
        body: SafeArea(child: renderFormWidget(widget.id)));
  }
}

class VocabularyInputWidget extends StatelessWidget {
  VocabularyInputWidget(
      {super.key,
      required this.onChangeWord,
      required this.onChangeMeaning,
      required this.onChangeExample,
      required this.onSwap,
      this.word,
      this.meaning,
      this.example,
      this.isWordInput = true});

  final OnChangeWord onChangeWord;
  final OnChangeMeaning onChangeMeaning;
  final OnChangeExample onChangeExample;
  final OnSwap onSwap;
  String? word;
  String? meaning;
  String? example;
  bool isWordInput;

  renderTextFormField({
    Key? key,
    required BuildContext context,
    required String label,
    required ValueChanged<String> onValueChanged,
    required FormFieldValidator validator,
    required TextInputAction textInputAction,
    String? initialValue,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      SizedBox(height: 10),
      TextFormField(
        key: key,
        initialValue: initialValue,
        validator: validator,
        textInputAction: textInputAction,
        onChanged: onValueChanged,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(30, 20, 30, 20),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: BorderSide(width: 0, style: BorderStyle.none)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: BorderSide(
                    width: 1,
                    style: BorderStyle.none,
                    color: Theme.of(context).primaryColor)),
            filled: true,
            fillColor: Colors.grey[300]),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          renderTextFormField(
            key: Key(isWordInput.toString()),
            context: context,
            label: "단어",
            initialValue: word,
            textInputAction: TextInputAction.next,
            onValueChanged: onChangeWord,
            validator: (val) {
              if (val.length < 1) {
                return "단어는 필수 입력사항입니다.";
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          Center(
              child:
                  IconButton(onPressed: onSwap, icon: Icon(Icons.swap_vert))),
          SizedBox(height: 10),
          renderTextFormField(
              key: Key(isWordInput.toString()),
              context: context,
              label: "의미",
              initialValue: meaning,
              textInputAction: TextInputAction.next,
              onValueChanged: onChangeMeaning,
              validator: (val) {
                if (val.length < 1) {
                  return "의미는 필수 입력사항입니다.";
                }
                return null;
              }),
          SizedBox(height: 40),
          renderTextFormField(
              context: context,
              label: "예제",
              initialValue: example,
              textInputAction: TextInputAction.done,
              onValueChanged: onChangeExample,
              validator: (val) {
                return null;
              }),
        ],
      ),
    );
  }
}
