import 'package:flutter/material.dart';
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

typedef OnChangeVoca = void Function(String voca);
typedef OnChangeDescription = void Function(String description);
typedef OnChangeExample = void Function(String example);
typedef OnSwap = void Function();

class _DetailsScreenState extends State<DetailsScreen> {
  Vocabulary _vocabulary = Vocabulary(word: "", meaning: "");
  final _formKey = GlobalKey<FormState>();
  final _snackBar = SnackBar(
    content: Text("저장이 완료되었습니다."),
    backgroundColor: Colors.purple[800],
    duration: Duration(milliseconds: 1000),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), side: BorderSide(width: 0)),
    dismissDirection: DismissDirection.down,
  );

  void _setWord(String word) {
    setState(() {
      if (word.isNotEmpty) {
        _vocabulary.word = word;
      }
    });
  }

  void _setMeaning(String meaning) {
    setState(() {
      if (meaning.isNotEmpty) {
        _vocabulary.meaning = meaning;
      }
    });
  }

  void _setExample(String example) {
    setState(() {
      _vocabulary.example = example;
    });
  }

  void _onSwap() {
    setState(() {
      print("OnSwap ${_vocabulary.word}");
      String description = _vocabulary.meaning;
      _vocabulary.meaning = _vocabulary.word;
      _vocabulary.word = description;
      print("OnSwap ${_vocabulary.word}");
    });
  }

  void _onSave(int? id) async {
    print("onSave: ${id} / ${_formKey.currentState?.validate()}");
    if (_formKey.currentState?.validate() == true) {
      _formKey.currentState?.save();

      if (id != null) {
        await SqlVocaRepository.update(_vocabulary);
      } else {
        await SqlVocaRepository.create(_vocabulary);
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
          child: VocaInputWidget(
            onChangeVoca: _setWord,
            onChangeDescription: _setMeaning,
            onChangeExample: _setExample,
            onSwap: _onSwap,
            vocabulary: _vocabulary,
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
              print(snapshot.data);
              _vocabulary = snapshot.data!;
              return Form(
                  key: _formKey,
                  child: VocaInputWidget(
                    onChangeVoca: _setWord,
                    onChangeDescription: _setMeaning,
                    onChangeExample: _setExample,
                    onSwap: _onSwap,
                    vocabulary: snapshot.data,
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

class VocaInputWidget extends StatelessWidget {
  const VocaInputWidget(
      {super.key,
      required this.onChangeVoca,
      required this.onChangeDescription,
      required this.onChangeExample,
      required this.onSwap,
      this.vocabulary});

  final OnChangeVoca onChangeVoca;
  final OnChangeDescription onChangeDescription;
  final OnChangeExample onChangeExample;
  final OnSwap onSwap;
  final Vocabulary? vocabulary;

  renderTextFormField({
    required BuildContext context,
    required String label,
    required FormFieldSetter onSaved,
    required FormFieldValidator validator,
    required TextInputAction textInputAction,
    String? initialValue,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      SizedBox(height: 10),
      TextFormField(
        initialValue: initialValue,
        onSaved: onSaved,
        validator: validator,
        textInputAction: textInputAction,
        onChanged: onSaved,
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
            context: context,
            label: "단어",
            initialValue: vocabulary?.word,
            textInputAction: TextInputAction.next,
            onSaved: (val) {
              onChangeVoca(val);
            },
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
              context: context,
              label: "의미",
              initialValue: vocabulary?.meaning,
              textInputAction: TextInputAction.next,
              onSaved: (val) {
                onChangeDescription(val);
              },
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
              initialValue: vocabulary?.example,
              textInputAction: TextInputAction.done,
              onSaved: (val) {
                onChangeExample(val);
              },
              validator: (val) {
                return null;
              }),
        ],
      ),
    );
  }
}
