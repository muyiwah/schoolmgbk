import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schmgtsystem/deepseek/deepseek2222/exammodel.dart'
    show Exam, Option, Question;

import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:schmgtsystem/home3.dart';
import 'package:schmgtsystem/login_screen.dart';
import 'package:schmgtsystem/utils/locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  configLoading();

  runApp(ProviderScope(child: MyApp()));
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = Duration(seconds: 3)
    ..loadingStyle = EasyLoadingStyle.light
    ..maskType = EasyLoadingMaskType.black
    ..indicatorSize = 20.0
    ..radius = 10.0
    ..contentPadding = EdgeInsets.all(28.0)
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      child: StyledToast(
        locale: Locale('en', 'US'),
        toastAnimation: StyledToastAnimation.fadeScale,
        reverseAnimation: StyledToastAnimation.fade,
        toastPositions: StyledToastPosition.top,
        animDuration: Duration(milliseconds: 300),
        duration: Duration(seconds: 3),
        fullWidth: false,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
        dismissOtherOnShow: true,
        child: MaterialApp.router(
          routerConfig: router, // Use the simple router directly
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            FlutterQuillLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('fr'), Locale('es')],
          title: 'LoveSpring Dashboard',
          theme: ThemeData(
            cardTheme: CardThemeData(
              color: Colors.blue,
              surfaceTintColor: Colors.blue,
              shadowColor: Colors.blue,
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          builder: EasyLoading.init(
            builder: (context, child) {
              final scale = MediaQuery.of(
                context,
              ).textScaler.clamp(minScaleFactor: 0.85, maxScaleFactor: 0.95);
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: scale),
                child: child!,
              );
            },
          ),
        ),
      ),
    );
  }
}
