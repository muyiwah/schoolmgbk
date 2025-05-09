import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:schmgtsystem/Student/all_student.dart';
import 'package:schmgtsystem/Student/timetable.dart';
import 'package:schmgtsystem/deepseek/deepseek2222/exammodel.dart'
    show Exam, Option, Question;
import 'package:schmgtsystem/deepseek/deepseek2222/examsetupscreen.dart';
import 'package:schmgtsystem/deepseek/deepseek2222/ques_provider.dart';
import 'package:schmgtsystem/deepseek/deepseek2222/questiondata.dart';
import 'package:schmgtsystem/deepseek/deepseek2222/takeexam.dart';
import 'package:schmgtsystem/home.dart';
import 'package:schmgtsystem/custom_timetable.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => QuestionProvider())],
      child: MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  MyApp({super.key});

  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate, // 👈 REQUIRED
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // 👈 add any locales you support
        Locale('fr'),
        Locale('es'),
        // etc...
      ],
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 84, 66, 248),
        ),
      ),
      // home: const SchoolAdminDashboard(),
      // home: TakeExamScreen(exam: examdata),
      home: ExamSetupScreen(),
    );
  }
}
