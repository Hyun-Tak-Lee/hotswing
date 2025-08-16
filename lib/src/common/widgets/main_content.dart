import 'package:flutter/material.dart';

class MainContent extends StatelessWidget {
  const MainContent({super.key, required this.isMobileSize});

  final bool isMobileSize;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Content'),
        ],
      ),
    );
  }
}
