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
  bool isLoading = false;

  Future<void> pickFolder() async {
    String? path = await FilePicker.platform.getDirectoryPath();

    if (path != null) {
      setState(() {
        selectedFolder = path;
        status = "Folder wybrany";
      });
    }
  }

  String getUniquePath(String dirPath, String fileName) {
    String newPath = "$dirPath/$fileName";
    int counter = 1;

    while (File(newPath).existsSync()) {
      String name = fileName.split('.').first;
      String ext = fileName.contains('.') ? ".${fileName.split('.').last}" : "";
      newPath = "$dirPath/${name}_$counter$ext";
      counter++;
    }

    return newPath;
  }

  Future<void> organizeFiles() async {
    if (selectedFolder == null) return;

    setState(() {
      isLoading = true;
      status = "Przetwarzanie...";
    });

    Directory dir = Directory(selectedFolder!);
    List<FileSystemEntity> files = dir.listSync();

    Directory images = Directory("${selectedFolder!}/Obrazy");
    Directory docs = Directory("${selectedFolder!}/Dokumenty");
    Directory installers = Directory("${selectedFolder!}/Instalatory");
    Directory others = Directory("${selectedFolder!}/Inne");

    if (!images.existsSync()) images.createSync();
    if (!docs.existsSync()) docs.createSync();
    if (!installers.existsSync()) installers.createSync();
    if (!others.existsSync()) others.createSync();

    int moved = 0;

    for (var file in files) {
      if (file is File) {
        String fileName = file.uri.pathSegments.last;

        // ignoruj pliki już w folderach docelowych
        if (file.path.contains("/Obrazy") ||
            file.path.contains("/Dokumenty") ||
            file.path.contains("/Instalatory") ||
            file.path.contains("/Inne")) continue;

        String ext = fileName.contains('.')
            ? fileName.split('.').last.toLowerCase()
            : "";

        Directory targetDir;

        if (["jpg", "png", "jpeg", "gif", "webp"].contains(ext)) {
          targetDir = images;
        } else if (["pdf", "doc", "docx", "txt", "xls", "xlsx"].contains(ext)) {
          targetDir = docs;
        } else if (["exe", "msi", "apk"].contains(ext)) {
          targetDir = installers;
        } else {
          targetDir = others;
        }

        try {
          String newPath = getUniquePath(targetDir.path, fileName);
          file.renameSync(newPath);
          moved++;
        } catch (e) {
          // fallback: kopiuj + usuń
          try {
            String newPath = getUniquePath(targetDir.path, fileName);
            await file.copy(newPath);
            await file.delete();
            moved++;
          } catch (_) {}
        }
      }
    }

    setState(() {
      isLoading = false;
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
              onPressed: isLoading ? null : pickFolder,
              icon: Icon(Icons.folder_open),
              label: Text("Wybierz folder"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: isLoading ? null : organizeFiles,
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
        if (isLoading) CircularProgressIndicator(),
        SizedBox(height: 10),
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
          subtitle: Text("jpg, png, jpeg, gif"),
        ),
        ListTile(
          leading: Icon(Icons.description, color: Colors.orange),
          title: Text("Dokumenty"),
          subtitle: Text("pdf, doc, txt, xls"),
        ),
        ListTile(
          leading: Icon(Icons.settings, color: Colors.red),
          title: Text("Instalatory"),
          subtitle: Text("exe, msi, apk"),
        ),
        ListTile(
          leading: Icon(Icons.folder, color: Colors.grey),
          title: Text("Inne"),
          subtitle: Text("pozostałe pliki"),
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