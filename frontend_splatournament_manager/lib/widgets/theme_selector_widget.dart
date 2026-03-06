import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class ThemeSelectorWidget extends StatelessWidget {
  ThemeSelectorWidget({super.key});

  final List<DropdownMenuItem> dropdownElements = [
    DropdownMenuItem(
      value: ThemeMode.light,
      child: Text("Light"),
    ),
    DropdownMenuItem(
      value: ThemeMode.dark,
      child: Text("Dark"),
    ),
    DropdownMenuItem(
      value: ThemeMode.system,
      child: Text("System"),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).hoverColor, borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Theme"),
          SizedBox(
            width: 250,
            child: DropdownButtonFormField(
              icon: Icon(Icons.color_lens),
              items: dropdownElements,
              initialValue: themeProvider.theme,
              onChanged: (value) {
                if (value == null) return;
                themeProvider.setTheme(value);
              },
            ),
          ),
        ],
      ),
    );
  }

}