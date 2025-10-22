import 'package:database/data/local/db_helper.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController decController = TextEditingController();

  List<Map<String, dynamic>> allNotes = [];
  DbHelper? dbref;

  @override
  void initState() {
    super.initState();
    dbref = DbHelper.getInstance;
    getNotes();
  }

  void openUpdateDialog(int sno, String oldTitle, String oldDesc) {
  TextEditingController titleController =
      TextEditingController(text: oldTitle);
  TextEditingController descController =
      TextEditingController(text: oldDesc);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Update Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String newTitle = titleController.text;
              String newDesc = descController.text;

              if (newTitle.isNotEmpty && newDesc.isNotEmpty) {
                bool updated = await dbref!.updateNote(
                  mTitle: newTitle,
                  mDesc: newDesc,
                  sno: sno,
                );
                if (updated) {
                  Navigator.pop(context); // close dialog
                  getNotes(); // refresh notes
                }
              }
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
}


  void getNotes() async {
    allNotes = await dbref!.getAllNotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: allNotes.isNotEmpty
          ? ListView.builder(
              itemCount: allNotes.length,
              itemBuilder: (_, index) {
                return ListTile(
  leading: Text('${allNotes[index][DbHelper.COLUMN_NOTE_SNO]}'),
  title: Text(allNotes[index][DbHelper.COLUMN_NOTE_TITLE]),
  subtitle: Text(allNotes[index][DbHelper.COLUMN_NOTE_DESC]),
  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        icon: Icon(Icons.edit),
        onPressed: () {
          openUpdateDialog(
            allNotes[index][DbHelper.COLUMN_NOTE_SNO],
            allNotes[index][DbHelper.COLUMN_NOTE_TITLE],
            allNotes[index][DbHelper.COLUMN_NOTE_DESC],
          );
        },
      ),
      IconButton(
        icon: Icon(Icons.delete),
        onPressed: () async {
          bool check = await dbref!.deleteNote(
            sno: allNotes[index][DbHelper.COLUMN_NOTE_SNO],
          );
          if (check) {
            getNotes(); // refresh after deleting
          }
        },
      ),
    ],
  ),
);

              },
            )
          : const Center(child: Text('No Notes Yet!!')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return BottomSheetView(
                titleController: titleController,
                decController: decController,
                dbref: dbref!,
                getNotes: getNotes,
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class BottomSheetView extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController decController;
  final DbHelper dbref;
  final Function getNotes;

  const BottomSheetView({
    super.key,
    required this.titleController,
    required this.decController,
    required this.dbref,
    required this.getNotes,
  });

  @override
  State<StatefulWidget> createState() {
    return _BottomSheetViewState();
  }
}

class _BottomSheetViewState extends State<BottomSheetView> {
  String errorMsg = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      width: double.infinity,
      child: Column(
        children: [
          const Text(
            "Add Note",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 21),
          TextField(
            controller: widget.titleController,
            decoration: InputDecoration(
              hintText: "Enter title here",
              label: const Text("Title"),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
          const SizedBox(height: 11),
          TextField(
            maxLines: 6,
            controller: widget.decController,
            decoration: InputDecoration(
              hintText: "Enter Description here",
              label: const Text("Description"),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
          const SizedBox(height: 21),
          Row(
            children: [
              OutlinedButton(
                onPressed: () async {
                  var title = widget.titleController.text;
                  var desc = widget.decController.text;
                  if (title.isNotEmpty && desc.isNotEmpty) {
                    bool check = await widget.dbref.addNote(
                      mTitle: title,
                      mDesc: desc,
                    );
                    if (check) {
                      widget.getNotes();
                    }
                    widget.titleController.clear();
                    widget.decController.clear();
                    Navigator.pop(context);
                  } else {
                    errorMsg = "Please Fill All The Required Blanks";
                    setState(() {});
                  }
                },
                child: const Text("Add Note"),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel"),
              ),
              Text(errorMsg),
            ],
          ),
        ],
      ),
    );
  }
}
