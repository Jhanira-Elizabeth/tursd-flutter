import 'package:flutter/material.dart';

class BottomNavigationBarTuristico extends StatefulWidget {
  // onTabChange para notificar el cambio de tab
  final ValueChanged<int> onTabChange;
  final int currentIndex;

  const BottomNavigationBarTuristico({
    super.key,
    required this.onTabChange,
    required this.currentIndex,
  });

  @override
  _BottomNavigationBarTuristicoState createState() =>
      _BottomNavigationBarTuristicoState();
}

class _BottomNavigationBarTuristicoState
    extends State<BottomNavigationBarTuristico> {
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
          icon:
              Icon(Icons.favorite_border), // Icono de corazón vacío por defecto
          label: 'Favoritos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'ChatBot',
        ),
      ],
    );
  }
}
