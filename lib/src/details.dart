import 'package:flutter/material.dart';
import 'package:vocaboka/src/model/vocabulary.dart';
import 'package:vocaboka/src/repository/sql_voca_repository.dart';

class DetailsScreenArguments {
  final String title;
  final int? vocaId;

  DetailsScreenArguments(this.title, this.vocaId);
}

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key, required this.title, this.id});

  final String title;
  final int? id;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

typedef OnChangeVoca = void Function(String voca);
typedef OnChangeDescription = void Function(String description);
typedef OnChangeExample = void Function(String example);

class _DetailsScreenState extends State<DetailsScreen> {
  Vocabulary _vocabulary = Vocabulary(voca: "", description: "");
  final _formKey = GlobalKey<FormState>();
  final _snackBar = SnackBar(
    content: Text("저장이 완료되었습니다."),
    backgroundColor: Colors.purple[800],
    duration: Duration(milliseconds: 1000),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), side: BorderSide(width: 0)),
    dismissDirection: DismissDirection.down,
  );

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

  Widget renderFormWidget(id) {
    if (id == null) {
      return Form(
          key: _formKey,
          child: VocaInputWidget(
              onChangeVoca: setVoca,
              onChangeDescription: setDescription,
              onChangeExample: setExample));
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
                    onChangeVoca: setVoca,
                    onChangeDescription: setDescription,
                    onChangeExample: setExample,
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
      this.vocabulary});

  final OnChangeVoca onChangeVoca;
  final OnChangeDescription onChangeDescription;
  final OnChangeExample onChangeExample;
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
            initialValue: vocabulary?.voca,
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
          SizedBox(height: 40),
          renderTextFormField(
              context: context,
              label: "의미",
              initialValue: vocabulary?.description,
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
