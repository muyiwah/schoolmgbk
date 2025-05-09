// import 'package:flutter/material.dart';
// import 'package:equatable/equatable.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:pdf/pdf.dart';
// import 'package:printing/printing.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:file_picker/file_picker.dart';
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'dart:html' as html;

// class StudentRow extends Equatable {
//   final String classId;
//   final String className;
//   final String teacher;
//   final String section;
//   final String studentName;
//   final String id;
//   final String imageUrl;

//   const StudentRow({
//     required this.classId,
//     required this.className,
//     required this.teacher,
//     required this.section,
//     required this.studentName,
//     required this.id,
//     required this.imageUrl,
//   });

//   @override
//   List<Object?> get props => [
//     classId,
//     className,
//     teacher,
//     section,
//     studentName,
//     id,
//     imageUrl,
//   ];

//   StudentRow copyWith({
//     String? classId,
//     String? className,
//     String? section,
//     String? studentName,
//     String? imageUrl,
//     String? teacher,
//     String? id,
//   }) {
//     return StudentRow(
//       className: className ?? this.className,
//       section: section ?? this.section,
//       studentName: studentName ?? this.studentName,
//       classId: classId ?? this.classId,
//       teacher: teacher ?? this.teacher,
//       id: id ?? this.id,
//       imageUrl: imageUrl ?? this.imageUrl,
//     );
//   }
// }

// String tableTitle = 'Teachers';

// // 2) DataTableSource for PaginatedDataTable
// class StudentDataSource extends DataTableSource {
//   final BuildContext context;
//   final List<StudentRow> _originalRows;
//   List<StudentRow> _displayRows;
//   final Set<StudentRow> _selected = {};

//   StudentDataSource(List<StudentRow> rows, this.context)
//     : _originalRows = rows,
//       _displayRows = List.from(rows);

//   // Filtering
//   void filter(String query) {
//     _displayRows =
//         query.isEmpty
//             ? List.from(_originalRows)
//             : _originalRows
//                 .where(
//                   (r) =>
//                       r.studentName.toLowerCase().contains(query.toLowerCase()),
//                 )
//                 .toList();
//     notifyListeners();
//   }

//   // Sorting
//   void sort<T>(Comparable<T> Function(StudentRow d) getField, bool asc) {
//     _displayRows.sort((a, b) {
//       final aValue = getField(a);
//       final bValue = getField(b);
//       return asc
//           ? Comparable.compare(aValue as Comparable, bValue as Comparable)
//           : Comparable.compare(bValue as Comparable, aValue as Comparable);
//     });
//     notifyListeners();
//   }

//   @override
//   DataRow getRow(int index) {
//     final row = _displayRows[index];
//     return DataRow.byIndex(
//       index: index,
//       selected: _selected.contains(row),
//       onSelectChanged: (sel) {
//         if (sel == null) return;
//         if (sel) {
//           _selected.add(row);
//         } else {
//           _selected.remove(row);
//         }
//         notifyListeners();
//       },
//       cells: [
//         DataCell(
//           CircleAvatar(
//             radius: 20,
//             backgroundImage: NetworkImage(row.imageUrl),
//             onBackgroundImageError: (_, __) => const Icon(Icons.person),
//           ),
//         ),
//         DataCell(Text(row.classId)),
//         DataCell(Text(row.className)),
//         DataCell(Text(row.teacher)),
//         DataCell(Text(row.section)),
//         DataCell(Text(row.studentName)),
//         DataCell(Text(row.id)),
//         DataCell(
//           Row(
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.edit),
//                 tooltip: 'Edit ${row.studentName}',
//                 onPressed: () async {
//                   final updated = await showDialog<StudentRow>(
//                     context:
//                         context, // ensure you passed context into the data source
//                     builder: (_) => EditStudentDialog(initial: row),
//                   );
//                   if (updated != null) {
//                     // 1) Replace the old row with the updated one
//                     _displayRows[index] = updated;
//                     // 2) Notify listeners so the table refreshes
//                     notifyListeners();
//                   }
//                 },
//               ),
//               IconButton(
//                 icon: const Icon(Icons.delete),
//                 tooltip: 'Delete',
//                 onPressed: () {
//                   // handle delete
//                 },
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   bool get isRowCountApproximate => false;
//   @override
//   int get rowCount => _displayRows.length;
//   @override
//   int get selectedRowCount => _selected.length;
// }

// class StudentTablePage extends StatefulWidget {
//   const StudentTablePage({super.key});
//   @override
//   State<StudentTablePage> createState() => _StudentTablePageState();
// }

