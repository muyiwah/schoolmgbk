import 'package:flutter/material.dart';
import 'package:schmgtsystem/color_pallete.dart';
import 'package:schmgtsystem/widgets/custom_dropdown_select.dart';
import 'package:schmgtsystem/widgets/screen_header.dart';
import 'package:collection/collection.dart';

class CreateTimetale extends StatefulWidget {
  const CreateTimetale({super.key});

  @override
  State<CreateTimetale> createState() => _CreateTimetaleState();
}

class _CreateTimetaleState extends State<CreateTimetale> {
  int selectedTab = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: screenBackground,
        ),
        child: Column(
          children: [
            const ScreenHeader(
              group: 'Students',
              subgroup: 'Create Time Table',
            ),
            const SizedBox(height: 15),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(1, 1),
                      spreadRadius: 2,
                      blurRadius: 2,
                      color: Colors.transparent,
                    ),
                  ],
                  border: Border.all(color: Colors.white),
                ),
                padding: EdgeInsets.all(15),
                width: double.infinity,
                margin: EdgeInsets.all(5),

                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      children:
                          ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
                              .mapIndexed(
                                (i, e) => InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedTab = i;
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(horizontal: 6),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color:
                                          selectedTab == i
                                              ? homeColor.withOpacity(.8)
                                              : homeColor.withOpacity(.2),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      e,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color:
                                            selectedTab == i
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),

                    SizedBox(height: 20,),
                    Row(children: [

CustomDropdown(allValues: ['Yoruba','English','Physics','Chemistry','Biology','History'], title: 'Sunjects')

                    ]
                    
                    
                    ,)
                  ],
                ),
                
              ),
            ),
          ],
        ),
      ),
    );
  }
}
