import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class TaskData extends StatefulWidget {
  const TaskData({super.key});

  @override
  State<TaskData> createState() => _TaskDataState();
}

class _TaskDataState extends State<TaskData> {
  final CollectionReference _uploadsCollection =
      FirebaseFirestore.instance.collection('uploads');

  TextEditingController _editGradeController = TextEditingController();
  TextEditingController _editTitleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          flexibleSpace: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                'Task Uploads',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _uploadsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final uploads = snapshot.data?.docs;

          return uploads == null || uploads.isEmpty
              ? Center(
                  child: Text('No uploads found',
                      style: TextStyle(fontFamily: 'poppins', fontSize: 16)))
              : ListView.builder(
                  itemCount: uploads.length,
                  itemBuilder: (context, index) {
                    final upload = uploads[index];
                    final String userName = upload['userName'];
                    final String title = upload['title'];
                    final Timestamp uploadTime = upload['uploadTime'];
                    final String fileURL = upload['fileURL'];
                    final String grade = upload['grade'];
                    final String code = upload['code'];
                    final String noInduk = upload['noInduk'];
                    final String docId = upload.id; // Ambil ID dokumen

                    // Format uploadTime to a readable string
                    String formattedTime = DateFormat('HH:mm, dd-MM-yyyy ')
                        .format(uploadTime.toDate());

                    return Container(
                      decoration: BoxDecoration(
                          color: Color(0xffE8E9E7),
                          borderRadius: BorderRadius.circular(15)),
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(8),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.file_download_rounded),
                              onPressed: () => _launchUrl(fileURL),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _showDeleteConfirmation(docId),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('By  : $userName',
                                  style: TextStyle(fontFamily: 'poppins')),
                              Text('ID   : $noInduk',
                                  style: TextStyle(
                                    fontFamily: 'poppins',
                                  )),
                              Text('On : $formattedTime',
                                  style: TextStyle(fontFamily: 'poppins')),
                              Text('Course Code: $code',
                                  style: TextStyle(
                                    fontFamily: 'poppins',
                                  )),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Grade: $grade',
                                      style: TextStyle(
                                        fontFamily: 'poppins',
                                        fontWeight: FontWeight.w500,
                                      )),
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () =>
                                        _showEditDialog(docId, title, grade),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }

  void _showEditDialog(String docId, String currentTitle, String currentGrade) {
    _editTitleController.text = currentTitle;
    _editGradeController.text = currentGrade;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Grade Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _editTitleController,
                decoration: InputDecoration(labelText: 'Task Title'),
              ),
              TextField(
                controller: _editGradeController,
                decoration: InputDecoration(labelText: 'Grade'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _updateUpload(docId);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUpload(String docId) async {
    try {
      // Update the Firestore document with the new title and grade
      await _uploadsCollection.doc(docId).update({
        'title': _editTitleController.text,
        'grade': _editGradeController.text,
      });

      // Show success message and refresh the UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload updated successfully')),
      );
      setState(() {}); // Refresh the UI
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating upload: $e')),
      );
    }
  }

  Future<void> _launchUrl(String fileURL) async {
    final Uri _url = Uri.parse(fileURL);
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  void _showDeleteConfirmation(String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Upload'),
          content: Text('Are you sure you want to delete this upload?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _deleteUpload(docId);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUpload(String docId) async {
    try {
      await _uploadsCollection.doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting upload: $e')),
      );
    }
  }
}
