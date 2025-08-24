import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schmgtsystem/screens/Student/all_student.dart';
import 'package:schmgtsystem/screens/Student/timetable.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/deepseek/deepseek2222/exammodel.dart'
    show Exam, Option, Question;
import 'package:schmgtsystem/deepseek/deepseek2222/examsetupscreen.dart';
import 'package:schmgtsystem/providers/ques_provider.dart';
import 'package:schmgtsystem/deepseek/deepseek2222/questiondata.dart';
import 'package:schmgtsystem/deepseek/deepseek2222/takeexam.dart';
import 'package:schmgtsystem/home.dart';
import 'package:schmgtsystem/custom_timetable.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:schmgtsystem/home2.dart';
import 'package:schmgtsystem/home3.dart';
import 'package:schmgtsystem/login_screen.dart';
import 'package:schmgtsystem/providers/user_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuestionProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          FlutterQuillLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('fr'), Locale('es')],
        title: 'Flutter Demo',
        theme: ThemeData(
          cardTheme: CardThemeData(color: Colors.blue,surfaceTintColor: Colors.blue ,shadowColor: Colors.blue,
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          textTheme: GoogleFonts.montserratTextTheme(
            Theme.of(context).textTheme,
          ),
          popupMenuTheme: PopupMenuThemeData(color: Colors.white),
          dropdownMenuTheme: DropdownMenuThemeData(
            menuStyle: MenuStyle(
              backgroundColor: MaterialStateProperty.all(Colors.white),
              shadowColor: MaterialStateProperty.all(Colors.grey),
              surfaceTintColor: MaterialStateProperty.all(Colors.white),
              elevation: MaterialStateProperty.all(4),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        home: const OakwoodLoginScreen(),
      ),
    );
  }
}
