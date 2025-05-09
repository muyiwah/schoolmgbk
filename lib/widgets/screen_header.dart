import 'package:flutter/material.dart';

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.group, required this.subgroup});
  final String group;
  final String subgroup;

  @override
  Widget build(BuildContext context) {
    return  Row(
      children: [
        Text(
         group,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        Spacer(),
        Text('Dashboard', style: TextStyle()),
        Text('   |  ', style: TextStyle()),
        Text(subgroup, style: TextStyle()),
      ],
    );
  }
}
