
import 'package:flutter/material.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final List<Map<String, dynamic>> notes = [
    {'title': 'Meeting Notes', 'tags': ['Work', 'Team']},
    {'title': 'Grocery List', 'tags': ['Personal', 'Shopping']},
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredNotes = notes.where((note) {
      final titleMatch = note['title']
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
      return titleMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: NotesSearchDelegate(notes),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredNotes.length,
        itemBuilder: (context, index) {
          final note = filteredNotes[index];
          return Card(
            child: ListTile(
              title: Text(note['title']),
              subtitle: Wrap(
                children: note['tags']
                    .map<Widget>((tag) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Chip(label: Text(tag)),
                ))
                    .toList(),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/editNote');
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/editNote'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NotesSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> notes;
  NotesSearchDelegate(this.notes);

  @override
  Widget buildResults(BuildContext context) {
    final results = notes
        .where((note) => note['title']
        .toLowerCase()
        .contains(query.toLowerCase()))
        .toList();

    return ListView(
      children: results
          .map((note) => ListTile(title: Text(note['title'])))
          .toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => buildResults(context);
}