import 'package:flutter/material.dart';

class BottomNavigationBarTuristico extends StatefulWidget {
  final ValueChanged<int> onTabChange; // Callback para notificar el cambio de tab
  final int currentIndex;

  const BottomNavigationBarTuristico({
    super.key,
    required this.onTabChange,
    required this.currentIndex,
  });

  @override
  _BottomNavigationBarTuristicoState createState() => _BottomNavigationBarTuristicoState();
}

class _BottomNavigationBarTuristicoState extends State<BottomNavigationBarTuristico> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: (index) {
        widget.onTabChange(index);
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Mapa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'ChatBot',
        ),
      ],
    );
  }
}