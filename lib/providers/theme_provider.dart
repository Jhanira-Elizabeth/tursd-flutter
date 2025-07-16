import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  // Cargar el tema guardado de SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false; // Valor por defecto: claro
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Notifica a los listeners después de cargar el tema
  }

  // Alternar el tema y guardarlo
  void toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
    notifyListeners(); // Notifica a los listeners sobre el cambio
  }

  // Definir tus temas
  static ThemeData lightTheme() {
    return ThemeData(
      primaryColor: const Color.fromARGB(255, 80, 18, 215),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 80, 18, 215),
        primary: const Color.fromARGB(255, 80, 18, 215),
        background: const Color.fromARGB(255, 255, 255, 255), // Fondo de scaffold
        surface: const Color.fromARGB(255, 240, 240, 240), // Color para Card, Dialogs, etc.
        onSurface: Colors.black, // Color de texto sobre surface
        // Puedes añadir más colores específicos para tu app
      ),
      scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF4A3C30), // Abano (aproximado)
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        selectedIconTheme: IconThemeData(color: Colors.black),
        unselectedIconTheme: IconThemeData(color: Colors.black),
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black),
        bodyMedium: TextStyle(color: Colors.black),
        // Define más estilos de texto si es necesario
      ),
      // Colores para Chips
      chipTheme: ChipThemeData(
        backgroundColor: Color(0xFFE0E6B8),
        labelStyle: TextStyle(color: Color(0xFF9DAF3A)),
        selectedColor: Color(0xFF9DAF3A), // Color cuando el chip está seleccionado
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      primaryColor: const Color.fromARGB(255, 150, 100, 255), // Un primary color oscuro
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 150, 100, 255),
        primary: const Color.fromARGB(255, 150, 100, 255),
        background: const Color.fromARGB(255, 30, 30, 30), // Fondo de scaffold oscuro
        surface: const Color.fromARGB(255, 50, 50, 50), // Color para Card, Dialogs, etc. oscuro
        onSurface: Colors.white, // Color de texto sobre surface
        brightness: Brightness.dark, // Indica que es un tema oscuro
      ),
      scaffoldBackgroundColor: const Color.fromARGB(255, 30, 30, 30),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 50, 50, 50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF201B18), // Un Abano más oscuro
        selectedItemColor: Color(0xFFE0E6B8), // Un color más claro para el item seleccionado
        unselectedItemColor: Colors.grey,
        selectedIconTheme: IconThemeData(color: Color(0xFFE0E6B8)),
        unselectedIconTheme: IconThemeData(color: Colors.grey),
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        // Define más estilos de texto si es necesario
      ),
      // Colores para Chips en modo oscuro
      chipTheme: ChipThemeData(
        backgroundColor: Color.fromARGB(255, 70, 70, 70), // Fondo más oscuro para chips
        labelStyle: TextStyle(color: Colors.white), // Texto blanco
        selectedColor: Color(0xFFE0E6B8), // Color cuando el chip está seleccionado
      ),
    );
  }
}