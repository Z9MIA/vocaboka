import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:vocaboka/src/details.dart';
import 'package:vocaboka/src/model/vocabulary.dart';
import 'package:vocaboka/src/repository/sql_voca_repository.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:flutter/scheduler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  final String title = '보카보까 \u{1F440}';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

typedef OnEdit = void Function(int id);
typedef OnDelete = void Function(int id);

class _HomeScreenState extends State<HomeScreen> {
  void update() => setState(() {});

  Future<List<Vocabulary>> _load() async {
    return SqlVocaRepository.getAll();
  }

  Future<void> _navigateAndUpdateList(BuildContext context, String? initialValue) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                DetailsScreen(title: "새 단어", initialValue: initialValue)));

    if (result != null && result is bool && result) {
      update();
    }
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      listenShareMediaFiles(context);
    });
  }

  void listenShareMediaFiles(BuildContext context) {
    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    ReceiveSharingIntent.getTextStream().listen((String value) {
      print("Receive Text: ${value}");
      var sharedText = value.split("\n")[0].replaceAll('"', "").toLowerCase();
      print("Change Received Text: ${sharedText}");
      
      _navigateAndUpdateList(context, sharedText);
    }, onError: (err) {
      print("getTextStream error: $err");
    });
  }

  void onEdit(int id) async {
    Navigator.pop(context);
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

  void onDelete(int id) async {
    Navigator.pop(context);
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              content: SingleChildScrollView(
                  child: ListBody(
                children: <Widget>[Text("정말로 삭제하실건가요?")],
              )),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Theme.of(context).disabledColor),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                    child: Text("Delete"),
                    onPressed: () async {
                      Navigator.pop(context);
                      await SqlVocaRepository.delete(id);
                      update();
                    })
              ]);
        });
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
                          onDelete: onDelete,
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
            onPressed: () {
              _navigateAndUpdateList(context, null);
            },
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
  final OnDelete onDelete;

  const VocaWidget(
      {super.key,
      required this.item,
      required this.onEdit,
      required this.onDelete});

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
                        item: widget.item,
                        onEdit: widget.onEdit,
                        onDelete: widget.onDelete,
                      ));
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
                          Text(widget.item.word,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Visibility(
                            visible: _showDescription,
                            child: Text(widget.item.meaning,
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
      {super.key,
      required this.item,
      required this.onEdit,
      required this.onDelete});

  final Vocabulary item;
  final OnEdit onEdit;
  final OnDelete onDelete;

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
                onDelete(item.id!);
              })
        ],
      ),
    );
  }
}
