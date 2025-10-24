import 'package:flutter/material.dart';
import 'package:schmgtsystem/widgets/inventory_add_prompt.dart';

class InventoryItem {
  final String id;
  final String name;
  final String itemId;
  final String category;
  final int quantity;
  final String? assignedTo;
  final String assignedToClass;
  final String status;
  final IconData categoryIcon;
  final Color categoryColor;

  InventoryItem({
    required this.id,
    required this.name,
    required this.itemId,
    required this.category,
    required this.quantity,
    this.assignedTo,
    required this.assignedToClass,
    required this.status,
    required this.categoryIcon,
    required this.categoryColor,
  });
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String selectedCategory = 'All Categories';
  String selectedStatus = 'All Status';
  String selectedStaff = 'All Staff';
  String searchQuery = '';

  final List<String> categories = [
    'All Categories',
    'Books',
    'Electronics',
    'Furniture',
    'Sports Equipment',
  ];

  final List<String> statuses = [
    'All Status',
    'Assigned',
    'Available',
    'Due for Return',
    'Maintenance',
  ];

  final List<String> staffMembers = [
    'All Staff',
    'Mr. Adebayo',
    'Ms. Johnson',
    'Dr. Smith',
    'Mrs. Williams',
  ];

  final List<InventoryItem> items = [
    InventoryItem(
      id: '1',
      name: 'Mathematics Textbook (JSS1)',
      itemId: 'MTH-JSS1-001',
      category: 'Books',
      quantity: 100,
      assignedTo: 'Mr. Adebayo',
      assignedToClass: 'JSS1',
      status: 'Assigned',
      categoryIcon: Icons.book,
      categoryColor: const Color(0xFF4F46E5),
    ),
    InventoryItem(
      id: '2',
      name: 'Projector X10',
      itemId: 'PROJ-X10-001',
      category: 'Electronics',
      quantity: 2,
      assignedToClass: '',
      status: 'Available',
      categoryIcon: Icons.devices,
      categoryColor: const Color(0xFF7C3AED),
    ),
    InventoryItem(
      id: '3',
      name: 'Chemistry Lab Equipment Set',
      itemId: 'CHEM-LAB-001',
      category: 'Equipment',
      quantity: 5,
      assignedTo: 'Dr. Smith',
      assignedToClass: 'SS2',
      status: 'Assigned',
      categoryIcon: Icons.science,
      categoryColor: const Color(0xFF059669),
    ),
    InventoryItem(
      id: '4',
      name: 'Basketball Set',
      itemId: 'SPORT-BB-001',
      category: 'Sports Equipment',
      quantity: 1,
      assignedToClass: '',
      status: 'Due for Return',
      categoryIcon: Icons.sports_basketball,
      categoryColor: const Color(0xFFDC2626),
    ),
  ];

  List<InventoryItem> get filteredItems {
    return items.where((item) {
      final matchesSearch =
          item.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.itemId.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory =
          selectedCategory == 'All Categories' ||
          item.category == selectedCategory;
      final matchesStatus =
          selectedStatus == 'All Status' || item.status == selectedStatus;
      final matchesStaff =
          selectedStaff == 'All Staff' || item.assignedTo == selectedStaff;

      return matchesSearch && matchesCategory && matchesStatus && matchesStaff;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final totalItems = items.length;
    final assignedItems =
        items.where((item) => item.status == 'Assigned').length;
    final unassignedItems =
        items.where((item) => item.status == 'Available').length;
    final dueForReturn =
        items.where((item) => item.status == 'Due for Return').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Inventory Management',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Admin Panel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            
                            child: AssignmentInterface(),),
                        );
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Assign Item'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Export'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Stats Cards
            Row(
              children: [
                _buildStatCard(
                  'Total Items',
                  totalItems.toString(),
                  Icons.inventory_2,
                  const Color(0xFF3B82F6),
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Assigned Items',
                  assignedItems.toString(),
                  Icons.person,
                  const Color(0xFF10B981),
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Unassigned Items',
                  unassignedItems.toString(),
                  Icons.inventory,
                  const Color(0xFF6B7280),
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Due for Return',
                  dueForReturn.toString(),
                  Icons.schedule,
                  const Color(0xFFDC2626),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Filters and Search
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    onChanged: (value) => setState(() => searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search by item name, ID, category...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF6B7280),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildDropdown('All Categories', categories, selectedCategory, (
                  value,
                ) {
                  setState(() => selectedCategory = value!);
                }),
                const SizedBox(width: 16),
                _buildDropdown('All Status', statuses, selectedStatus, (value) {
                  setState(() => selectedStatus = value!);
                }),
                const SizedBox(width: 16),
                _buildDropdown('All Staff', staffMembers, selectedStaff, (
                  value,
                ) {
                  setState(() => selectedStaff = value!);
                }),
              ],
            ),

            const SizedBox(height: 24),

            // Data Table
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Table Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 40), // Checkbox space
                          const Expanded(
                            flex: 3,
                            child: Text(
                              'ITEM NAME',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 2,
                            child: Text(
                              'CATEGORY',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: Text(
                              'QUANTITY',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 2,
                            child: Text(
                              'ASSIGNED TO',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: Text(
                              'STATUS',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: Text(
                              'ACTIONS',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Table Content
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return _buildTableRow(item);
                        },
                      ),
                    ),

                    // Pagination
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Showing 1 to ${filteredItems.length} of ${items.length} results',
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                            ),
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: null,
                                child: const Text('Previous'),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '1',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text('2'),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text('3'),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text('Next'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String hint,
    List<String> items,
    String value,
    Function(String?) onChanged,
  ) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items:
              items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item, style: const TextStyle(fontSize: 14)),
                    ),
                  )
                  .toList(),
          onChanged: onChanged,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          isExpanded: true,
        ),
      ),
    );
  }

  Widget _buildTableRow(InventoryItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          Checkbox(
            value: false,
            onChanged: (value) {},
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    item.categoryIcon,
                    color: item.categoryColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        'ID: ${item.itemId}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.category,
                style: TextStyle(
                  color: item.categoryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                item.quantity.toString(),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child:
                item.assignedTo != null
                    ? Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: const Color(0xFF3B82F6),
                          child: Text(
                            item.assignedTo![0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.assignedTo!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                item.assignedToClass,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                    : const Text(
                      'Unassigned',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(item.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.status,
                style: TextStyle(
                  color: _getStatusColor(item.status),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility, size: 16),
                  color: const Color(0xFF6B7280),
                ),
                // IconButton(
                //   onPressed: () {},
                //   icon: const Icon(Icons.edit, size: 16),
                //   color: const Color(0xFF3B82F6),
                // ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_horiz, size: 16),
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(child: Text('Delete')),
                        const PopupMenuItem(child: Text('Duplicate')),
                      ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Assigned':
        return const Color(0xFF10B981);
      case 'Available':
        return const Color(0xFF3B82F6);
      case 'Due for Return':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
