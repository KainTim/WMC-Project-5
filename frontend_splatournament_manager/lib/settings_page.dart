import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static const List<String> themes = ['System', 'Dark', 'Light'];

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var dropDownValue = SettingsPage.themes[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Splatournament")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Settings"),
            DropdownButton(
              value: dropDownValue,
              icon: Icon(Icons.color_lens),
              items: SettingsPage.themes
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value){
                if(value == null) return;
                print(value);
                setState(() {
                  dropDownValue = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
