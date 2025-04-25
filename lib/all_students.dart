import 'dart:html' as html;
import 'dart:io';
import 'dart:typed_data';

import 'package:data_table_2/data_table_2.dart';
import 'package:excel/excel.dart' ;
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


class MyDataRowModel {
  String className;
  String section;
  String student;
  int number;
  String profilePictureUrl;
  html.File? imageFile; 
     Uint8List? imageBytes;
  // This will hold the picked image file

  MyDataRowModel({
    required this.className,
    required this.section,
    required this.student,
    required this.number,
    this.profilePictureUrl = '',
     this.imageFile,
        this.imageBytes,
  });

   MyDataRowModel copyWith({
    String? className,
    String? section,
    String? student,
    int? number,
    String? profilePictureUrl,
    Uint8List? imageBytes,
    
  }) {
    return MyDataRowModel(
      className: className ?? this.className,
      section: section ?? this.section,
      student: student ?? this.student,
      number: number ?? this.number,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      imageBytes: imageBytes ?? this.imageBytes,
    );
  }
}

class AllStudents extends StatefulWidget {
  const AllStudents({super.key});

  @override
  State<AllStudents> createState() => _AllStudentsState();
}

class _AllStudentsState extends State<AllStudents> {
  // List<MyDataRowModel> _data = [];
  int? _sortColumnIndex;
  bool _isAscending = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedRows = List.generate(_data.length, (index) => false);
  }

  final List<MyDataRowModel> _data = [
    MyDataRowModel(
      className: "Primary 1",
      section: "A",
      student: "John Doe",
      number: 1,
      profilePictureUrl:
          'https://ik.imagekit.io/dp750urb0/userImg.jpeg?updatedAt=1742563967488',
    ),
    MyDataRowModel(
      className: "Primary 2",
      section: "B",
      student: "Jane Smith",
      number: 2,
      profilePictureUrl:
          'https://ik.imagekit.io/dp750urb0/featured1.jpeg?updatedAt=1742563965798',
    ),
  ];

  List<MyDataRowModel> get filteredData {
    return _data
        .where(
          (row) =>
              row.className.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              row.section.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              row.student.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              row.number.toString().contains(_searchQuery),
        )
        .toList();
  }

  void _deleteAllRows() {
    setState(() {
      _data.clear(); // Clear all rows
      _selectedRows.clear(); // Clear the selection
    });
  }

  List<bool> _selectedRows = [];
  void _toggleSelection(int index) {
    setState(() {
      _selectedRows[index] = !_selectedRows[index];
    });
  }

  void _toggleSelectAll(bool selectAll) {
    setState(() {
      for (int i = 0; i < _selectedRows.length; i++) {
        _selectedRows[i] = selectAll;
      }
    });
  }

  Future<void> _downloadExcel() async {
    final excel = Excel.createExcel();
    final Sheet sheetObject = excel['Student Data'];

    // Add header
    sheetObject.appendRow([
      'Class',
      'Section',
      'Student',
      'Number',
      'Profile Picture',
    ]);

    // Add data rows
    for (var row in _data) {
      sheetObject.appendRow([
        row.className,
        row.section,
        row.student,
        row.number,
        row.profilePictureUrl,
      ]);
    }

    final excelBytes = excel.encode();

    if (excelBytes == null) return;

    // For Web
    final blob = html.Blob([excelBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor =
        html.AnchorElement(href: url)
          ..setAttribute("download", "students_table.xlsx")
          ..click();
    html.Url.revokeObjectUrl(url);
  }

  /////////////////////////////////////PRINT WITHOUT PROFILE PICTURE///////////////////////
  void _printTable2() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build:
            (pw.Context context) => [
              pw.Table.fromTextArray(
                headers: ['Class', 'Section', 'Student', 'Number'],
                data:
                    _data
                        .map(
                          (row) => [
                            row.className,
                            row.section,
                            row.student,
                            row.number,
                          ],
                        )
                        .toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                border: pw.TableBorder.all(),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  ///////////////////////////////PRINT WITH IMAGE///////////////////////////////
  Future<void> _printTable() async {
    final pdf = pw.Document();

    List<List<dynamic>> tableData = [];

    for (var row in _data) {
      // Try to load image from URL
      pw.ImageProvider imageProvider;
      if (row.profilePictureUrl.isNotEmpty) {
        try {
          // Fetch image from URL and convert to MemoryImage
          final response = await http.get(Uri.parse(row.profilePictureUrl));
          if (response.statusCode == 200) {
            final imageBytes = response.bodyBytes;
            imageProvider = pw.MemoryImage(imageBytes); // Load image from bytes
          } else {
            // Fallback in case of failure
            imageProvider = await _getFallbackImage(); // Load fallback image
          }
        } catch (e) {
          // Handle error (e.g., invalid URL)
          imageProvider = await _getFallbackImage(); // Load fallback image
        }
      } else {
        imageProvider =
            await _getFallbackImage(); // Load fallback image if no URL
      }

      // Create table row
      tableData.add([
        row.className,
        row.section,
        row.student,
        row.number,
        imageProvider, // Add the image provider to the row data
      ]);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build:
            (pw.Context context) => [
              pw.Table(
                border: pw.TableBorder.all(
                  width: 0.5,
                ), // Table border with custom width
                columnWidths: {
                  0: pw.FlexColumnWidth(2),
                  1: pw.FlexColumnWidth(1),
                  2: pw.FlexColumnWidth(3),
                  3: pw.FlexColumnWidth(1),
                  4: pw.FlexColumnWidth(2),
                },
                children: [
                  // Table header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: PdfColor(0.8, 0.8, 0.8),
                    ),
                    children: [
                      _buildHeaderCell('Class'),
                      _buildHeaderCell('Section'),
                      _buildHeaderCell('Student'),
                      _buildHeaderCell('Number'),
                      _buildHeaderCell('Profile Picture'),
                    ],
                  ),
                  // Table data rows
                  ...tableData.map((row) {
                    return pw.TableRow(
                      children: [
                        _buildCell(row[0]),
                        _buildCell(row[1]),
                        _buildCell(row[2]),
                        _buildCell(row[3].toString()),
                        // Render image if it's available
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Image(row[4], width: 40, height: 40),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // Function to build each header cell with consistent style
  pw.Widget _buildHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4.0),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 12,
          color: PdfColors.black,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  // Function to build each table cell with consistent style
  pw.Widget _buildCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4.0),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 10, color: PdfColors.black),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  Future<pw.ImageProvider> _getFallbackImage() async {
    // You can create a small blank image or use a predefined one here
    final fallbackImageBytes = await _generateBlankImage();
    return pw.MemoryImage(
      Uint8List.fromList(fallbackImageBytes),
    ); // Convert List<int> to Uint8List
  }

  // Function to generate a blank image (placeholder)
  Future<List<int>> _generateBlankImage() async {
    // Generate a simple 40x40 pixel white image (you can customize this)
    final img = List<int>.generate(
      40 * 40 * 4,
      (i) => 255,
    ); // Solid white image
    return img;
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  void _sort<T>(
    Comparable<T> Function(MyDataRowModel d) getField,
    int columnIndex,
    bool ascending,
  ) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _isAscending = ascending;
      _data.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return ascending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
    });
  }

  Future<void> _downloadTable() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build:
            (pw.Context context) => [
              pw.Table.fromTextArray(
                headers: ['Class', 'Section', 'Student', 'Number'],
                data:
                    _data
                        .map(
                          (row) => [
                            row.className,
                            row.section,
                            row.student,
                            row.number,
                          ],
                        )
                        .toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                border: pw.TableBorder.all(),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ],
      ),
    );

    // Save/download the PDF
    final pdfBytes = await pdf.save();
    await Printing.sharePdf(bytes: pdfBytes, filename: 'students_table.pdf');
  }
  // Handle image upload
  Uint8List? _imageBytes;

Future<void> _pickImage() async {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((event) {
          final bytes = reader.result as Uint8List?;
          if (bytes != null) {
            // Update state
            setState(() {
              _imageBytes = bytes;
            });
          }
        });
      }
    });
  }

  // void _showViewDialog(MyDataRowModel row) {
  //   showDialog(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           title: const Text("Student Details"),
  //           content: SizedBox(
  //             width: MediaQuery.of(context).size.width * 0.5,
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Text("Class: ${row.className}"),
  //                 Text("Section: ${row.section}"),
  //                 Text("Student: ${row.student}"),
  //                 Text("Number: ${row.number}"),
  //               ],
  //             ),
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: const Text("Close"),
  //             ),
  //           ],
  //         ),
  //   );
  // }

  // void _showEditDialog(MyDataRowModel row) {
  //   final classController = TextEditingController(text: row.className);
  //   final sectionController = TextEditingController(text: row.section);
  //   final studentController = TextEditingController(text: row.student);
  //   final numberController = TextEditingController(text: row.number.toString());
  //   // Use this to store the selected image temporarily
  //   html.File? selectedImage;
  //   showDialog(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           title: const Text("Edit Student Info"),
  //           content: SizedBox(
  //             width: MediaQuery.of(context).size.width * 0.5,
  //             child: SingleChildScrollView(
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                    GestureDetector(
  //               onTap: _pickImage, // Open the file picker when tapped
  //               child: CircleAvatar(
  //                 radius: 50,
  //                 backgroundImage: _imageBytes != null
  //                     ? MemoryImage(_imageBytes!) // Show selected image
  //                     : null,
  //                 child: _imageBytes == null
  //                     ? Icon(Icons.account_circle, size: 50)
  //                     : null, // Show default icon if no image selected
  //               ),
  //             ),
  //             SizedBox(height: 20),
  //                   TextField(
  //                     controller: classController,
  //                     decoration: const InputDecoration(labelText: "Class"),
  //                   ),
  //                   const SizedBox(height: 8),
  //                   TextField(
  //                     controller: sectionController,
  //                     decoration: const InputDecoration(labelText: "Section"),
  //                   ),
  //                   const SizedBox(height: 8),
  //                   TextField(
  //                     controller: studentController,
  //                     decoration: const InputDecoration(labelText: "Student"),
  //                   ),
  //                   const SizedBox(height: 8),
  //                   TextField(
  //                     controller: numberController,
  //                     keyboardType: TextInputType.number,
  //                     decoration: const InputDecoration(labelText: "Number"),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: const Text("Cancel"),
  //             ),
  //             ElevatedButton(
  //               onPressed: () {
  //                 setState(() {
  //                   row.className = classController.text;
  //                   row.section = sectionController.text;
  //                   row.student = studentController.text;
  //                   row.number =
  //                       int.tryParse(numberController.text) ?? row.number;
  //                 });
  //                 Navigator.pop(context);
  //               },
  //               child: const Text("Save"),
  //             ),
  //           ],
  //         ),
  //   );
  // }

  void _deleteRow(int index) {
    setState(() {
      _data.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final allRowsSelected = _selectedRows.every((isSelected) => isSelected);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Search...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _printTable,
                icon: const Icon(Icons.print),
                label: const Text("Print WITH PIC"),
              ),
              ElevatedButton.icon(
                onPressed: _printTable2,
                icon: const Icon(Icons.print),
                label: const Text("Print"),
              ),
              ElevatedButton.icon(
                onPressed: _downloadTable,
                icon: Icon(Icons.download),
                label: Text('Download Table'),
              ),
              ElevatedButton.icon(
                onPressed: _downloadExcel,
                icon: Icon(Icons.table_chart),
                label: Text('Download Excel'),
              ),
              if (allRowsSelected)
                ElevatedButton.icon(
                  onPressed: _deleteAllRows,
                  icon: const Icon(Icons.delete),
                  label: const Text("Delete All"),
                ),
            ],
          ),
          Expanded(
            child: DataTable2(fixedColumnsColor: Colors.amberAccent,
            fixedCornerColor: Colors.red,
          headingRowColor: WidgetStatePropertyAll(Colors.grey[200]!),
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 800,
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _isAscending,

              columns: [
                DataColumn2(
                  
                  label: Checkbox(
                    value: allRowsSelected,
                    onChanged: (bool? value) {
                      _toggleSelectAll(value ?? false);
                    },
                  ),
                  size: ColumnSize.V,
                  onSort:
                      (columnIndex, ascending) =>
                          _sort((d) => d.className, columnIndex, ascending),
                ),
                DataColumn2(
                  
                  label: const Text('No'),
                  size: ColumnSize.V,
                  onSort:
                      (columnIndex, ascending) =>
                          _sort((d) => d.className, columnIndex, ascending),
                ),
                DataColumn2(label: const Text('Picture'),size: ColumnSize.S),
                DataColumn(
                  label: const Text('Section'),
                  onSort:
                      (columnIndex, ascending) =>
                          _sort((d) => d.section, columnIndex, ascending),
                ),
                DataColumn(
                  label: const Text('Student'),
                  onSort:
                      (columnIndex, ascending) =>
                          _sort((d) => d.student, columnIndex, ascending),
                ),
                const DataColumn(label: Text('Action')),
                DataColumn(
                  label: const Text('Number'),
                  numeric: true,
                  onSort:
                      (columnIndex, ascending) =>
                          _sort((d) => d.number, columnIndex, ascending),
                ),
              ],

              rows:
                  filteredData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final d = entry.value;
                    return DataRow(
                      color: MaterialStateProperty.resolveWith<Color>((states) {
                        if (_selectedRows[index]) {
                          return Colors.grey.shade300; // Grey out selected rows
                        }
                        return Colors.white; // Default white background
                      }),
                      cells: [
                        DataCell(
                          Checkbox(
                            value: _selectedRows[index],
                            onChanged: (bool? value) {
                              _toggleSelection(index);
                            },
                          ),
                        ),
                        DataCell(Text(d.number.toString())),
                       DataCell(
                          GestureDetector(
                            onTap: () => _pickImage(),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  d.imageBytes != null
                                      ? MemoryImage(d.imageBytes!)
                                      : (d.profilePictureUrl.isNotEmpty
                                          ? NetworkImage(d.profilePictureUrl)
                                          : null),
                              child:
                                  d.imageBytes == null &&
                                          d.profilePictureUrl.isEmpty
                                      ? const Icon(Icons.person, size: 20)
                                      : null,
                            ),
                          ),
                        ),

                        DataCell(Text(d.className)),
                        DataCell(Text(d.section)),
                        DataCell(Text(d.student)),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.visibility,
                                  color: Colors.blue,
                                ),
                                onPressed: () =>showDialog(context: context, builder:(context) => StudentDetailsDialog(student: d,),),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                tooltip: 'Edit',
                                onPressed: () async {
                                  final updated = await showDialog<
                                    MyDataRowModel
                                  >(
                                    context:
                                        context, // ensure you passed context into the data source
                                    builder:
                                        (_) => EditStudentDialog(initial: d),
                                  );
                                 if (updated != null) {
                                    setState(() {
                                      _data[_data.indexOf(d)] = updated;
                                    });
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteRow(index),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}


class EditStudentDialog extends StatefulWidget {
  final MyDataRowModel initial;
  const EditStudentDialog({super.key, required this.initial});

  @override
  State<EditStudentDialog> createState() => _EditStudentDialogState();
}

class _EditStudentDialogState extends State<EditStudentDialog> {
  late final TextEditingController _classCtrl;
  late final TextEditingController _sectionCtrl;
  late final TextEditingController _studentCtrl;
  late final TextEditingController _numberCtrl;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _classCtrl = TextEditingController(text: widget.initial.className);
    _sectionCtrl = TextEditingController(text: widget.initial.section);
    _studentCtrl = TextEditingController(text: widget.initial.student);
    _numberCtrl = TextEditingController(text: widget.initial.number.toString());
    _imageBytes = widget.initial.imageBytes;
  }

  @override
  void dispose() {
    _classCtrl.dispose();
    _sectionCtrl.dispose();
    _studentCtrl.dispose();
    _numberCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((event) {
          final bytes = reader.result as Uint8List?;
          if (bytes != null) {
            setState(() {
              _imageBytes = bytes;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Student Info'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _imageBytes != null
                          ? MemoryImage(_imageBytes!)
                          : (widget.initial.profilePictureUrl.isNotEmpty
                              ? NetworkImage(widget.initial.profilePictureUrl)
                              : null),
                  child:
                      _imageBytes == null &&
                              widget.initial.profilePictureUrl.isEmpty
                          ? const Icon(Icons.person, size: 50)
                          : null,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _classCtrl,
                decoration: const InputDecoration(labelText: 'Class'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _sectionCtrl,
                decoration: const InputDecoration(labelText: 'Section'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _studentCtrl,
                decoration: const InputDecoration(labelText: 'Student'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _numberCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Number'),
                // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final updated = widget.initial.copyWith(
              className: _classCtrl.text,
              section: _sectionCtrl.text,
              student: _studentCtrl.text,
              number: int.tryParse(_numberCtrl.text) ?? widget.initial.number,
              imageBytes: _imageBytes,
            );
            Navigator.pop(context, updated);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}


class StudentDetailsDialog extends StatefulWidget {
  final MyDataRowModel student;

  const StudentDetailsDialog({
    Key? key,
    required this.student,
  }) : super(key: key);

  @override
  State<StudentDetailsDialog> createState() => _StudentDetailsDialogState();
}

class _StudentDetailsDialogState extends State<StudentDetailsDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 4,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.6,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildProfileSection(),
                const SizedBox(height: 32),
                _buildDetailsSection(),
                const SizedBox(height: 24),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Student Details",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Close',
        ),
      ],
    );
  }

  Widget _buildProfileSection() {
    return Center(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // border: Border.all(
              //   color: Theme.of(context).primaryColor.withOpacity(0.2),
              //   width: 4,
              // ),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[200],
              backgroundImage: _getProfileImage(),
              child: _getProfilePlaceholder(),
            ),
          ),
          const SizedBox(height: 16),
          if (widget.student.student.isNotEmpty)
            Text(
              widget.student.student,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          if (widget.student.className.isNotEmpty || widget.student.section.isNotEmpty)
            Text(
              '${widget.student.className} ${widget.student.section}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }

  ImageProvider? _getProfileImage() {
    if (widget.student.imageBytes != null) return MemoryImage(widget.student.imageBytes!);
    if (widget.student.profilePictureUrl.isNotEmpty) {
      return NetworkImage(widget.student.profilePictureUrl);
    }
    return null;
  }

  Widget? _getProfilePlaceholder() {
    if (widget.student.imageBytes == null && widget.student.profilePictureUrl.isEmpty) {
      return const Icon(Icons.person, size: 60, color: Colors.white);
    }
    return null;
  }

  Widget _buildDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildDetailItem(
            icon: Icons.school,
            label: "Class",
            value: widget.student.className,
          ),
          const Divider(height: 24, thickness: 0.5),
          _buildDetailItem(
            icon: Icons.groups,
            label: "Section",
            value: widget.student.section,
          ),
          const Divider(height: 24, thickness: 0.5),
          _buildDetailItem(
            icon: Icons.person,
            label: "Student",
            value: widget.student.student,
          ),
          const Divider(height: 24, thickness: 0.5),
          _buildDetailItem(
            icon: Icons.confirmation_number,
            label: "Number",
            value: widget.student.number.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        child: const Text("Close", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
