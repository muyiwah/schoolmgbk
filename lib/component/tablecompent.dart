// import 'dart:html' as html;
// import 'dart:typed_data';

// import 'package:data_table_2/data_table_2.dart';
// import 'package:excel/excel.dart';
// import 'package:flutter/material.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';

// typedef OnRowEdit<T> = Future<T?> Function(T row);
// typedef OnRowDelete = Future<bool> Function(int index);
// typedef OnRowView<T> = Future<void> Function(T row);
// typedef OnRowSelect = void Function(int index, bool selected);
// typedef OnSelectAll = void Function(bool selectAll);
// typedef CustomCellBuilder<T> = Widget Function(T rowData);

// class CustomDataTableConfig<T> {
//   final List<DataColumn2> columns;
//   final List<T> data;
//   final String? searchHint;
//   final bool showSearch;
//   final bool showPrint;
//   final bool showExcelExport;
//   final bool showSelectAll;
//   final bool showDeleteAll;
//   final bool showRowActions;
//   final bool isSelectable;
//   final List<bool>? selectedRows;
//   final OnRowEdit<T>? onEdit;
//   final OnRowDelete? onDelete;
//   final OnRowView? onView;
//   final OnRowSelect? onRowSelect;
//   final OnSelectAll? onSelectAll;
//   final Map<String, CustomCellBuilder<T>>? customCellBuilders;
//   final int? sortColumnIndex;
//   final bool? sortAscending;
//   final void Function(int columnIndex, bool ascending)? onSort;

//   CustomDataTableConfig({
//     required this.columns,
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
//     this.customCellBuilders,
//     this.sortColumnIndex,
//     this.sortAscending,
//     this.onSort,
//   });
// }

// class CustomDataTable<T> extends StatefulWidget {
//   final CustomDataTableConfig<T> config;

//   const CustomDataTable({Key? key, required this.config}) : super(key: key);

//   @override
//   State<CustomDataTable> createState() => _CustomDataTableState<T>();
// }

// class _CustomDataTableState<T> extends State<CustomDataTable<T>> {
//   String _searchQuery = '';
//   List<bool> _selectedRows = [];

//   @override
//   void initState() {
//     super.initState();
//     _selectedRows = List.generate(widget.config.data.length, (index) => false);
//   }

//   List<T> get filteredData {
//     // Default search implementation - can be overridden by providing custom search logic
//     return widget.config.data.where((row) {
//       return row.toString().toLowerCase().contains(_searchQuery.toLowerCase());
//     }).toList();
//   }

//   Future<void> _downloadExcel(List<T> data) async {
//     final excel = Excel.createExcel();
//     final Sheet sheetObject = excel['Data'];

//     // Add header
//     sheetObject.appendRow(
//       widget.config.columns.map((col) => col.label.toString()).toList(),
//     );

//     // Add data rows - simple implementation, should be customized per use case
//     for (var row in data) {
//       sheetObject.appendRow([row.toString()]);
//     }

//     final excelBytes = excel.encode();
//     if (excelBytes == null) return;

//     // For Web
//     final blob = html.Blob([excelBytes]);
//     final url = html.Url.createObjectUrlFromBlob(blob);
//     final anchor =
//         html.AnchorElement(href: url)
//           ..setAttribute("download", "data_table.xlsx")
//           ..click();
//     html.Url.revokeObjectUrl(url);
//   }

//   Future<void> _printTable(List<T> data) async {
//     final pdf = pw.Document();

//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         build:
//             (pw.Context context) => [
//               pw.Table.fromTextArray(
//                 headers:
//                     widget.config.columns
//                         .map((col) => col.label.toString())
//                         .toList(),
//                 data: data.map((row) => [row.toString()]).toList(),
//                 headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//                 border: pw.TableBorder.all(),
//                 cellAlignment: pw.Alignment.centerLeft,
//               ),
//             ],
//       ),
//     );

//     await Printing.layoutPdf(
//       onLayout: (PdfPageFormat format) async => pdf.save(),
//     );
//   }

//   void _deleteAllRows() {
//     if (widget.config.onDelete != null) {
//       for (int i = widget.config.data.length - 1; i >= 0; i--) {
//         widget.config.onDelete!(i);
//       }
//     }
//   }

//   void _toggleSelection(int index) {
//     setState(() {
//       _selectedRows[index] = !_selectedRows[index];
//       widget.config.onRowSelect?.call(index, _selectedRows[index]);
//     });
//   }

