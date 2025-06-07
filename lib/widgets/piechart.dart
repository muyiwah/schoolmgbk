import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CustomPieChart extends StatefulWidget {
  CustomPieChart({
    super.key,
    required this.spiritual,
    required this.education,
    required this.social,
    required this.identity,
  });
  final int spiritual;
  final int education;
  final int social;
  final int identity;
  @override
  State<CustomPieChart> createState() => _WholenessChartState();
}

class _WholenessChartState extends State<CustomPieChart> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

 
  int identity = 1;
  int education = 1;
  int social = 1;
  int spiritual = 1;
  int identityGrey = 24;
  int educationGrey = 24;
  int socialGrey = 24;
  int spiritualGrey = 24;
 

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 270,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: PieChart(
          swapAnimationDuration: Duration(milliseconds: 700),
          swapAnimationCurve: Curves.easeIn,
          PieChartData(
            sections: [
              PieChartSectionData(
                value: identity.toDouble(),
                color: Colors.red,
                radius: 55,
                showTitle: true,
                titleStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              PieChartSectionData(
                value: identityGrey.toDouble(),
                color: Colors.grey.withOpacity(.3),
                radius: 35,
                showTitle: false,
                titleStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              PieChartSectionData(
                value: social.toDouble(),
                color: Colors.blue,
                radius: 35,
                showTitle: false,
                titleStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              PieChartSectionData(
                value: socialGrey.toDouble(),
                color: Colors.grey.withOpacity(.3),
                radius: 35,
                showTitle: false,
                titleStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              PieChartSectionData(
                value: spiritual.toDouble(),
                color: Colors.green,
                radius: 35,
                showTitle: false,
                titleStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              PieChartSectionData(
                value: spiritualGrey.toDouble(),
                color: Colors.grey.withOpacity(.3),
                radius: 35,
                showTitle: false,
                titleStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              // PieChartSectionData(
              //   value: education.toDouble(),
              //   color: Colors.amber,
              //   radius: 35,
              //   showTitle: false,
              //   titleStyle: TextStyle(
              //     color: Colors.white,
              //     fontSize: 10,
              //     fontWeight: FontWeight.w700,
              //   ),
              // ),
              // PieChartSectionData(
              //   value: educationGrey.toDouble(),
              //   showTitle: false,
              //   color: Colors.grey.withOpacity(.3),
              //   radius: 35,
              //   titleStyle: TextStyle(
              //     color: Colors.white,
              //     fontSize: 10,
              //     fontWeight: FontWeight.w700,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