// class _StudentTablePageState extends State<StudentTablePage> {
//   late StudentDataSource _dataSource;
//   int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
//   int? _sortColumnIndex;
//   bool _sortAscending = true;
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     final rows = const [
//       StudentRow(
//         classId: '0001222222',
//         className: 'Grade 1',
//         teacher: 'MR toluwanimi Adeoti',
//         section: 'A',
//         studentName: 'Alice',
//         id: '1',
//         imageUrl:
//             'https://ik.imagekit.io/dp750urb0/userImg.jpeg?updatedAt=1742563967488',
//       ),
//       StudentRow(
//         classId: '0001222222',
//         className: 'Grade 1',
//         teacher: 'MR toluwanimi Adeoti',
//         section: 'A',
//         studentName: 'Alice',
//         id: '1',
//         imageUrl:
//             'https://ik.imagekit.io/dp750urb0/featured4.jpeg?updatedAt=1742563965787',
//       ),

//       // add more dummy rows as needed
//     ];
//     _dataSource = StudentDataSource(rows, context);
//   }

//   Future<pw.Document> _buildPdf() async {
//     final pdf = pw.Document();
//     final headers = ['Class', 'Section', 'Student'];

//     // Combine header + data rows into widgets
//     final allRows = <pw.Widget>[
//       // Header row
//       pw.Container(
//         color: PdfColors.grey300,
//         padding: const pw.EdgeInsets.all(6),
//         child: pw.Row(
//           children:
//               headers
//                   .map(
//                     (h) => pw.Expanded(
//                       child: pw.Text(
//                         h,
//                         style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                       ),
//                     ),
//                   )
//                   .toList(),
//         ),
//       ),
//       // Data rows
//       ..._dataSource._displayRows.map((r) {
//         return pw.Container(
//           padding: const pw.EdgeInsets.all(6),
//           child: pw.Row(
//             children: [
//               pw.Expanded(child: pw.Text(r.classId)),
//               pw.Expanded(child: pw.Text(r.className)),
//               pw.Expanded(child: pw.Text(r.teacher)),
//               pw.Expanded(child: pw.Text(r.section)),
//               pw.Expanded(child: pw.Text(r.studentName)),
//             ],
//           ),
//         );
//       }),
//     ];

//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         build:
//             (context) => [
//               pw.Text(tableTitle, style: pw.TextStyle(fontSize: 20)),
//               pw.SizedBox(height: 12),
//               pw.ListView(children: allRows),
//             ],
//       ),
//     );

//     return pdf;
//   }

//   Future<void> _printTable() async {
//     final pdfDoc = await _buildPdf();
//     final bytes = await pdfDoc.save();
//     await Printing.layoutPdf(onLayout: (_) => bytes);

//     // final pdfDoc = pw.Document();

//     final headers = ['Class', 'Section', 'Student', 'Id'];

//     final data =
//         _dataSource._displayRows.map((row) {
//           return [
//             row.classId,
//             row.className,
//             row.teacher,
//             row.section,
//             row.studentName,
//           ];
//         }).toList();

//     pdfDoc.addPage(
//       pw.Page(
//         build: (pw.Context context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Text(tableTitle, style: pw.TextStyle(fontSize: 20)),
//               pw.SizedBox(height: 20),
//               pw.Table.fromTextArray(
//                 headers: headers,
//                 data: data,
//                 border: pw.TableBorder.all(),
//                 headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                 cellAlignment: pw.Alignment.centerLeft,
//                 headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
//                 cellPadding: const pw.EdgeInsets.all(6),
//               ),
//             ],
//           );
//         },
//       ),
//     );

//     await Printing.layoutPdf(
//       onLayout: (PdfPageFormat format) async => pdfDoc.save(),
//     );
//   }

//   void _sort<T>(
//     Comparable<T> Function(StudentRow d) getField,
//     int colIndex,
//     bool asc,
//   ) {
//     _dataSource.sort(getField, asc);
//     setState(() {
//       _sortColumnIndex = colIndex;
//       _sortAscending = asc;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.red,
//       appBar: AppBar(
//         title: Text(tableTitle),
//         backgroundColor: Colors.white,
//         centerTitle: false,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // 3) Search/filter field
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 SizedBox(
//                   width: 250,
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: const InputDecoration(
//                       border: OutlineInputBorder(),
//                       labelText: 'Search by student name',
//                       prefixIcon: Icon(Icons.search),
//                     ),
//                     onChanged: (q) => _dataSource.filter(q),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: ElevatedButton.icon(
//                     onPressed: _printTable,
//                     icon: const Icon(Icons.print),
//                     label: const Text('Print Table'),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             // 4) PaginatedDataTable with sorting & pagination
//             Expanded(
//               child: SingleChildScrollView(
//                 child: PaginatedDataTable(
//                   // header: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   //   children: [
//                   //     const Text('Class List'),
//                   //  Align(
//                   //       alignment: Alignment.centerRight,
//                   //       child: ElevatedButton.icon(
//                   //         onPressed: _printTable,
//                   //         icon: const Icon(Icons.print),
//                   //         label: const Text('Print Table'),
//                   //       ),
//                   //     ),  ],
//                   // ),
//                   columns: [
//                     DataColumn(label: Text('Image')),
//                     DataColumn(
//                       label: const Text('ClassId'),
//                       onSort: (ci, asc) => _sort((d) => d.classId, ci, asc),
//                     ),
//                     DataColumn(
//                       label: const Text('Class'),
//                       onSort: (ci, asc) => _sort((d) => d.className, ci, asc),
//                     ),
//                     DataColumn(
//                       label: const Text('Teacher'),
//                       onSort: (ci, asc) => _sort((d) => d.teacher, ci, asc),
//                     ),
//                     DataColumn(
//                       label: const Text('Section'),
//                       onSort: (ci, asc) => _sort((d) => d.section, ci, asc),
//                     ),
//                     DataColumn(
//                       label: const Text('Student'),
//                       onSort: (ci, asc) => _sort((d) => d.studentName, ci, asc),
//                     ),
//                     DataColumn(
//                       label: const Text('Id'),
//                       onSort: (ci, asc) => _sort((d) => d.studentName, ci, asc),
//                     ),
//                     const DataColumn(label: Text('Action')),
//                   ],
//                   source: _dataSource,
//                   rowsPerPage: _rowsPerPage,
//                   availableRowsPerPage: const [5, 10, 20],
//                   onRowsPerPageChanged: (r) {
//                     if (r != null) setState(() => _rowsPerPage = r);
//                   },
//                   sortColumnIndex: _sortColumnIndex,
//                   sortAscending: _sortAscending,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class EditStudentDialog extends StatefulWidget {
//   final StudentRow initial;
//   const EditStudentDialog({super.key, required this.initial});

//   @override
//   State<EditStudentDialog> createState() => _EditStudentDialogState();
// }

// class _EditStudentDialogState extends State<EditStudentDialog> {
//   late TextEditingController _classCtrl;
//   late TextEditingController _sectionCtrl;
//   late TextEditingController _nameCtrl;
//   late TextEditingController _idCtrl;
//   late TextEditingController _teacherCtrl;

//   @override
//   void initState() {
//     super.initState();
//     _classCtrl = TextEditingController(text: widget.initial.className);
//     _sectionCtrl = TextEditingController(text: widget.initial.section);
//     _nameCtrl = TextEditingController(text: widget.initial.studentName);
//     _idCtrl = TextEditingController(text: widget.initial.id);
//     _teacherCtrl = TextEditingController(text: widget.initial.teacher);
//     if (widget.initial.imageUrl.isNotEmpty &&
//         widget.initial.imageUrl.startsWith('http')) {
//       // Could load preview from network too if needed
//     }
//   }

//   @override
//   void dispose() {
//     _classCtrl.dispose();
//     _sectionCtrl.dispose();
//     _nameCtrl.dispose();
//     super.dispose();
//   }

//   Uint8List? _imageBytes;
//   String? _imagePath;
// Future<void> _pickImage() async {
//     final uploadInput = html.FileUploadInputElement();
//     uploadInput.accept = 'image/*';
//     uploadInput.click();

//     uploadInput.onChange.listen((event) {
//       final file = uploadInput.files?.first;
//       if (file != null) {
//         final reader = html.FileReader();
//         reader.readAsArrayBuffer(file);
//         reader.onLoadEnd.listen((event) {
//           final bytes = reader.result as Uint8List?;
//           if (bytes != null) {
//             // Update state
//             setState(() {
//               _imageBytes = bytes;
//             });
//           }
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Edit Student'),
//       content: Container(
//         width: MediaQuery.of(context).size.width * .7,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             GestureDetector(
//               onTap: _pickImage,
//               child: CircleAvatar(
//                 radius: 40,
//                 backgroundImage:
//                     _imageBytes != null
//                         ? MemoryImage(_imageBytes!)
//                         : (widget.initial.imageUrl.isNotEmpty
//                             ? NetworkImage(widget.initial.imageUrl)
//                             : null),
//                 child:
//                     _imageBytes == null && widget.initial.imageUrl.isEmpty
//                         ? const Icon(Icons.person, size: 40)
//                         : null,
//               ),
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton.icon(
//               onPressed: _pickImage,
//               icon: const Icon(Icons.upload),
//               label: const Text("Upload Image"),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _classCtrl,
//               decoration: const InputDecoration(labelText: 'Class'),
//             ),
//             TextField(
//               controller: _sectionCtrl,
//               decoration: const InputDecoration(labelText: 'Section'),
//             ),
//             TextField(
//               controller: _nameCtrl,
//               decoration: const InputDecoration(labelText: 'Student Name'),
//             ),
//             TextField(
//               controller: _idCtrl,
//               decoration: const InputDecoration(labelText: 'Student id'),
//             ),
//             TextField(
//               controller: _teacherCtrl,
//               decoration: const InputDecoration(labelText: 'teacher Name'),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             final updated = widget.initial.copyWith(
//               className: _classCtrl.text,
//               section: _sectionCtrl.text,
//               studentName: _nameCtrl.text,
//               id: _idCtrl.text,
//               classId: _teacherCtrl.text,
//             );
//             Navigator.pop(context, updated);
//           },
//           child: const Text('Save'),
//         ),
//       ],
//     );
//   }
// }