//   void _toggleSelectAll(bool selectAll) {
//     setState(() {
//       for (int i = 0; i < _selectedRows.length; i++) {
//         _selectedRows[i] = selectAll;
//         widget.config.onRowSelect?.call(i, selectAll);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final allRowsSelected = _selectedRows.every((isSelected) => isSelected);
//     final filtered = filteredData;
//     print('object');
//     filtered.forEach((e) => print(e));
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               if (widget.config.showSearch)
//                 SizedBox(
//                   width: 300,
//                   child: TextField(
//                     onChanged: (value) {
//                       setState(() {
//                         _searchQuery = value;
//                       });
//                     },
//                     decoration: InputDecoration(
//                       labelText: widget.config.searchHint ?? 'Search...',
//                       border: const OutlineInputBorder(),
//                       prefixIcon: const Icon(Icons.search),
//                     ),
//                   ),
//                 ),
//               if (widget.config.showPrint)
//                 ElevatedButton.icon(
//                   onPressed: () => _printTable(filtered),
//                   icon: const Icon(Icons.print),
//                   label: const Text("Print"),
//                 ),
//               if (widget.config.showExcelExport)
//                 ElevatedButton.icon(
//                   onPressed: () => _downloadExcel(filtered),
//                   icon: const Icon(Icons.table_chart),
//                   label: const Text("Download Excel"),
//                 ),
//               if (widget.config.showDeleteAll && allRowsSelected)
//                 ElevatedButton.icon(
//                   onPressed: _deleteAllRows,
//                   icon: const Icon(Icons.delete),
//                   label: const Text("Delete All"),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Expanded(
//             child: DataTable2(
//               fixedColumnsColor: Colors.amberAccent,
//               fixedCornerColor: Colors.red,
//               headingRowColor: MaterialStatePropertyAll(Colors.grey[200]!),
//               columnSpacing: 12,
//               horizontalMargin: 12,
//               minWidth: 800,
//               sortColumnIndex: widget.config.sortColumnIndex,
//               sortAscending: widget.config.sortAscending ?? true,
//               columns: [
//                 if (widget.config.isSelectable)
//                   DataColumn2(
//                     label:
//                         widget.config.showSelectAll
//                             ? Checkbox(
//                               value: allRowsSelected,
//                               onChanged: (bool? value) {
//                                 _toggleSelectAll(value ?? false);
//                               },
//                             )
//                             : const SizedBox.shrink(),
//                     size: ColumnSize.S,
//                   ),
//                 ...widget.config.columns,
//                 if (widget.config.showRowActions)
//                   const DataColumn2(label: Text('Actions'), size: ColumnSize.S),
//               ],
//               rows:
//                   filtered.asMap().entries.map((entry) {
//                     print(entry);
//                     final index = entry.key;
//                     final row = entry.value;
//                     print('row');
//                     print(row);
//                     return DataRow(
//                       color: MaterialStateProperty.resolveWith<Color>((states) {
//                         if (_selectedRows[index]) {
//                           return Colors.grey.shade300;
//                         }
//                         return Colors.white;
//                       }),
//                       cells: [
//                         if (widget.config.isSelectable)
//                           DataCell(
//                             Checkbox(
//                               value: _selectedRows[index],
//                               onChanged: (bool? value) {
//                                 _toggleSelection(index);
//                               },
//                             ),
//                           ),
//                         ...widget.config.columns.map((column) {
//                           if (widget.config.customCellBuilders != null &&
//                               widget.config.customCellBuilders!.containsKey(
//                                 column.label.toString(),
//                               )) {
//                             return DataCell(
//                               widget.config.customCellBuilders![column.label
//                                   .toString()]!(row),
//                             );
//                           }
//                           return DataCell(Text(row.toString()));
//                         }),
//                         if (widget.config.showRowActions)
//                           DataCell(
//                             Row(
//                               children: [
//                                 if (widget.config.onView != null)
//                                   IconButton(
//                                     icon: const Icon(
//                                       Icons.visibility,
//                                       color: Colors.blue,
//                                     ),
//                                     onPressed: () => widget.config.onView!(row),
//                                   ),
//                                 if (widget.config.onEdit != null)
//                                   IconButton(
//                                     icon: const Icon(Icons.edit),
//                                     onPressed: () async {
//                                       final updated = await widget
//                                           .config
//                                           .onEdit!(row);
//                                       if (updated != null) {
//                                         setState(() {});
//                                       }
//                                     },
//                                   ),
//                                 if (widget.config.onDelete != null)
//                                   IconButton(
//                                     icon: const Icon(
//                                       Icons.delete,
//                                       color: Colors.red,
//                                     ),
//                                     onPressed:
//                                         () => widget.config.onDelete!(index),
//                                   ),
//                               ],
//                             ),
//                           ),
//                       ],
//                     );
//                   }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
