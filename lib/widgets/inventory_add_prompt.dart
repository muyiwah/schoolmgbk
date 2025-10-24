import 'package:flutter/material.dart';
import 'package:schmgtsystem/widgets/success_snack.dart';

class AssignmentInterface extends StatefulWidget {
  const AssignmentInterface({Key? key}) : super(key: key);

  @override
  State<AssignmentInterface> createState() => _AssignmentInterfaceState();
}

class _AssignmentInterfaceState extends State<AssignmentInterface> {
  String selectedAssignType = 'Staff';
  String? selectedStaffMember;
  int quantity = 1;
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  final List<String> staffMembers = [
    'John Smith',
    'Sarah Johnson',
    'Michael Brown',
    'Emily Davis',
    'David Wilson',
  ];

  @override
  void dispose() {
    _purposeController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  void _incrementQuantity() {
    if (quantity < 89) {
      setState(() {
        quantity++;
      });
    }
  }

  void _decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDateController.text =
            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      width: MediaQuery.sizeOf(context).width * .5,
      height: MediaQuery.sizeOf(context).height * .8,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.book, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Book',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Available',
                    style: TextStyle(fontSize: 14, color: Colors.blue),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Assignment status
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Already Assigned: 30',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    '${90 - quantity} remaining',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Assign To section
            const Text(
              'Assign To',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            // Toggle buttons
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAssignType = 'Staff';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          color:
                              selectedAssignType == 'Staff'
                                  ? Colors.blue
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person,
                              color:
                                  selectedAssignType == 'Staff'
                                      ? Colors.white
                                      : Colors.grey[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Staff',
                              style: TextStyle(
                                color:
                                    selectedAssignType == 'Staff'
                                        ? Colors.white
                                        : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAssignType = 'Class';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          color:
                              selectedAssignType == 'Class'
                                  ? Colors.grey[600]
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.groups,
                              color:
                                  selectedAssignType == 'Class'
                                      ? Colors.white
                                      : Colors.grey[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Class',
                              style: TextStyle(
                                color:
                                    selectedAssignType == 'Class'
                                        ? Colors.white
                                        : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Select Staff Member
            const Text(
              'Select Staff Member',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  border: InputBorder.none,
                ),
                hint: const Text('Choose a staff member...'),
                value: selectedStaffMember,
                items:
                    staffMembers.map((String member) {
                      return DropdownMenuItem<String>(
                        value: member,
                        child: Text(member),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedStaffMember = newValue;
                  });
                },
              ),
            ),

            const SizedBox(height: 24),

            // Quantity to Assign
            const Text(
              'Quantity to Assign',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: IconButton(
                    onPressed: _decrementQuantity,
                    icon: const Icon(Icons.remove, size: 20),
                    color: Colors.grey[600],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      quantity.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: IconButton(
                    onPressed: _incrementQuantity,
                    icon: const Icon(Icons.add, size: 20),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              '${89 - quantity} left after this assignment',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 24),

            // Assignment Purpose
            const Text(
              'Assignment Purpose (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextFormField(
                controller: _purposeController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText:
                      'e.g., For class distribution, Projector for SS2 ICT...',
                  contentPadding: EdgeInsets.all(16.0),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Due Date
            const Text(
              'Due Date (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextFormField(
                controller: _dueDateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: const InputDecoration(
                  hintText: 'mm/dd/yyyy',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.calendar_month, color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Assignment Preview
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assignment Preview:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14, color: Colors.blue),
                      children: [
                        const TextSpan(text: "You're assigning "),
                        TextSpan(
                          text:
                              '$quantity copy${quantity > 1 ? 'ies' : ''} of Mathematics Textbook',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: ' to '),
                        TextSpan(
                          text: selectedStaffMember ?? 'Select a staff member',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  fixedSize: Size(300, 50),
                ),
                onPressed: () {
                  showSnackbar(context, 'Item Assigned');
                  Navigator.pop(context);
                },
                child: Text('Assign', style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
