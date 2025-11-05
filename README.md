# Grade Entry Flutter App

A mobile application built using Flutter that allows users to **add, view, edit, and delete student grade records**. This project was developed as part of **CSCI 4100U – Mobile Devices** Lab 06/07. The lab focuses on building multi-screen interfaces, managing state, and implementing **SQLite persistence** in Flutter. :contentReference[oaicite:1]{index=1}

---

## ✨ Features

| Feature | Description |
|--------|-------------|
| **ListGrades Page** | Displays all stored grades using a `ListView` of `ListTile` widgets. |
| **GradeForm Page** | Allows adding or editing a student ID and letter grade. |
| **Selectable List Items** | Tapping a list item highlights the selected row. |
| **Add Grade** | Floating action button opens the GradeForm to create new entries. |
| **Edit Grade** | Edit icon opens the GradeForm pre-filled for modification. |
| **Delete Grade** | Delete icon removes the selected grade from the list. |
| **Local Database Storage** | Uses **sqflite** to persist grades on-device. |

---

## 🗂 App Structure
```bash
grade-entry-flutter-app/
│
├── lib/
│ ├── main.dart # Application entry point
│ ├── models/
│ │ └── grade.dart # Grade class + toMap/fromMap
│ ├── db/
│ │ └── grades_model.dart # Database helper for CRUD operations
│ ├── pages/
│ │ ├── list_grades.dart # ListGrades UI
│ │ └── grade_form.dart # GradeForm UI
│
└── screenshots/ # UI screenshots for documentation
```

---

## 🧰 Technologies Used

- **Flutter**
- **Dart**
- **SQLite** (via `sqflite` package)
- `ListView`, `ListTile`, `GestureDetector`, `Navigator`, `FloatingActionButton`

---

## 📸 Screenshots

> Add screenshots inside the `screenshots/` folder and reference them here:


---

## 🚀 Running the App

### 1. Install Dependencies
```bash
flutter pub get
```
### 2. Run on Emulator or Device
```bash
flutter run
```

## 🔧 Future Improvements (Optional Bonus Ideas)

These are extension features listed in the lab that can be added later for enhancement:
- Swipe to delete instead of using delete icon.
- Long-press to edit with a contextual menu.
- Sorting controls in the AppBar (e.g., sort by grade or student ID).
- Data visualization using a DataTable or bar chart.
- Import grades from a .csv file.

## 📄 Lab Source Reference

This implementation follows the requirements of CSCI 4100U Lab 06/07 — Grade Entry System. 

## 👤 Author

Klein C.
Ontario Tech University
2025 Fall
