import 'package:flutter/material.dart';
import 'package:schmgtsystem/widgets/piechart.dart';
import 'package:schmgtsystem/widgets/screen_header.dart';

class SingleStudent extends StatelessWidget {
  const SingleStudent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // ScreenHeader(group: 'Student', subgroup: 'single student'),
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Container(
                    margin: EdgeInsets.only(right: 10),

                    height: 350,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          width: double.infinity,
                          height: 160,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.purple,
                                Color.fromARGB(255, 97, 11, 137),
                                // Color.fromARGB(255, 52, 1, 91),
                              ],
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 65,
                                child: Icon(Icons.person),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    'Jessie Rose',
                                    style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        ' No6, ojoo, ibadan',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w200,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Flexible(
                                    child: SizedBox(
                                      width: 350,
                                      child: Text(
                                        'lorem as asdf asdf asdf adf asdf asdf asdf asdf asdf asdfasdf asdf asdf asdf asdf asdfas dfas dfa sdf asdf asdf asdf',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w200,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: .5,
                                  ),
                                ),
                                child: Text(
                                  'View Full Profile',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomBox(),
                            CustomBox(),
                            CustomBox(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),SizedBox(width: 10,),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    height: 350,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Text('Attendance'), Icon(Icons.settings)],
                        ),
                        CustomPieChart(
                          spiritual: 40,
                          education: 6,
                          social: 8,
                          identity: 52,
                        ),
                        Row(
                          children: [
                            Container(
                              height: 15,
                              width: 15,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.purple,
                              ),
                            ),
                            Text(
                              '  Present',
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              ' 70%',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Spacer(),
                            Container(
                              height: 15,
                              width: 15,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.amber,
                              ),
                            ),
                            Text(
                              '  Absent',
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              ' 30%',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container CustomBox() {
    return Container(
                        padding: EdgeInsets.all(16),
                        height: 180,
                        width: 180,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: Colors.purpleAccent.withOpacity(
                                      .3,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.headset,
                                    color: Colors.purpleAccent,
                                    size: 16,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Row(
                                  children: [
                                    Text(
                                      '12',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                Text(
                                  ' this month',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                                  ],
                                ),
                              ],
                            ),Spacer(),
                            Text(
                              'Notification',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),SizedBox(height: 8,),
                            Text(
                              'Your school activities are store here, please check it',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                          ],
                        ),
                      );
  }
}
