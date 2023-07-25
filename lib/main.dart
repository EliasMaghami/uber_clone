import 'package:flutter/material.dart';
import 'package:snap_simple/constant/dimens.dart';
import 'package:snap_simple/screen/map_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MapScreen(),
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            fixedSize:
                const MaterialStatePropertyAll(Size(double.infinity, 58)),
            shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimens.medium),
              ),
            ),
            elevation: const MaterialStatePropertyAll(0),
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return const Color.fromARGB(255, 6, 117, 24);
              }
              return const Color.fromARGB(255, 2, 207, 36);
            }),
          ),
        ),
      ),
    );
  }
}
