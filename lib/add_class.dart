import 'package:flutter/material.dart';
import 'package:schmgtsystem/color_pallete.dart';
import 'package:equatable/equatable.dart';
import 'package:schmgtsystem/widgets/screen_header.dart';


class AddClass extends StatefulWidget {
  const AddClass({super.key});

  @override
  State<AddClass> createState() => _AddClassState();
}

class _AddClassState extends State<AddClass> {
  bool prenurseryCheck = false;
  bool nurseryCheck = false;
  bool primaryCheck = false;
  bool juniorSecondaryCheck = false;
  bool seniorSecondaryCheck = false;
  final List<StudentRow> rows = [
    StudentRow(className: 'Grade 1', section: 'A', studentName: 'Alice'),
    StudentRow(className: 'Grade 1', section: 'B', studentName: 'Bob'),
    StudentRow(className: 'Grade 2', section: 'A', studentName: 'Charlie'),
    StudentRow(className: 'Grade 2', section: 'B', studentName: 'Diana'),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            ScreenHeader(group: 'Class',subgroup: 'Add Class',),
SizedBox(height: 30,),
            Row(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Class',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Text(
                              'Name ',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '*',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Text(
                              'Section ',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '*',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.0, // default is 16.0 on both sides
                            vertical: 0.0, // default is 0.0 vertically
                          ),
                          title: const Text(
                            'Prenursery',
                            style: TextStyle(fontSize: 14),
                          ),
                          value: prenurseryCheck,
                          onChanged: (bool? newValue) {
                            setState(() {
                              prenurseryCheck = newValue ?? false;
                              nurseryCheck = false;
                              primaryCheck = false;
                              seniorSecondaryCheck = false;
                              juniorSecondaryCheck = false;
                            });
                          },
                          controlAffinity:
                              ListTileControlAffinity
                                  .leading, // checkbox before text
                          activeColor: Theme.of(context).primaryColor,
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.0, // default is 16.0 on both sides
                            vertical: 0.0, // default is 0.0 vertically
                          ),
                          title: const Text('Nursery',
                            style: TextStyle(fontSize: 14),

                          ),
                          value: nurseryCheck,
                          onChanged: (bool? newValue) {
                            setState(() {
                              nurseryCheck = newValue ?? false;
                              prenurseryCheck = false;
                              primaryCheck = false;
                              seniorSecondaryCheck = false;
                              juniorSecondaryCheck = false;
                            });
                          },
                          controlAffinity:
                              ListTileControlAffinity
                                  .leading, // checkbox before text
                          activeColor: Theme.of(context).primaryColor,
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.0, // default is 16.0 on both sides
                            vertical: 0.0, // default is 0.0 vertically
                          ),
                          title: const Text('Primary',
                            style: TextStyle(fontSize: 14),
                          ),
                          value: primaryCheck,
                          onChanged: (bool? newValue) {
                            setState(() {
                              primaryCheck = newValue ?? false;
                              prenurseryCheck = false;
                              nurseryCheck = false;
                              seniorSecondaryCheck = false;
                              juniorSecondaryCheck = false;
                            });
                          },
                          controlAffinity:
                              ListTileControlAffinity
                                  .leading, // checkbox before text
                          activeColor: Theme.of(context).primaryColor,
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.0, // default is 16.0 on both sides
                            vertical: 0.0, // default is 0.0 vertically
                          ),
                          title: const Text('Junior Secondary',
                            style: TextStyle(fontSize: 14),
                          ),
                          value: juniorSecondaryCheck,
                          onChanged: (bool? newValue) {
                            setState(() {
                              juniorSecondaryCheck = newValue ?? false;
                              prenurseryCheck = false;
                              primaryCheck = false;
                              seniorSecondaryCheck = false;
                              nurseryCheck = false;
                            });
                          },
                          controlAffinity:
                              ListTileControlAffinity
                                  .leading, // checkbox before text
                          activeColor: Theme.of(context).primaryColor,
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.0, // default is 16.0 on both sides
                            vertical: 0.0, // default is 0.0 vertically
                          ),
                          title: const Text('Secondary',
                            style: TextStyle(fontSize: 14),
                          ),
                          value: seniorSecondaryCheck,
                          onChanged: (bool? newValue) {
                            setState(() {
                              seniorSecondaryCheck = newValue ?? false;
                              prenurseryCheck = false;
                              primaryCheck = false;
                              nurseryCheck = false;
                              juniorSecondaryCheck = false;
                            });
                          },
                          controlAffinity:
                              ListTileControlAffinity
                                  .leading, // checkbox before text
                          activeColor: Theme.of(context).primaryColor,
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Text(
                              'Save Class',
                              style: TextStyle(color: Colors.white,fontSize: 14),
                            ),

                            style: ElevatedButton.styleFrom(
                              shape: BeveledRectangleBorder(
                                borderRadius: BorderRadius.circular(3),
                              ),
                              backgroundColor: homeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Class')),
            DataColumn(label: Text('Section')),
            DataColumn(label: Text('Student')),
            DataColumn(label: Text('Action')),
          ],
          rows: rows.map((row) {
            return DataRow(cells: [
              DataCell(Text(row.className)),
              DataCell(Text(row.section)),
              DataCell(Text(row.studentName)),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit ${row.studentName}',
                  onPressed: () {
                    // TODO: handle edit action
                  },
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    )
                  ),
                
              ],
            ),
          ],
        ),
      ),
    );
  }
}





class StudentRow extends Equatable {
  final String className;
  final String section;
  final String studentName;

  const StudentRow({
    required this.className,
    required this.section,
    required this.studentName,
  });

  @override
  List<Object?> get props => [className, section, studentName];
}

// 2) DataTableSource for PaginatedDataTable
class StudentDataSource extends DataTableSource {
  final List<StudentRow> _originalRows;
  List<StudentRow> _displayRows;
  final Set<StudentRow> _selected = {};

  StudentDataSource(List<StudentRow> rows)
    : _originalRows = rows,
      _displayRows = List.from(rows);

  // Filtering
  void filter(String query) {
    _displayRows =
        query.isEmpty
            ? List.from(_originalRows)
            : _originalRows
                .where(
                  (r) =>
                      r.studentName.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
    notifyListeners();
  }

  // Sorting
  void sort<T>(Comparable<T> Function(StudentRow d) getField, bool asc) {
    _displayRows.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return asc
          ? Comparable.compare(aValue as Comparable, bValue as Comparable)
          : Comparable.compare(bValue as Comparable, aValue as Comparable);
    });
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    final row = _displayRows[index];
    return DataRow.byIndex(
      index: index,
      selected: _selected.contains(row),
      onSelectChanged: (sel) {
        if (sel == null) return;
        if (sel) {
          _selected.add(row);
        } else {
          _selected.remove(row);
        }
        notifyListeners();
      },
      cells: [
        DataCell(Text(row.className)),
        DataCell(Text(row.section)),
        DataCell(Text(row.studentName)),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit',
                onPressed: () {
                  // handle edit
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: 'Delete',
                onPressed: () {
                  // handle delete
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _displayRows.length;
  @override
  int get selectedRowCount => _selected.length;
}
