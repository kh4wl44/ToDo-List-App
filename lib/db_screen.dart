import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class DbScreen extends StatefulWidget {
  const DbScreen({super.key});

  @override
  State<DbScreen> createState() => _DbScreenState();
}

class _DbScreenState extends State<DbScreen> {
  late Database db;
  List<Map>? todoList;
  var titleController = TextEditingController();
  var contentController = TextEditingController();

  Future<void> initDatabase() async {
    db = await openDatabase("todo.db", version: 1,
        onCreate: (database, version) async {  //works one time when first creating database
          await database.execute(
              "CREATE TABLE todo (id INTEGER PRIMARY KEY, title TEXT, content TEXT)");
          print("table created!!");
        },
        onOpen: (database) async {   //works everytime the database is opened, gets database
          todoList = await database.rawQuery("SELECT * FROM todo"); //gets all data from todo table


        }
        );


  }


  Future<void> addTodo(String title, String content) async { // function to insert into db
    await db.transaction((action) async {
      int newID = await action.rawInsert(
          'insert into todo(title, content) values("$title", "$content")');
      print("added id $newID");
    });
    loadTodos();  // loads new insertions along with the old ones
  }

  var color = Colors.blue;

  void loadTodos() {
    setState(() {});
    db.transaction((action) async {
      todoList = await action.rawQuery("SELECT * FROM todo");
    });
  }


  Future<void> updateTodo(int id, String title, String content) async {
    await db.transaction((action) async {
      await action.rawUpdate(
          "UPDATE todo SET title = ?, content = ? WHERE id = ?",
          [title, content, id]);
      print("updated successfully");
    });
    loadTodos(); // Reload the updated list
  }


  void deleteTodo(int id) {
    db.transaction((action) async {
      await action.rawDelete("DELETE FROM todo WHERE id = ?", [id]);
      print("deleted successfully");
    });
  }


  @override
  void initState() {
    initDatabase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff4f0ad),
      appBar: AppBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(80),
            ),
          ),

        title: const Text("My To-Do", style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 25)),
        centerTitle: true, backgroundColor: Color(0xffFCCD2A),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xffFCCD2A),
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextField(
                            controller: titleController,
                            decoration: const InputDecoration(labelText: "Title"),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextField(
                            controller: contentController,
                            decoration:
                            const InputDecoration(labelText: "Content"),
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              addTodo(
                                  titleController.text, contentController.text);
                              titleController.text = "";
                              contentController.text = "";
                              Navigator.pop(context);
                            },
                            child: const Text("Save")
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel")
                        ),
                      ],
                    ),
                  );
                });
          }),
      body: todoList == null
          ? const Center(child: CircularProgressIndicator())
          : todoList!.isEmpty
          ? const Center(
        child: Text(
          "To Do List is Empty",
          style: TextStyle(fontSize: 30, color: Color(0xff2e2e2d)),
        ),
      )
          : ListView.builder(
        itemCount: todoList?.length ?? 0,
        itemBuilder: (c, index) {

          final id = todoList![index]["id"];
          final title = todoList![index]["title"];
          final content = todoList![index]["content"];


          return Dismissible(
            key: Key(id.toString()), // Unique key for each item
            direction: DismissDirection.endToStart, // Swipe from right to left
            onDismissed: (direction) {

              deleteTodo(id);
              // Call delete function
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(
              //     content: Text("$title deleted"),
              //   ),
              // );


            },
            background: Container(
              color: Colors.red,
              // Background color when swiped
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: GestureDetector(
              onTap: () {
                titleController.text = title; // Set the current title
                contentController.text = content; // Set the current content

                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextField(
                              controller: titleController,
                              decoration: const InputDecoration(labelText: "Title"),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextField(
                              controller: contentController,
                              decoration: const InputDecoration(labelText: "Content"),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              updateTodo(id, titleController.text, contentController.text);
                              titleController.clear();
                              contentController.clear();
                              Navigator.pop(context);
                            },
                            child: const Text("Update"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel"),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 5.0),
                child: Card(
                  child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0, left: 15.0),
                          child: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0, top: 5.0),
                          child: Text(
                            content,
                            style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 20),
                          ),
                        ),
                        const Divider(color: Colors.transparent,),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}