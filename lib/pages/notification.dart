import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class Notif extends StatefulWidget {
  const Notif({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NotifState();
  }
}

class NotifState extends State {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.end,
            children:const [
              TabBar(
                tabs: [
                  Tab(
                    child: Text("Notifications")
                  ),
                  Tab(
                    child: Text("Mentions")
                  )
                ],
              ),
            ]
          )
        ),
        body: TabBarView(
          children: [
            Container(
              child: Column(
                children: [
                  Text("normal notif"),
                ],
              )
            ),
            Container(
              child: Text("mention")
            )
          ],
        )
      )
    );
  }
}