import 'package:flutter/material.dart';
import 'package:vocaboka/src/model/vocabulary.dart';
import 'package:vocaboka/src/repository/sql_database.dart';
import 'package:vocaboka/src/repository/sql_voca_repository.dart';

void main() {
  // Firebase widget binding
  WidgetsFlutterBinding.ensureInitialized();
  SqlDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vocaboka',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'Vocaboka'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _createTempVoca() async {
    var voca = Vocabulary(voca: "take a stand", description: "take a stand");
    await SqlVocaRepository.create(voca);
    update();
  }

  void update() => setState(() {});

  Future<List<Vocabulary>> _load() async {
    return SqlVocaRepository.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Row(
          children: const [
            SizedBox(width: 10),
            Text("보카보까 \u{1F440}", style: TextStyle(color: Colors.black))
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
            onPressed: update, // TODO: Make _shuffle function
            tooltip: 'Shuffle',
            child: const Icon(Icons.shuffle),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _createTempVoca,
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
