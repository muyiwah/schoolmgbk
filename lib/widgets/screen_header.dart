import 'package:flutter/material.dart';

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.group,
    required this.subgroup,
    this.showSearchBar = false,
  });
  final String group;
  final String subgroup;
  final bool showSearchBar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          group,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        Spacer(),
        if (showSearchBar)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            margin: EdgeInsets.only(right: 40),
            width: 320,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                border: InputBorder.none,
              ),
            ),
          ),
        Text('Dashboard', style: TextStyle()),

        Text('   |  ', style: TextStyle()),
        Text(subgroup, style: TextStyle()),
      ],
    );
  }
}
