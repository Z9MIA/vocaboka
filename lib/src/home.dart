import 'package:flutter/material.dart';
import 'package:vocaboka/src/details.dart';
import 'package:vocaboka/src/model/vocabulary.dart';
import 'package:vocaboka/src/repository/sql_voca_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

typedef OnEdit = void Function(int id);

class _HomeScreenState extends State<HomeScreen> {
  void update() => setState(() {});

  Future<List<Vocabulary>> _load() async {
    return SqlVocaRepository.getAll();
  }

  Future<void> _navigateAndUpdateList() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const DetailsScreen(title: "새 단어")));
    print(result);

    if (result != null && result is bool && result) {
      update();
    }
  }

  void onEdit(int id) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailsScreen(
                  title: "단어 편집",
                  id: id,
                )));
    print(result);

    if (result != null && result is bool && result) {
      update();
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
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold))
          ],
        ),
        backgroundColor: Colors.grey[200],
        elevation: 0.0,
      ),
      body: SafeArea(
          child: FutureBuilder<List<Vocabulary>>(
        future: _load(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Not Support Sqflite'));
          }

          if (snapshot.hasData) {
            var datas = snapshot.data;
            return ListView(
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                itemExtent: 200,
                children: List.generate(
                    datas!.length,
                    (index) => VocaWidget(
                          item: datas[index],
                          onEdit: onEdit,
                        )));
          }

          return Center(child: CircularProgressIndicator());
        },
      )),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "shuffle",
            onPressed: () {
              // TODO: onPressed shuffle
            },
            tooltip: 'Shuffle',
            child: const Icon(Icons.shuffle),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "add",
            onPressed: _navigateAndUpdateList,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class VocaWidget extends StatefulWidget {
  final Vocabulary item;
  final OnEdit onEdit;

  const VocaWidget({super.key, required this.item, required this.onEdit});

  @override
  State<VocaWidget> createState() => _VocaWidgetState();
}

class _VocaWidgetState extends State<VocaWidget> {
  bool _showDescription = false;

  void _toggleShowDescription() {
    setState(() {
      _showDescription = !_showDescription;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: InkWell(
            onTap: _toggleShowDescription,
            onLongPress: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) => ModalBottomSheetWidget(
                      item: widget.item, onEdit: widget.onEdit));
            },
            child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.all(10),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.item.voca,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Visibility(
                            visible: _showDescription,
                            child: Text(widget.item.description,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent)),
                          ),
                        ])))));
  }
}

class ModalBottomSheetWidget extends StatelessWidget {
  const ModalBottomSheetWidget(
      {super.key, required this.item, required this.onEdit});

  final Vocabulary item;
  final OnEdit onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 15.0, bottom: 30.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
              leading: Icon(Icons.folder),
              title: Text("그룹 변경"),
              onTap: () {
                print("onTap Photo");
              }),
          ListTile(
              leading: Icon(Icons.edit),
              title: Text("편집"),
              onTap: () {
                onEdit(item.id!);
              }),
          ListTile(
              leading: Icon(Icons.delete),
              title: Text("삭제"),
              onTap: () {
                print("onTap Photo");
              })
        ],
      ),
    );
  }
}
