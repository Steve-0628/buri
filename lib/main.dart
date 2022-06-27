import 'package:flutter/material.dart';
import 'pages/welcome.dart';
import 'pages/main.dart';
import 'pages/note.dart';

void main() {
  runApp(const Buri());
}

class Buri extends StatelessWidget {
  const Buri({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buri Beta',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => const Welcome(),
        "/main": (context) => MainWidget(),
        "/note": (context) => CreateNote(),
      },
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

