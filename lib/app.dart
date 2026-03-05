import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/notes_provider.dart';
import 'screens/home_screen.dart';
import 'screens/floating_note_screen.dart';

class StickyNotesApp extends StatelessWidget {
  const StickyNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => NotesProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Sticky Notes App',
        theme: ThemeData(
          primarySwatch: Colors.yellow,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class FloatingNoteApp extends StatelessWidget {
  final Map<String, dynamic> noteData;

  const FloatingNoteApp(this.noteData, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => NotesProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Floating Note',
        theme: ThemeData(
          primarySwatch: Colors.yellow,
          useMaterial3: true,
        ),
        home: FloatingNoteScreen.fromMap(noteData),
      ),
    );
  }
}