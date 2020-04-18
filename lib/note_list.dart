import 'dart:async';
import 'package:flutter/material.dart';
import 'note.dart';
import 'database_helper.dart';
import 'note_detail.dart';
import 'package:sqflite/sqflite.dart';



class NoteList extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {

    return NoteListState();
  }
}

class NoteListState extends State<NoteList>{

  DatabaseHelper databaseHelper=new DatabaseHelper();
  List<Note> notelist;
  int count=0;
  @override
  Widget build(BuildContext context) {
    if(notelist==null){
      notelist=List<Note>();
      updateListView();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          debugPrint("FAB Clicked");

         navigateToDetail(Note('','',2),'Add Note');
        },
        tooltip: 'Add Note',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView(){
    TextStyle titleStyle=Theme.of(context).textTheme.subhead;
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext cotext,int position){
        return Card(
          color: Colors.white,
          elevation: 20,
          child: ListTile(
            leading: CircleAvatar
              (
              backgroundColor: getPriorityColor(this.notelist[position].priority),
              child: getPriorityIcon(this.notelist[position].priority),
            ),
            title: Text(this.notelist[position].title,style: titleStyle,),
            subtitle: Text(this.notelist[position].date),
            trailing: GestureDetector(
              child: Icon(Icons.delete,color: Colors.grey,),
              onTap: (){
                _delete(context, notelist[position]);
              },
            ),
            onTap: (){
              debugPrint("testing");
              navigateToDetail(this.notelist[position],'Edit Note');

            },
          ),

        );
      },
    );
  }

  Color getPriorityColor(int priority){
    switch (priority){
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;

      default:
        return Colors.yellow;
    }
  }

  // Returns the priority icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;

      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }


  void _delete(BuildContext context, Note note) async {

    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
       updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {

    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Note note,String title) async{
   bool result= await Navigator.push(context, MaterialPageRoute(builder: (context){
      return NoteDetail(note,title);
    }));

   if(result==true){
     updateListView();
   }
  }

  void updateListView() {

    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {

      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.notelist = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}