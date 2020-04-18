import 'package:flutter/material.dart';
import 'package:flutterappnootkeepersqllite/database_helper.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'note.dart';
import 'note_list.dart';
import 'package:sqflite/sql.dart';


class NoteDetail extends StatefulWidget{

  final String appBarTitle;
  final Note note;

  NoteDetail(this.note,this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note,this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail>{

static var _priorities=['High','Low'];
DatabaseHelper databaseHelper=DatabaseHelper();
TextEditingController titleController = TextEditingController();
TextEditingController descriptionController = TextEditingController();
Note note;
String appBarTitle;
NoteDetailState(this.note,this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle=Theme.of(context).textTheme.title;

    titleController.text=note.title;
    descriptionController.text=note.description;
    return WillPopScope(

        onWillPop: () {
          // Write some code to control things, when user press Back navigation button in device navigationBar
          moveToLastScreen();
        },
      child: Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        leading: IconButton(icon: Icon(
                                                Icons.arrow_back),
                                                 onPressed: (){
                                                   moveToLastScreen();
                                                 }
                                        ),
                ),

      body: Padding(
        padding: EdgeInsets.only(top: 15.0,left: 10.0,right: 10.0),
        child: ListView(
          children: <Widget>[
            //first element
            ListTile(
              title: DropdownButton(
                items: _priorities.map((String dropDownStingItem){
                  return DropdownMenuItem<String>(
                    value: dropDownStingItem,
                    child: Text(dropDownStingItem),
                  );
                }).toList(),

                style: textStyle,
                value: getPriorityAsString(note.priority),

                onChanged: (valueSelectedByUser){
                  setState(() {
                    debugPrint('User selected $valueSelectedByUser');
                    updatePriorityAsInt(valueSelectedByUser);
                  });
                }
              ),
            ),

            //Second Element

            Padding(
              padding: EdgeInsets.only(top: 15.0,bottom: 15.0),
              child: TextField(
                controller: titleController,
                style: textStyle,
                onChanged: (value){
                  debugPrint('Something changed in tiltle text field');
                  updateTitle();
                },
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: textStyle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0)
                  )
                ),
              ),
            ),

            //Third Element
            Padding(
              padding: EdgeInsets.only(top: 15.0,bottom: 15.0),
              child: TextField(
                controller: descriptionController,
                style: textStyle,
                onChanged: (value){
                  debugPrint('Something changed in description text field');
                  updateDescription();
                },
                decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)
                    )
                ),
              ),
            ),

            //Fourth element

            Padding(
               padding: EdgeInsets.only(top: 15.0,bottom: 15.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      child: Text(
                        'Save',
                        textScaleFactor: 1.5,
                      ),
                      onPressed: (){
                        setState(() {
                          debugPrint("Savr button clicked");
                          _save();
                        });
                      },
                    ),
                  ),

                  Container(width: 5.0,),
                  //delete button
                  Expanded(
                    child: RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      child: Text(
                        'delete',
                        textScaleFactor: 1.5,
                      ),
                      onPressed: (){
                        setState(() {
                          debugPrint("Delete button clicked");
                          _delete();
                        });
                      },
                    ),
                  ),
                ],
              ),
            )


          ],
        ),
      ),
    ));
  }

  void moveToLastScreen(){
    Navigator.pop(context,true);
  }

// Convert the String priority in the form of integer before saving it to Database
void updatePriorityAsInt(String value) {
  switch (value) {
    case 'High':
      note.priority = 1;
      break;
    case 'Low':
      note.priority = 2;
      break;
  }
}

// Convert int priority to String priority and display it to user in DropDown
String getPriorityAsString(int value) {
  String priority;
  switch (value) {
    case 1:
      priority = _priorities[0];  // 'High'
      break;
    case 2:
      priority = _priorities[1];  // 'Low'
      break;
  }
  return priority;
}

  void updateTitle(){
    note.title = titleController.text;
  }

  // Update the description of Note object
  void updateDescription() {
    note.description = descriptionController.text;
  }

  // Save data to database
  void _save() async {

    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {  // Case 1: Update operation
      result = await databaseHelper.updateNote(note);
    } else { // Case 2: Insert Operation
      result = await databaseHelper.insertNote(note);
    }

    if (result != 0) {  // Success
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {  // Failure
      _showAlertDialog('Status', 'Problem Saving Note');
    }

  }

  void _delete() async {

    moveToLastScreen();

    // Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
    // the detail page by pressing the FAB of NoteList page.
    if (note.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }

    // Case 2: User is trying to delete the old note that already has a valid ID.
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occured while Deleting Note');
    }
  }


  void _showAlertDialog(String title, String message) {

    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
  }

}