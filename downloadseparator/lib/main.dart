import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inteligentny Segregator Plików',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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

  // Funkcja do wyboru folderu - tu tylko symulacja
  void pickFolder() {
    // Tu będzie logika wybierania folderu, na razie symulujemy wybór
    setState(() {
      selectedFolder = "C:/Users/TwojFolder";  // Symulacja ścieżki folderu
    });
  }

  // Funkcja do segregacji plików - tylko mockup
  void organizeFiles() {
    if (selectedFolder != null) {
      // Tutaj można dodać prawdziwą logikę segregacji
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Segregowanie plików..."),
            content: Text("Pliki zostały pomyślnie posortowane!"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inteligentny Segregator Plików'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            // Nagłówek
            Text(
              'Wybierz folder do segregacji plików',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            // Wyświetlenie wybranego folderu
            Text(
              selectedFolder ?? 'Nie wybrano folderu',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 30),
            // Przyciski do wyboru folderu i segregacji
            ElevatedButton(
              onPressed: pickFolder,
              child: Text('Wybierz folder'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: organizeFiles,
              child: Text('Segreguj pliki'),
            ),
          ],
        ),
      ),
    );
  }
}