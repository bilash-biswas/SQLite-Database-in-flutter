import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_practise/data/local/db_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController titleEditingController = TextEditingController();
  TextEditingController descriptionEditingController = TextEditingController();
  List<Map<String, dynamic>> allNotes = [];
  DBHelper? dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper.instance;
    getNotes();
  }

  void getNotes() async {
    allNotes = await dbHelper!.getAllNotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        backgroundColor: Colors.orange,
      ),
      body: allNotes.isNotEmpty
          ? ListView.builder(
              itemCount: allNotes.length,
              itemBuilder: (_, index) {
                return Card(
                  child: ListTile(
                    leading: Text((index + 1).toString()),
                    title: Text(allNotes[index][DBHelper.columnNoteTitle]),
                    subtitle: Text(allNotes[index][DBHelper.columnNoteDesc]),
                    trailing: SizedBox(
                      width: 50,
                      child: Row(
                        children: [
                          InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      titleEditingController.text =
                                          allNotes[index]
                                              [DBHelper.columnNoteTitle];
                                      descriptionEditingController.text =
                                          allNotes[index]
                                              [DBHelper.columnNoteDesc];
                                      return showModelBottomSheet(
                                          isUpdate: true,
                                          serialNo: allNotes[index]
                                              [DBHelper.columnNoteSNo]);
                                    });
                              },
                              child: const Icon(Icons.edit)),
                          InkWell(
                              onTap: () async {
                                bool check = await dbHelper!.deleteNote(
                                    serialNo: allNotes[index]
                                        [DBHelper.columnNoteSNo]);
                                if (check) {
                                  getNotes();
                                }
                              },
                              child: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ))
                        ],
                      ),
                    ),
                  ),
                );
              })
          : const Center(child: Text('Empty Notes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return showModelBottomSheet();
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget showModelBottomSheet({bool isUpdate = false, int serialNo = 0}) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            const SizedBox(
              height: 21,
            ),
            Text(
              isUpdate ? 'Update Note' : 'Add Note',
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 21,
            ),
            TextField(
              controller: titleEditingController,
              decoration: InputDecoration(
                  label: const Text('Title'),
                  hintText: 'Enter Title Here',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(21),
                  )),
            ),
            const SizedBox(
              height: 21,
            ),
            TextField(
              controller: descriptionEditingController,
              maxLines: 4,
              decoration: InputDecoration(
                  label: const Text('Description'),
                  hintText: 'Enter Description Here',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(21),
                  )),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11))),
                      onPressed: () async {
                        var title = titleEditingController.text;
                        var description = descriptionEditingController.text;
                        if (title.isNotEmpty && description.isNotEmpty) {
                          bool check = isUpdate
                              ? await dbHelper!.updateNote(
                                  title: title,
                                  description: description,
                                  serialNo: serialNo)
                              : await dbHelper!
                                  .addNote(mTitle: title, mDesc: description);
                          if (check) {
                            getNotes();
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please Enter All the filed')));
                        }
                        titleEditingController.clear();
                        descriptionEditingController.clear();
                        Navigator.pop(context);
                      },
                      child: Text(isUpdate ? 'Update Note' : 'Add Note')),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11))),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel')),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
