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

                    // Format uploadTime to a readable string
                    String formattedTime = DateFormat('yyyy-MM-dd HH:mm')
                        .format(uploadTime.toDate());

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 24,
                          child: Icon(Icons.person, color: Colors.white),
                          backgroundColor: Colors.grey,
                        ),
                        title: Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('By: $userName',
                                style: TextStyle(fontFamily: 'poppins')),
                            Text('On: $formattedTime',
                                style: TextStyle(fontFamily: 'poppins')),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.file_download),
                          onPressed: () => _launchUrl(fileURL),
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }

  Future<void> _launchUrl(String fileURL) async {
    final Uri _url = Uri.parse(fileURL);
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }
}
