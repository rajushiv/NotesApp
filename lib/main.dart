// lib/main.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const PeopleNotesApp());
}

class PeopleNotesApp extends StatelessWidget {
  const PeopleNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'People Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const PeopleListScreen(),
    );
  }
}

/// Model for one person note
class PersonNote {
  String id;
  String name;
  String gender; // "Male" or "Female"
  DateTime dob;
  int age;
  double heightCm;
  double weightKg;
  String note;

  PersonNote({
    required this.id,
    required this.name,
    required this.gender,
    required this.dob,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.note,
  });

  factory PersonNote.fromJson(Map<String, dynamic> j) => PersonNote(
    id: j['id'] as String,
    name: j['name'] as String,
    gender: j['gender'] as String,
    dob: DateTime.parse(j['dob'] as String),
    age: j['age'] as int,
    heightCm: (j['heightCm'] as num).toDouble(),
    weightKg: (j['weightKg'] as num).toDouble(),
    note: j['note'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'gender': gender,
    'dob': dob.toIso8601String(),
    'age': age,
    'heightCm': heightCm,
    'weightKg': weightKg,
    'note': note,
  };
}

class PeopleListScreen extends StatefulWidget {
  const PeopleListScreen({super.key});

  @override
  State<PeopleListScreen> createState() => _PeopleListScreenState();
}

class _PeopleListScreenState extends State<PeopleListScreen> {
  static const storageKey = 'people_notes_v1';
  List<PersonNote> _people = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw != null) {
      final List decoded = jsonDecode(raw) as List;
      _people = decoded.map((e) => PersonNote.fromJson(e)).toList();
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_people.map((p) => p.toJson()).toList());
    await prefs.setString(storageKey, jsonStr);
  }

  void _addOrEdit({PersonNote? editing}) async {
    final result = await Navigator.of(context).push<PersonNote?>(
      MaterialPageRoute(
        builder: (_) => PersonEditorScreen(initial: editing),
      ),
    );

    if (result == null) return; // user cancelled

    setState(() {
      if (editing == null) {
        // insert new at top
        _people.insert(0, result);
      } else {
        final i = _people.indexWhere((p) => p.id == editing.id);
        if (i >= 0) _people[i] = result;
      }
    });
    await _save();
  }

  Future<void> _delete(PersonNote p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete record?'),
        content: Text('Delete "${p.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      setState(() => _people.removeWhere((e) => e.id == p.id));
      await _save();
    }
  }

  String _formatDob(DateTime d) => '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('People Notes'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _people.isEmpty
          ? const Center(child: Text('No records yet. Tap + to add.'))
          : ListView.builder(
        itemCount: _people.length,
        itemBuilder: (context, i) {
          final p = _people[i];
          return Dismissible(
            key: Key(p.id),
            direction: DismissDirection.endToStart,
            background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.delete, color: Colors.white)),
            onDismissed: (_) => _delete(p),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: ListTile(
                onTap: () => _addOrEdit(editing: p),
                title: Text(p.name.isEmpty ? '(No name)' : p.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gender: ${p.gender} • DOB: ${_formatDob(p.dob)} • Age: ${p.age}'),
                    Text('Height: ${p.heightCm.toStringAsFixed(1)} cm • Weight: ${p.weightKg.toStringAsFixed(1)} kg'),
                    if (p.note.isNotEmpty) Text('Note: ${p.note}', maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _addOrEdit(editing: p),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEdit(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PersonEditorScreen extends StatefulWidget {
  final PersonNote? initial;
  const PersonEditorScreen({super.key, this.initial});

  @override
  State<PersonEditorScreen> createState() => _PersonEditorScreenState();
}

class _PersonEditorScreenState extends State<PersonEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameC;
  String _gender = 'Male';
  DateTime? _dob;
  late TextEditingController _heightC;
  late TextEditingController _weightC;
  late TextEditingController _noteC;

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    _nameC = TextEditingController(text: init?.name ?? '');
    _gender = init?.gender ?? 'Male';
    _dob = init?.dob;
    _heightC = TextEditingController(text: init != null ? init.heightCm.toString() : '');
    _weightC = TextEditingController(text: init != null ? init.weightKg.toString() : '');
    _noteC = TextEditingController(text: init?.note ?? '');
  }

  @override
  void dispose() {
    _nameC.dispose();
    _heightC.dispose();
    _weightC.dispose();
    _noteC.dispose();
    super.dispose();
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _pickDob() async {
    final initial = _dob ?? DateTime.now().subtract(const Duration(days: 365 * 20));
    final firstDate = DateTime(1900);
    final lastDate = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) setState(() => _dob = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (_dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Date of Birth')));
      return;
    }

    final name = _nameC.text.trim();
    final height = double.tryParse(_heightC.text.trim()) ?? 0.0;
    final weight = double.tryParse(_weightC.text.trim()) ?? 0.0;
    final age = _calculateAge(_dob!);
    final note = _noteC.text.trim();

    final id = widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final person = PersonNote(
      id: id,
      name: name,
      gender: _gender,
      dob: _dob!,
      age: age,
      heightCm: height,
      weightKg: weight,
      note: note,
    );

    Navigator.of(context).pop(person);
  }

  String _dobText() => _dob == null ? 'Select DOB' : '${_dob!.day.toString().padLeft(2, '0')}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.year}';

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Person' : 'Add Person'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameC,
                decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Male'),
                      leading: Radio<String>(
                        value: 'Male',
                        groupValue: _gender,
                        onChanged: (v) => setState(() => _gender = v!),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Female'),
                      leading: Radio<String>(
                        value: 'Female',
                        groupValue: _gender,
                        onChanged: (v) => setState(() => _gender = v!),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDob,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Date of Birth', border: const OutlineInputBorder(), hintText: _dobText()),
                    controller: TextEditingController(text: _dob == null ? '' : _dobText()),
                    validator: (_) => _dob == null ? 'Pick DOB' : null,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _heightC,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Height (cm)', border: OutlineInputBorder()),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter height';
                        final n = double.tryParse(v);
                        if (n == null || n <= 0) return 'Invalid height';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _weightC,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Weight (kg)', border: OutlineInputBorder()),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter weight';
                        final n = double.tryParse(v);
                        if (n == null || n <= 0) return 'Invalid weight';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteC,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Note (optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),
              const SizedBox(height: 8),
              if (widget.initial != null)
                TextButton(
                  onPressed: () {
                    // quick recalc age preview
                    if (_dob != null) {
                      final age = _calculateAge(_dob!);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Current calculated age: $age years')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('DOB not selected')));
                    }
                  },
                  child: const Text('Show calculated age'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
