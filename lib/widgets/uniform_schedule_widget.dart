import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/models/uniform_model.dart';
import 'package:schmgtsystem/providers/provider.dart';

class UniformScheduleWidget extends ConsumerStatefulWidget {
  final String classId;
  final String studentName;

  const UniformScheduleWidget({
    Key? key,
    required this.classId,
    required this.studentName,
  }) : super(key: key);

  @override
  ConsumerState<UniformScheduleWidget> createState() =>
      _UniformScheduleWidgetState();
}

class _UniformScheduleWidgetState extends ConsumerState<UniformScheduleWidget> {
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    // Load uniforms only once when widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoaded) {
        _hasLoaded = true;
        ref
            .read(RiverpodProvider.uniformProvider.notifier)
            .loadClassUniforms(widget.classId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final uniformState = ref.watch(RiverpodProvider.uniformProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[50]!, Colors.blue[100]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.blue[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.checkroom, color: Colors.blue[700], size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Uniform Schedule',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    Text(
                      'for ${widget.studentName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (uniformState.isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Uniform Schedule
          if (uniformState.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (uniformState.errorMessage != null)
            _buildErrorState(uniformState.errorMessage!)
          else if (uniformState.uniforms.isEmpty)
            _buildEmptyState()
          else
            _buildUniformSchedule(uniformState.uniforms),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unable to load uniform schedule',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  errorMessage,
                  style: TextStyle(fontSize: 14, color: Colors.red[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange[600], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No uniform schedule available',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Uniform schedule will be available once it\'s set up by the school administration.',
                  style: TextStyle(fontSize: 14, color: Colors.orange[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUniformSchedule(List<UniformModel> uniforms) {
    // Define the order of days
    const dayOrder = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    // Sort uniforms by day order
    final sortedUniforms =
        uniforms.toList()..sort(
          (a, b) => dayOrder.indexOf(a.day).compareTo(dayOrder.indexOf(b.day)),
        );

    return Column(
      children: [
        // Week header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Day',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
              Text(
                'Uniform Color',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Uniform list
        ...sortedUniforms.map((uniform) => _buildUniformItem(uniform)),
      ],
    );
  }

  Widget _buildUniformItem(UniformModel uniform) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Day
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getDayColor(uniform.day),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  uniform.day,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Uniform color
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _getUniformColor(uniform.uniform),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  uniform.uniform.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          // Uniform icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getUniformColor(uniform.uniform).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.checkroom,
              color: _getUniformColor(uniform.uniform),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDayColor(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return Colors.blue;
      case 'tuesday':
        return Colors.green;
      case 'wednesday':
        return Colors.orange;
      case 'thursday':
        return Colors.purple;
      case 'friday':
        return Colors.red;
      case 'saturday':
        return Colors.teal;
      case 'sunday':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  Color _getUniformColor(String uniform) {
    switch (uniform.toLowerCase()) {
      case 'white':
        return Colors.white;
      case 'black':
        return Colors.black;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'brown':
        return Colors.brown;
      case 'grey':
      case 'gray':
        return Colors.grey;
      default:
        return Colors.grey[400]!;
    }
  }
}
