import 'package:flutter/material.dart';
import 'package:vocaboka/src/model/vocabulary.dart';
import 'package:vocaboka/src/repository/sql_voca_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void update() => setState(() {});

  Future<List<Vocabulary>> _load() async {
    return SqlVocaRepository.getAll();
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
                    datas!.length, (index) => VocaWidget(item: datas[index])));
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
            onPressed: () async {
              await Navigator.pushNamed(context, "/detail").then((res) {
                if (res != null && res is bool && res) {
                  update();
                }
              });
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

  const VocaWidget({
    super.key,
    required this.item,
  });

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
