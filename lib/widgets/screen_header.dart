import 'package:flutter/material.dart';
import 'package:schmgtsystem/widgets/custom_dropdown_select.dart';

class ScreenHeader extends StatelessWidget {
   ScreenHeader({
    super.key,
    required this.group,
    required this.subgroup,
    this.showSearchBar = false,
    this.showDropdown=false,
  });
  final String group;
  final String subgroup;
  final bool showSearchBar;
  final bool showDropdown;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          group,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        Spacer(),
        if(showDropdown)
          CustomDropdown(
            allValues: const [
              'Grade1',
              'Grade2',
              'Grade3',
              'Grade4',
              'Grade5',
              'Grade6',
              'Grade7',
              'Grade8',
              'Grade9',
              
            ],
            title: 'Select Class',
            onChanged: (value) => print('Selected role: $value'),
          ),SizedBox(width: 12,),
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
