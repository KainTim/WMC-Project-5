import 'package:flutter/material.dart';

class TournamentDetailPage extends StatelessWidget {
  const TournamentDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tournament"),),
      body: Center(child: Text("Detail"),)
    );
  }

}