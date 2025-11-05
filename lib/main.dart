import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

void main() async {
  // Ensures all Flutter bindings are initialized before running asynchronous code
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize and open the database before building the app UI
  final db = await GradesModel().database; // force DB creation before UI

  // Run the app after the database is ready
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Forms and SQLite',
      home: ListGrades(),
    ),
  );
}

/// --------- Model ---------
/// Represents a single Grade record (model for each database row)
class Grade {
  int? id; // Primary key (auto-increment)
  String sid; // Student ID
  String grade; // Student grade

  Grade({this.id, required this.sid, required this.grade});

  // Convert this Grade object into a Map (for SQLite insertion)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{'sid': sid, 'grade': grade};
    if (id != null) map['id'] = id;
    return map;
  }

  // Factory constructor to create a Grade object from a Map (for reading from DB)
  factory Grade.fromMap(Map<String, dynamic> map) => Grade(
    id: map['id'] as int?,
    sid: map['sid'] as String,
    grade: map['grade'] as String,
  );
}

/// --------- SQLite data access ---------
/// Handles all SQLite database operations (CRUD)
class GradesModel {
  static Database? _db; // Singleton database instance

  // Getter that returns the database, initializing it if necessary
  Future<Database> get database async {
    // print('database getter called');
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  // Initializes (creates or opens) the database file
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath(); // Get system database directory
    final path = p.join(dbPath, 'grades.db'); // Join path with file name
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        // print('Creating grades.db...');
        // Create the "grades" table on first database creation
        await db.execute('''
        CREATE TABLE grades(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sid TEXT NOT NULL,
          grade TEXT NOT NULL
        )
      ''');
      },
    );
  }

  // Retrieve all grades from the database, sorted by descending ID
  Future<List<Grade>> getAllGrades() async {
    // print('getAllGrades() called');
    final db = await database;
    final rows = await db.query('grades', orderBy: 'id DESC');
    // print('getAllGrades returned ${rows.length} rows');
    return rows.map((m) => Grade.fromMap(m)).toList();
  }

  // Insert a new Grade record into the database
  Future<int> insertGrade(Grade grade) async {
    final db = await database;
    final id = await db.insert('grades', grade.toMap());
    // print('Inserted row id = $id');
    return id;
  }

  // Update an existing Grade record in the database
  Future<int> updateGrade(Grade grade) async {
    final db = await database;
    return db.update(
      'grades',
      grade.toMap(),
      where: 'id = ?',
      whereArgs: [grade.id],
    );
  }

  // Delete a Grade record by its ID
  Future<int> deleteGradeById(int id) async {
    final db = await database;
    return db.delete('grades', where: 'id = ?', whereArgs: [id]);
  }
}

/// --------- ListGrades screen ---------
/// Main screen that displays all grades and allows add/edit/delete
class ListGrades extends StatefulWidget {
  const ListGrades({super.key});

  @override
  State<ListGrades> createState() => _ListGradesState();
}

class _ListGradesState extends State<ListGrades> {
  final GradesModel _model = GradesModel(); // Database handler
  List<Grade> _grades = <Grade>[]; // List of grades loaded from DB
  int? _selectedIndex; // Index of currently selected grade in the list

  @override
  void initState() {
    super.initState();
    _refreshGrades(); // Load grades when the widget is first created
  }

  // Fetch grades from database and update the UI
  Future<void> _refreshGrades() async {
    final grades = await _model.getAllGrades();
    // print('Loaded ${grades.length} grades from DB');
    if (!mounted) return;
    setState(() {
      _grades = grades;
      _selectedIndex = null;
    });
  }

  // Navigate to form screen to add a new grade
  Future<void> _addGrade() async {
    final result = await Navigator.push<Grade>(
      context,
      MaterialPageRoute(builder: (_) => const GradeForm()),
    );

    if (result != null) {
      // print('Inserting grade: ${result.sid}, ${result.grade}');
      await _model.insertGrade(result); // Insert into database
      await _refreshGrades(); // Refresh UI after insert
    }
  }

  // Navigate to form screen to edit selected grade
  Future<void> _editGrade() async {
    if (_selectedIndex == null) return; // No grade selected
    final grade = _grades[_selectedIndex!];
    final result = await Navigator.push<Grade>(
      context,
      MaterialPageRoute(builder: (_) => GradeForm(grade: grade)),
    );
    if (result != null) {
      await _model.updateGrade(result); // Update grade in database
      await _refreshGrades(); // Refresh UI after update
    }
  }

  // Delete selected grade from database
  Future<void> _deleteGrade() async {
    if (_selectedIndex == null) return; // No grade selected
    final id = _grades[_selectedIndex!].id!;
    await _model.deleteGradeById(id); // Delete by ID
    await _refreshGrades(); // Refresh UI after delete
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forms and SQLite'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editGrade),
          IconButton(icon: const Icon(Icons.delete), onPressed: _deleteGrade),
        ],
      ),
      // Main list view showing all grades
      body: ListView.builder(
        itemCount: _grades.length,
        itemBuilder: (context, index) {
          final g = _grades[index];
          final selected = _selectedIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: Container(
              color: selected
                  ? Colors.blue.shade100
                  : null, // Highlight selected row
              child: ListTile(title: Text(g.sid), subtitle: Text(g.grade)),
            ),
          );
        },
      ),
      // Floating action button to add a new grade
      floatingActionButton: FloatingActionButton(
        onPressed: _addGrade,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// --------- GradeForm screen ---------
/// Screen used to add or edit a grade record
class GradeForm extends StatefulWidget {
  final Grade? grade; // Optional existing grade for editing
  const GradeForm({super.key, this.grade});

  @override
  State<GradeForm> createState() => _GradeFormState();
}

class _GradeFormState extends State<GradeForm> {
  final _formKey = GlobalKey<FormState>(); // For validating form input
  late final TextEditingController _sidCtl; // Controller for SID text field
  late final TextEditingController _gradeCtl; // Controller for Grade text field

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing grade data if editing
    _sidCtl = TextEditingController(text: widget.grade?.sid ?? '');
    _gradeCtl = TextEditingController(text: widget.grade?.grade ?? '');
  }

  // Validate and save form data, returning the result to previous screen
  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final g = Grade(
      id: widget.grade?.id,
      sid: _sidCtl.text.trim(),
      grade: _gradeCtl.text.trim(),
    );
    // Show a quick confirmation message before returning
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Grade saved, returning...')),
    );
    // Pass the Grade object back to the previous screen
    Navigator.pop(context, g);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.grade != null; // True if editing existing record
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Grade' : 'Add Grade')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Student ID input
              TextFormField(
                controller: _sidCtl,
                decoration: const InputDecoration(labelText: 'SID'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter SID';
                  if (v.trim().length != 9) return 'SID must be 9 digits';
                  if (!RegExp(r'^\d{9}$').hasMatch(v.trim()))
                    return 'SID must be numeric';
                  return null;
                },
              ),
              // Grade input
              TextFormField(
                controller: _gradeCtl,
                decoration: const InputDecoration(labelText: 'Grade'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter grade' : null,
              ),
            ],
          ),
        ),
      ),
      // Floating action button to save form data
      floatingActionButton: FloatingActionButton(
        onPressed: _save,
        child: const Icon(Icons.save),
      ),
    );
  }
}