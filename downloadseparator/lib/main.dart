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
  double progress = 0;

  List<Map<String, String>> history = []; // do cofania

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
      String name = fileName.contains('.')
          ? fileName.substring(0, fileName.lastIndexOf('.'))
          : fileName;

      String ext = fileName.contains('.')
          ? fileName.substring(fileName.lastIndexOf('.'))
          : "";

      newPath = "$dirPath/${name}_$counter$ext";
      counter++;
    }

    return newPath;
  }

  Map<String, List<String>> categories = {
    "Obrazy": ["jpg", "png", "jpeg", "gif", "webp"],
    "Dokumenty": ["pdf", "doc", "docx", "txt", "xls", "xlsx"],
    "Instalatory": ["exe", "msi", "apk"],
    "Wideo": ["mp4", "mkv", "avi", "mov"],
    "Archiwa": ["zip", "rar", "7z"],
  };

  String getCategory(String ext) {
    for (var entry in categories.entries) {
      if (entry.value.contains(ext)) return entry.key;
    }
    return "Inne";
  }

  Future<void> organizeFiles() async {
    if (selectedFolder == null) return;

    Directory dir = Directory(selectedFolder!);
    List<FileSystemEntity> files = dir.listSync();

    setState(() {
      isLoading = true;
      progress = 0;
      status = "Przetwarzanie...";
      history.clear();
    });

    int totalFiles = files.whereType<File>().length;
    int processed = 0;
    int moved = 0;

    for (var file in files) {
      if (file is File) {
        String fileName = file.uri.pathSegments.last;

        if (file.path.contains("/Obrazy") ||
            file.path.contains("/Dokumenty") ||
            file.path.contains("/Instalatory") ||
            file.path.contains("/Inne") ||
            file.path.contains("/Wideo") ||
            file.path.contains("/Archiwa")) continue;

        String ext = fileName.contains('.')
            ? fileName.split('.').last.toLowerCase()
            : "";

        String category = getCategory(ext);
        Directory targetDir =
            Directory("${selectedFolder!}/$category");

        if (!targetDir.existsSync()) {
          targetDir.createSync();
        }

        try {
          String newPath = getUniquePath(targetDir.path, fileName);
          await file.rename(newPath);

          history.add({
            "from": newPath,
            "to": file.path,
          });

          moved++;
        } catch (e) {
          try {
            String newPath = getUniquePath(targetDir.path, fileName);
            await file.copy(newPath);
            await file.delete();

            history.add({
              "from": newPath,
              "to": file.path,
            });

            moved++;
          } catch (_) {}
        }

        processed++;
        setState(() {
          progress = processed / totalFiles;
        });
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

  Future<void> undoChanges() async {
  if (history.isEmpty) return;

  setState(() {
    isLoading = true;
    status = "Cofanie zmian...";
  });

  for (var item in history.reversed) {
    try {
      await File(item["from"]!).rename(item["to"]!);
    } catch (_) {}
  }

  removeEmptyCategoryFolders();

  setState(() {
    isLoading = false;
    status = "Cofnięto zmiany";
    history.clear();
  });
}

void removeEmptyCategoryFolders() {
  if (selectedFolder == null) return;

  for (var category in categories.keys) {
    Directory dir = Directory("${selectedFolder!}/$category");

    if (dir.existsSync()) {
      final items = dir.listSync();

      if (items.isEmpty) {
        dir.deleteSync();
      }
    }
  }

  Directory otherDir = Directory("${selectedFolder!}/Inne");

  if (otherDir.existsSync() && otherDir.listSync().isEmpty) {
    otherDir.deleteSync();
  }
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
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isLoading ? null : pickFolder,
              icon: Icon(Icons.folder_open),
              label: Text("Wybierz folder"),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: isLoading ? null : organizeFiles,
              icon: Icon(Icons.cleaning_services),
              label: Text("Segreguj pliki"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: isLoading ? null : undoChanges,
              icon: Icon(Icons.undo),
              label: Text("Cofnij"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
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
        if (isLoading)
          Column(
            children: [
              CircularProgressIndicator(value: progress),
              SizedBox(height: 10),
              Text("${(progress * 100).toStringAsFixed(0)}%"),
            ],
          ),
        SizedBox(height: 10),
        Text(
          "Status: $status",
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget buildInfo() {
    return Column(
      children: categories.keys.map((cat) {
        return ListTile(
          leading: Icon(Icons.folder),
          title: Text(cat),
          subtitle: Text(categories[cat]!.join(", ")),
        );
      }).toList()
        ..add(
          ListTile(
            leading: Icon(Icons.folder),
            title: Text("Inne"),
            subtitle: Text("pozostałe pliki"),
          ),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Download Cleaner"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
