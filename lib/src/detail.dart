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
  final _formKey = GlobalKey<FormState>();
  final snackBar = SnackBar(
    content: Text("저장이 완료되었습니다."),
    backgroundColor: Colors.purple[800],
    duration: Duration(milliseconds: 1000),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), side: BorderSide(width: 0)),
    dismissDirection: DismissDirection.down,
  );

  // TODO: Use Form
  void setVoca(String voca) {
    setState(() {
      if (voca.isNotEmpty) {
        _vocabulary.voca = voca;
      }
    });
  }

  void setDescription(String description) {
    setState(() {
      if (description.isNotEmpty) {
        _vocabulary.description = description;
      }
    });
  }

  void setExample(String example) {
    setState(() {
      _vocabulary.example = example;
    });
  }

  void _onSave() async {
    print("onSave: ${_formKey.currentState?.validate()}");
    if (_formKey.currentState?.validate() == true) {
      _formKey.currentState?.save();

      await SqlVocaRepository.create(_vocabulary);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.pop(context, true);
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
                        _onSave();
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
        body: SafeArea(
            child: Form(
          key: _formKey,
          child: VocaInputWidget(
              onChangeVoca: setVoca,
              onChangeDescription: setDescription,
              onChangeExample: setExample),
        )));
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

  renderTextFormField({
    required String label,
    required FormFieldSetter onSaved,
    required FormFieldValidator validator,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      SizedBox(height: 10),
      TextFormField(
        onSaved: onSaved,
        validator: validator,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(30, 20, 30, 20),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: BorderSide(width: 0, style: BorderStyle.none)),
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
              label: "단어",
              onSaved: (val) {
                onChangeVoca(val);
              },
              validator: (val) {
                if (val.length < 1) {
                  return "단어는 필수 입력사항입니다.";
                }
                return null;
              }),
          SizedBox(height: 40),
          renderTextFormField(
              label: "의미",
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
              label: "예제",
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
