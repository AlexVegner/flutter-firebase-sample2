import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const String COLLECTION = 'sample-2';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase ToDo crud',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Firebase ToDo crud'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _newTaskName = '';

  void _deleteItem(String item) {
    DocumentReference df =
        Firestore.instance.collection(COLLECTION).document(item);
    df.delete();
  }

  void _updateNewTaskName(String value) {
    _newTaskName = value;
  }

  void _addItem() {
    Firestore.instance
        .collection(COLLECTION)
        .document(_newTaskName)
        .setData({'title': _newTaskName});
    setState(() {
      _newTaskName = '';
    });
    Navigator.of(context).pop();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add ToDo"),
          content: TextField(
            onChanged: _updateNewTaskName,
          ),
          actions: <Widget>[
            FlatButton(child: Text("Add"), onPressed: _addItem),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _showAddDialog,
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection(COLLECTION).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (BuildContext context, int index) {
                  DocumentSnapshot ds = snapshot.data.documents[index];
                  return Dismissible(
                    key: Key(ds['title']),
                    child: ListTile(
                      title: Text(ds['title']),
                    ),
                    onDismissed: (DismissDirection direction) {
                      _deleteItem(ds['title']);
                    },
                  );
                });
          } else {
            return Align(
              alignment: FractionalOffset.bottomCenter,
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
