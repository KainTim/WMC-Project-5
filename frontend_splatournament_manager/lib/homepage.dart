import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Splatournament"),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              context.go("/settings");
            },
            itemBuilder: (context) {
              return [PopupMenuItem(value: 1,child: Text("Settings"),)];
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [Text("Homepage")],
        ),
      ),
    );
  }
}
