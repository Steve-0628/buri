import 'package:flutter/material.dart';
import 'timeline.dart';
import 'notification.dart';


class MainWidget extends StatefulWidget {
  const MainWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MainState();
  }
}

class MainState extends State {
  int _currentIndex = 0;

  void onTap(int val){
    setState((){
      _currentIndex = val;
    });
  }
  
  @override
  Widget build(BuildContext context) {

    // print(widget.host);
    Set arg = ModalRoute.of(context)!.settings.arguments as Set;
    String host = arg.elementAt(0);
    String apiKey = arg.elementAt(1);

    List<Widget> bodyList = [
      Timeline(host: host, apiKey: apiKey,),
      const Notif(),
      ElevatedButton(onPressed: (){Navigator.pop(context);}, child: const Text("btn"),)
    ];
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: bodyList,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings")
        ],
      ),
    );
  }
}