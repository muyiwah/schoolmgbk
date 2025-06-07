// import 'dart:typed_data';
// import 'dart:html' as html;

// import 'package:data_table_2/data_table_2.dart';
// import 'package:flutter/material.dart';
// import 'package:schmgtsystem/all_students.dart';
// import 'package:schmgtsystem/component/tablecompent.dart';

// class StudentDataTable extends StatelessWidget {
//   final List<MyDataRowModel> data;
  
//   final String? searchHint;
//   final bool showSearch;
//   final bool showPrint;
//   final bool showExcelExport;
//   final bool showSelectAll;
//   final bool showDeleteAll;
//   final bool showRowActions;
//   final bool isSelectable;
//   final List<bool>? selectedRows;
//   final Future<MyDataRowModel?> Function(MyDataRowModel row)? onEdit;
//   final Future<bool> Function(int index)? onDelete;
//   final Future<void> Function(MyDataRowModel row)? onView;
//   final void Function(int index, bool selected)? onRowSelect;
//   final void Function(bool selectAll)? onSelectAll;
//   final int? sortColumnIndex;
//   final bool? sortAscending;
//   final void Function(int columnIndex, bool ascending)? onSort;

//   const StudentDataTable({
//     Key? key,
//     required this.data,
//     this.searchHint,
//     this.showSearch = true,
//     this.showPrint = true,
//     this.showExcelExport = true,
//     this.showSelectAll = true,
//     this.showDeleteAll = true,
//     this.showRowActions = true,
//     this.isSelectable = false,
//     this.selectedRows,
//     this.onEdit,
//     this.onDelete,
//     this.onView,
//     this.onRowSelect,
//     this.onSelectAll,
//     this.sortColumnIndex,
//     this.sortAscending,
//     this.onSort,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return CustomDataTable<MyDataRowModel>(
//       config: CustomDataTableConfig(
//         columns: [
//           DataColumn2(
//             label: const Text('No'),
//             size: ColumnSize.S,
//             onSort: onSort,
//           ),
//           const DataColumn2(label: Text('Picture'), size: ColumnSize.S),
//           DataColumn2(label: const Text('Class'), onSort: onSort),
//           DataColumn2(label: const Text('Section'), onSort: onSort),
//           DataColumn2(label: const Text('Student'), onSort: onSort),
//           DataColumn2(
//             label: const Text('Number'),
//             numeric: true,
//             onSort: onSort,
//           ),
//         ],
//         data: data,
//         searchHint: searchHint,
//         showSearch: showSearch,
//         showPrint: showPrint,
//         showExcelExport: showExcelExport,
//         showSelectAll: showSelectAll,
//         showDeleteAll: showDeleteAll,
//         showRowActions: showRowActions,
//         isSelectable: isSelectable,
//         selectedRows: selectedRows,
//         onEdit: onEdit,
//         onDelete: onDelete,
//         // onView: onView ,
//         onRowSelect: onRowSelect,
//         onSelectAll: onSelectAll,
//         customCellBuilders: {
//           'Picture': (student) => _buildStudentAvatar(student),
//           'No': (student) => Text(student.number.toString()),
//           'Class': (student) => Text(student.className),
//           'Section': (student) => Text(student.section),
//           'Student': (student) => Text(student.student),
//           'Number': (student) => Text(student.number.toString()),
//         },
//         sortColumnIndex: sortColumnIndex,
//         sortAscending: sortAscending,
//         onSort: onSort,
//       ),
//     );
//   }

//   Widget _buildStudentAvatar(MyDataRowModel student) {
//     return GestureDetector(
//       onTap: () => _pickImage(student),
//       child: CircleAvatar(
//         radius: 20,
//         backgroundImage:
//             student.imageBytes != null
//                 ? MemoryImage(student.imageBytes!)
//                 : (student.profilePictureUrl.isNotEmpty
//                     ? NetworkImage(student.profilePictureUrl)
//                     : null),
//         child:
//             student.imageBytes == null && student.profilePictureUrl.isEmpty
//                 ? const Icon(Icons.person, size: 20)
//                 : null,
//       ),
//     );
//   }

//   Future<void> _pickImage(MyDataRowModel student) async {
//     final uploadInput = html.FileUploadInputElement();
//     uploadInput.accept = 'image/*';
//     uploadInput.click();

//     uploadInput.onChange.listen((event) async {
//       final file = uploadInput.files?.first;
//       if (file != null) {
//         final reader = html.FileReader();
//         reader.readAsArrayBuffer(file);
//         reader.onLoadEnd.listen((event) {
//           final bytes = reader.result as Uint8List?;
//           if (bytes != null && onEdit != null) {
//             onEdit!(student.copyWith(imageBytes: bytes));
//           }
//         });
//       }
//     });
//   }
// }
