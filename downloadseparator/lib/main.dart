import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Download Cleaner',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: FileOrganizerPage(),
    );
  }
}

class FileOrganizerPage extends StatefulWidget {
  @override
  _FileOrganizerPageState createState() => _FileOrganizerPageState();
}

class _FileOrganizerPageState extends State<FileOrganizerPage> {
  String? selectedFolder;
  String status = "Gotowy";

  Future<void> pickFolder() async {
    String? path = await FilePicker.platform.getDirectoryPath();

    if (path != null) {
      setState(() {
        selectedFolder = path;
        status = "Folder wybrany";
      });
    }
  }

  Future<void> organizeFiles() async {
    if (selectedFolder == null) return;

    Directory dir = Directory(selectedFolder!);
    List<FileSystemEntity> files = dir.listSync();

    Directory images = Directory("${selectedFolder!}/Obrazy");
    Directory docs = Directory("${selectedFolder!}/Dokumenty");
    Directory installers = Directory("${selectedFolder!}/Instalatory");

    if (!images.existsSync()) images.createSync();
    if (!docs.existsSync()) docs.createSync();
    if (!installers.existsSync()) installers.createSync();

    int moved = 0;

    for (var file in files) {
      if (file is File) {
        String ext = file.path.split('.').last.toLowerCase();

        try {
          if (["jpg", "png", "jpeg"].contains(ext)) {
            file.renameSync("${images.path}/${file.uri.pathSegments.last}");
            moved++;
          } else if (["pdf", "doc", "docx", "txt"].contains(ext)) {
            file.renameSync("${docs.path}/${file.uri.pathSegments.last}");
            moved++;
          } else if (["exe", "msi", "apk"].contains(ext)) {
            file.renameSync("${installers.path}/${file.uri.pathSegments.last}");
            moved++;
          }
        } catch (e) {
          // np. plik już istnieje
        }
      }
    }

    setState(() {
      status = "Przeniesiono $moved plików";
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Gotowe ✅"),
        content: Text("Przeniesiono $moved plików"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          )
        ],
      ),
    );
  }

  Widget buildCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.folder, size: 60, color: Colors.indigo),
            SizedBox(height: 15),
            Text(
              selectedFolder ?? "Nie wybrano folderu",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: pickFolder,
              icon: Icon(Icons.folder_open),
              label: Text("Wybierz folder"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: organizeFiles,
              icon: Icon(Icons.cleaning_services),
              label: Text("Segreguj pliki"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStatus() {
    return Column(
      children: [
        SizedBox(height: 20),
        Text(
          "Status: $status",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget buildInfo() {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.image, color: Colors.blue),
          title: Text("Obrazy"),
          subtitle: Text("jpg, png, jpeg"),
        ),
        ListTile(
          leading: Icon(Icons.description, color: Colors.orange),
          title: Text("Dokumenty"),
          subtitle: Text("pdf, doc, txt"),
        ),
        ListTile(
          leading: Icon(Icons.settings, color: Colors.red),
          title: Text("Instalatory"),
          subtitle: Text("exe, msi, apk"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Download Cleaner"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildCard(),
            buildStatus(),
            SizedBox(height: 20),
            buildInfo(),
          ],
        ),
      ),
    );
  }
}
