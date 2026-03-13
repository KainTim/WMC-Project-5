import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class ThemeSelectorWidget extends StatelessWidget {
  ThemeSelectorWidget({super.key});

  final List<DropdownMenuItem<AppThemeOption>> dropdownElements = [
    const DropdownMenuItem(
      value: AppThemeOption.lightBlue,
      child: Text('Helles Blau'),
    ),
    const DropdownMenuItem(
      value: AppThemeOption.darkPurple,
      child: Text('Dunkles Lila'),
    ),
    const DropdownMenuItem(
      value: AppThemeOption.lightMint,
      child: Text('Helles Mint'),
    ),
    const DropdownMenuItem(
      value: AppThemeOption.darkAmber,
      child: Text('Dunkles Bernstein'),
    ),
    const DropdownMenuItem(value: AppThemeOption.system, child: Text('System')),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).hoverColor,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Design'),
          SizedBox(
            width: 250,
            child: DropdownButtonFormField<AppThemeOption>(
              icon: const Icon(Icons.color_lens),
              items: dropdownElements,
              initialValue: themeProvider.selectedTheme,
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
