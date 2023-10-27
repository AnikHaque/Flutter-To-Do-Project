import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: TodoApp(),
  ));
}

class Task {
  String title;
  String description;

  Task({required this.title, required this.description});
}

class TodoApp extends StatefulWidget {
  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  final List<Task> tasks = [];
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  void _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? title = prefs.getString('title');
    String? description = prefs.getString('description');

    if (title != null && description != null) {
      titleController.text = title;
      descriptionController.text = description;
    }
  }

  void _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('title', titleController.text);
    prefs.setString('description', descriptionController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo App'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: titleController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Title'),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Description'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _addTask();
            },
            child: Text('Add Task'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Text((index + 1).toString()),
                  ),
                  title: Text(tasks[index].title),
                  subtitle: Text(tasks[index].description),
                  onLongPress: () {
                    _showTaskDialog(tasks[index], index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addTask() {
    if (titleController.text.isNotEmpty && descriptionController.text.isNotEmpty) {
      tasks.add(Task(
        title: titleController.text,
        description: descriptionController.text,
      ));
      titleController.clear();
      descriptionController.clear();
      _saveData();
      setState(() {});
    }
  }

  void _showTaskDialog(Task? task, int index) {
    titleController.text = task?.title ?? '';
    descriptionController.text = task?.description ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Task Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(

                controller: titleController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  labelText: 'Title'),
              ),
              SizedBox(height: 20,),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Description'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (index == -1) {
                  tasks.add(Task(
                    title: titleController.text,
                    description: descriptionController.text,
                  ));
                } else {
                  tasks[index] = Task(
                    title: titleController.text,
                    description: descriptionController.text,
                  );
                }
                titleController.clear();
                descriptionController.clear();
                Navigator.of(context).pop();
                _saveData();
                setState(() {});
              },
              child: Text('Edit Don'),
            ),
            if (task != null)
              TextButton(
                onPressed: () {
                  tasks.removeAt(index);
                  Navigator.of(context).pop();
                  _saveData();
                  setState(() {});
                },
                child: Text('Delete'),
              ),
          ],
        );
      },
    );
  }
}
