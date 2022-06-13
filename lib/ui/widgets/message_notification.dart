import 'package:flutter/material.dart';

class MessageNotification extends StatelessWidget {
  final VoidCallback onReplay;
  final String title;
  final String body;

  const MessageNotification(this.title, this.body, {required this.onReplay});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: SafeArea(
        child: ListTile(
//          leading: SizedBox.fromSize(
//              size: const Size(40, 40),
//              child: ClipOval(child: Image.asset('assets/avatar.png'))),
          title: Text(title),
          subtitle: Text(body),
          trailing: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
 onReplay();
              }),
        ),
      ),
    );
  }
}
