import 'package:flutter/material.dart';
import 'package:vocaboka/src/model/vocabulary.dart';
import 'package:vocaboka/src/repository/sql_voca_repository.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.title});

  final String title;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

typedef OnSetIsSaveEnabledCallback = void Function(bool enabled);
typedef OnChangeVoca = void Function(String voca);
typedef OnChangeDescription = void Function(String description);
typedef OnChangeExample = void Function(String example);

class _DetailScreenState extends State<DetailScreen> {
  final Vocabulary _vocabulary = Vocabulary(voca: "", description: "");
  bool _isSaveEnabled = false;

  void validateSave() {
    setIsSaveEnabled(
        _vocabulary.voca.isNotEmpty && _vocabulary.description.isNotEmpty);
  }

  // TODO: Use Form
  void onChangeVoca(String voca) {
    setState(() {
      if (voca.isNotEmpty) {
        _vocabulary.voca = voca;
      }
      validateSave();
    });
  }

  void onChangeDescription(String description) {
    setState(() {
      if (description.isNotEmpty) {
        _vocabulary.description = description;
      }
      validateSave();
    });
  }

  void onChangeExample(String example) {
    setState(() {
      _vocabulary.example = example;
      validateSave();
    });
  }

  void setIsSaveEnabled(bool enabled) {
    setState(() {
      _isSaveEnabled = enabled;
    });
  }

  void _onSave() async {
    await SqlVocaRepository.create(_vocabulary);
    Navigator.pop(context, true);
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
                        _onSave();
                      },
                      child: Text("저장",
                          style: TextStyle(
                              color: _isSaveEnabled
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).disabledColor,
                              fontWeight: FontWeight.bold))))
            ],
          ),
          backgroundColor: Colors.grey[200],
          elevation: 0.0,
        ),
        body: SafeArea(
            child: VocaInputWidget(
                onChangeVoca: onChangeVoca,
                onChangeDescription: onChangeDescription,
                onChangeExample: onChangeExample)));
  }
}

class VocaInputWidget extends StatelessWidget {
  const VocaInputWidget(
      {super.key,
      required this.onChangeVoca,
      required this.onChangeDescription,
      required this.onChangeExample});

  final OnChangeVoca onChangeVoca;
  final OnChangeDescription onChangeDescription;
  final OnChangeExample onChangeExample;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("단어",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          TextField(
            onChanged: onChangeVoca,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(30, 20, 30, 20),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(width: 0, style: BorderStyle.none)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(width: 0, style: BorderStyle.none)),
                filled: true,
                fillColor: Colors.grey[300]),
          ),
          SizedBox(height: 40),
          Text("의미",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          TextField(
            onChanged: onChangeDescription,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(30, 20, 30, 20),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                    borderSide: BorderSide(width: 0, style: BorderStyle.none)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(width: 0, style: BorderStyle.none)),
                filled: true,
                fillColor: Colors.grey[300]),
          ),
          SizedBox(height: 40),
          Text("예제",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          TextField(
            onChanged: onChangeExample,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(30, 20, 30, 20),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                    borderSide: BorderSide(width: 0, style: BorderStyle.none)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(width: 0, style: BorderStyle.none)),
                filled: true,
                fillColor: Colors.grey[300]),
          ),
        ],
      ),
    );
  }
}
