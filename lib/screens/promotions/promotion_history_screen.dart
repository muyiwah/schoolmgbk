import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/models/promotion_model.dart';
import 'package:schmgtsystem/providers/promotion_provider.dart';
import 'package:schmgtsystem/services/global_academic_year_service.dart';

class PromotionHistoryScreen extends ConsumerStatefulWidget {
  const PromotionHistoryScreen({super.key});

  @override
  ConsumerState<PromotionHistoryScreen> createState() =>
      _PromotionHistoryScreenState();
}

class _PromotionHistoryScreenState
    extends ConsumerState<PromotionHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebounceTimer;

  // Filter states
  String _selectedAcademicYear = '';
  String _selectedSortBy = 'promotionDate';
  String _selectedSortOrder = 'desc';

  // Toggle for showing/hiding statistics and filters
  bool _showStatisticsAndFilters = true;

  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAcademicYear();
      _loadPromotionHistory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _loadAcademicYear() {
    final academicYearService = GlobalAcademicYearService();
    setState(() {
      _selectedAcademicYear = academicYearService.currentAcademicYearString;
    });
  }

  Future<void> _loadPromotionHistory({bool loadMore = false}) async {
    final pageToLoad = loadMore ? _currentPage + 1 : 1;

    await ref
        .read(promotionHistoryProvider.notifier)
        .getPromotionHistory(
          page: pageToLoad,
          limit: _itemsPerPage,
          academicYear:
              _selectedAcademicYear.isEmpty ? null : _selectedAcademicYear,
          sortBy: _selectedSortBy,
          sortOrder: _selectedSortOrder,
        );

    if (loadMore) {
      setState(() {
        _currentPage++;
        _isLoadingMore = false;
      });
    }
  }

  void _onSearchChanged() {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _loadPromotionHistory();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoadingMore) {
        setState(() {
          _isLoadingMore = true;
        });
        _loadPromotionHistory(loadMore: true);
      }
    }
  }

  // void _onFilterChanged() {
  //   _loadPromotionHistory();
  // }

  void _onAcademicYearChanged(String? value) {
    setState(() {
      _selectedAcademicYear = value ?? '';
    });
    _loadPromotionHistory();
  }

  void _onSortChanged(String? value) {
    setState(() {
      _selectedSortBy = value ?? 'promotionDate';
    });
    _loadPromotionHistory();
  }

  void _onSortOrderChanged(String? value) {
    setState(() {
      _selectedSortOrder = value ?? 'desc';
    });
    _loadPromotionHistory();
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(promotionHistoryProvider);
    final promotions = historyState.promotions;
    final pagination = historyState.pagination;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Promotion History',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'View and track all student promotion activities',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
                // Toggle Statistics and Filters Button
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showStatisticsAndFilters = !_showStatisticsAndFilters;
                    });
                  },
                  icon: Icon(
                    _showStatisticsAndFilters
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color:
                        _showStatisticsAndFilters
                            ? Colors.white
                            : Color(0xFF64748B),
                    size: 18,
                  ),
                  label: Text(
                    _showStatisticsAndFilters ? 'Hide Cards' : 'Show Cards',
                    style: TextStyle(
                      color:
                          _showStatisticsAndFilters
                              ? Colors.white
                              : Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _showStatisticsAndFilters
                            ? Color(0xFF64748B)
                            : Colors.grey[100],
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: _showStatisticsAndFilters ? 2 : 0,
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => context.go('/promotions'),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  label: const Text(
                    'Back to Promotions',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Scrollable content
            Expanded(
              child:
                  _showStatisticsAndFilters
                      ? SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Statistics Cards
                            _buildStatisticsCards(promotions, pagination),
                            const SizedBox(height: 32),

                            // Search and Filters
                            _buildSearchAndFilters(),
                            const SizedBox(height: 24),

                            // Filter Status Indicator
                            _buildFilterStatusIndicator(),
                            const SizedBox(height: 24),

                            // Data Table
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: _buildPromotionsTable(
                                promotions,
                                historyState.isLoading,
                                historyState.errorMessage,
                              ),
                            ),
                          ],
                        ),
                      )
                      : Column(
                        children: [
                          // Data Table (expanded to fill space)
                          Expanded(
                            child: _buildPromotionsTable(
                              promotions,
                              historyState.isLoading,
                              historyState.errorMessage,
                            ),
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(
    List<PromotionModel> promotions,
    PaginationInfo? pagination,
  ) {
    final totalPromoted = promotions.fold(0, (sum, p) => sum + p.promotedCount);
    final totalRepeated = promotions.fold(0, (sum, p) => sum + p.repeatedCount);
    final totalGraduated = promotions.fold(
      0,
      (sum, p) => sum + p.graduatedCount,
    );

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total Records',
            value: pagination?.totalRecords.toString() ?? '0',
            icon: Icons.history,
            color: const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Promoted',
            value: totalPromoted.toString(),
            icon: Icons.arrow_upward,
            color: const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Repeated',
            value: totalRepeated.toString(),
            icon: Icons.refresh,
            color: const Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Graduated',
            value: totalGraduated.toString(),
            icon: Icons.school,
            color: const Color(0xFF8B5CF6),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // First Row - Search and Basic Filters
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => _onSearchChanged(),
                  decoration: InputDecoration(
                    hintText: 'Search by academic year or student name...',
                    hintStyle: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Color(0xFF94A3B8),
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged();
                              },
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Color(0xFF6366F1)),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              SizedBox(
                width: 200,
                child: _buildFilterDropdown(
                  value: _selectedAcademicYear,
                  items: [
                    DropdownMenuItem(value: '', child: Text('All Years')),
                    DropdownMenuItem(
                      value: _selectedAcademicYear,
                      child: Text(_selectedAcademicYear),
                    ),
                  ],
                  onChanged: _onAcademicYearChanged,
                ),
              ),
              SizedBox(width: 12),
              SizedBox(
                width: 150,
                child: _buildFilterDropdown(
                  value: _selectedSortBy,
                  items: [
                    DropdownMenuItem(
                      value: 'promotionDate',
                      child: Text('Sort by Date'),
                    ),
                    DropdownMenuItem(
                      value: 'academicYear',
                      child: Text('Sort by Year'),
                    ),
                    DropdownMenuItem(
                      value: 'totalStudents',
                      child: Text('Sort by Count'),
                    ),
                  ],
                  onChanged: _onSortChanged,
                ),
              ),
              SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: _buildFilterDropdown(
                  value: _selectedSortOrder,
                  items: [
                    DropdownMenuItem(value: 'desc', child: Text('Descending')),
                    DropdownMenuItem(value: 'asc', child: Text('Ascending')),
                  ],
                  onChanged: _onSortOrderChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButton<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        underline: SizedBox(),
        icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF94A3B8)),
        isExpanded: true,
        style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
      ),
    );
  }

  Widget _buildFilterStatusIndicator() {
    final activeFilters = <String>[];

    if (_selectedAcademicYear.isNotEmpty) {
      activeFilters.add('Year: $_selectedAcademicYear');
    }
    if (_selectedSortBy != 'promotionDate') {
      activeFilters.add('Sort: $_selectedSortBy');
    }
    if (_selectedSortOrder != 'desc') {
      activeFilters.add('Order: $_selectedSortOrder');
    }
    if (_searchController.text.isNotEmpty) {
      activeFilters.add('Search: ${_searchController.text}');
    }

    if (activeFilters.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            activeFilters
                .map(
                  (filter) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Color(0xFF6366F1).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          filter,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            if (filter.startsWith('Year:')) {
                              _onAcademicYearChanged('');
                            } else if (filter.startsWith('Sort:')) {
                              _onSortChanged('promotionDate');
                            } else if (filter.startsWith('Order:')) {
                              _onSortOrderChanged('desc');
                            } else if (filter.startsWith('Search:')) {
                              _searchController.clear();
                              _onSearchChanged();
                            }
                          },
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildPromotionsTable(
    List<PromotionModel> promotions,
    bool isLoading,
    String? errorMessage,
  ) {
    if (isLoading) {
      return Container(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF6366F1)),
        ),
      );
    }

    if (errorMessage != null) {
      return Container(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
              SizedBox(height: 16),
              Text(
                'Error loading promotion history: $errorMessage',
                style: TextStyle(color: Color(0xFFEF4444), fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPromotionHistory,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (promotions.isEmpty) {
      return Container(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.history, color: Color(0xFF94A3B8), size: 48),
              SizedBox(height: 16),
              Text(
                'No promotion history found',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: _buildHeaderCell('ACADEMIC YEAR')),
                Expanded(flex: 1, child: _buildHeaderCell('DATE')),
                Expanded(flex: 1, child: _buildHeaderCell('PROMOTED')),
                Expanded(flex: 1, child: _buildHeaderCell('REPEATED')),
                Expanded(flex: 1, child: _buildHeaderCell('GRADUATED')),
                Expanded(flex: 1, child: _buildHeaderCell('TOTAL')),
                SizedBox(width: 100, child: _buildHeaderCell('ACTIONS')),
              ],
            ),
          ),
          // Promotion Rows
          Expanded(
            child: ListView.builder(
              itemCount: promotions.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == promotions.length) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                final promotion = promotions[index];
                return _buildPromotionRow(promotion, index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title) {
    return Text(
      title,
      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
    );
  }

  Widget _buildPromotionRow(PromotionModel promotion, int rowNumber) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          // Academic Year
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promotion.academicYear,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                SizedBox(height: 2),
                Text(
                  '${promotion.promotions.length} students',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          // Date
          Expanded(
            flex: 1,
            child: Text(
              '${promotion.promotionDate.day}/${promotion.promotionDate.month}/${promotion.promotionDate.year}',
              style: TextStyle(fontSize: 14),
            ),
          ),
          // Promoted
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                promotion.promotedCount.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF10B981),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Repeated
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFFF59E0B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                promotion.repeatedCount.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFF59E0B),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Graduated
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFF8B5CF6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                promotion.graduatedCount.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8B5CF6),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Total
          Expanded(
            flex: 1,
            child: Text(
              promotion.totalStudents.toString(),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          // Actions
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size(0, 0),
                  ),
                  onPressed: () => _showPromotionDetails(promotion),
                  child: Text('View', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPromotionDetails(PromotionModel promotion) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Promotion Details - ${promotion.academicYear}'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: ListView.builder(
                itemCount: promotion.promotions.length,
                itemBuilder: (context, index) {
                  final item = promotion.promotions[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(
                        item.status,
                      ).withOpacity(0.1),
                      child: Icon(
                        _getStatusIcon(item.status),
                        color: _getStatusColor(item.status),
                        size: 20,
                      ),
                    ),
                    title: Text(item.studentName),
                    subtitle: Text(
                      '${item.admissionNumber} • ${item.fromClassName}',
                    ),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(item.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _getStatusColor(item.status),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'promoted':
        return Color(0xFF10B981);
      case 'repeated':
        return Color(0xFFF59E0B);
      case 'graduated':
        return Color(0xFF8B5CF6);
      default:
        return Color(0xFF64748B);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'promoted':
        return Icons.arrow_upward;
      case 'repeated':
        return Icons.refresh;
      case 'graduated':
        return Icons.school;
      default:
        return Icons.info;
    }
  }
}
