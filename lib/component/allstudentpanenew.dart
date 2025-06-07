// import 'package:flutter/material.dart';
// import 'package:schmgtsystem/all_students.dart';
// import 'package:schmgtsystem/component/studentdatatable.dart';

// class AllStudentsPage extends StatefulWidget {
//   const AllStudentsPage({super.key});

//   @override
//   State<AllStudentsPage> createState() => _AllStudentsPageState();
// }

// class _AllStudentsPageState extends State<AllStudentsPage> {
//   int? _sortColumnIndex;
//   bool _isAscending = true;
//   List<bool> _selectedRows = [];

//   final List<MyDataRowModel> _data = [
//     MyDataRowModel(
//       className: "Primary 1",
//       section: "A",
//       student: "John Doe",
//       number: 1,
//       profilePictureUrl:
//           'https://ik.imagekit.io/dp750urb0/userImg.jpeg?updatedAt=1742563967488',
//     ),
//     MyDataRowModel(
//       className: "Primary 2",
//       section: "B",
//       student: "Jane Smith",
//       number: 2,
//       profilePictureUrl:
//           'https://ik.imagekit.io/dp750urb0/featured1.jpeg?updatedAt=1742563965798',
//     ),
//     // ... more data
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _selectedRows = List.generate(_data.length, (index) => false);
//   }

//   void _sort<T>(
//     Comparable<T> Function(MyDataRowModel d) getField,
//     int columnIndex,
//     bool ascending,
//   ) {
//     setState(() {
//       _sortColumnIndex = columnIndex;
//       _isAscending = ascending;
//       _data.sort((a, b) {
//         final aValue = getField(a);
//         final bValue = getField(b);
//         return ascending
//             ? Comparable.compare(aValue, bValue)
//             : Comparable.compare(bValue, aValue);
//       });
//     });
//   }

//   Future<MyDataRowModel?> _onEdit(MyDataRowModel row) async {
//     return await showDialog<MyDataRowModel>(
//       context: context,
//       builder: (_) => EditStudentDialog(initial: row),
//     );
//   }

//   Future<bool> _onDelete(int index) async {
//     setState(() {
//       _data.removeAt(index);
//       _selectedRows.removeAt(index);
//     });
//     return true;
//   }

//  Future<void> _onView(MyDataRowModel row) async {
//     await showDialog(
//       context: context,
//       builder: (context) => StudentDetailsDialog(student: row),
//     );
//   }
//   void _onRowSelect(int index, bool selected) {
//     setState(() {
//       _selectedRows[index] = selected;
//     });
//   }

//   void _onSelectAll(bool selectAll) {
//     setState(() {
//       for (int i = 0; i < _selectedRows.length; i++) {
//         _selectedRows[i] = selectAll;
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StudentDataTable(
//       data: _data,
//       sortColumnIndex: _sortColumnIndex,
//       sortAscending: _isAscending,
//       onSort: (columnIndex, ascending) {
//         switch (columnIndex) {
//           case 0: // No column
//             _sort((d) => d.number, columnIndex, ascending);
//             break;
//           case 2: // Class column
//             _sort((d) => d.className, columnIndex, ascending);
//             break;
//           case 3: // Section column
//             _sort((d) => d.section, columnIndex, ascending);
//             break;
//           case 4: // Student column
//             _sort((d) => d.student, columnIndex, ascending);
//             break;
//           case 5: // Number column
//             _sort((d) => d.number, columnIndex, ascending);
//             break;
//         }
//       },
//       selectedRows: _selectedRows,
//       onEdit: _onEdit,
//       onDelete: _onDelete,
//       onView: _onView,
//       onRowSelect: _onRowSelect,
//       onSelectAll: _onSelectAll,
//       isSelectable: true,
//     );
//   }
// }
