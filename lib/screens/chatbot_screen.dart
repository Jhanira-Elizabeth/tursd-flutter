import 'package:flutter/material.dart';
import 'package:tursd/widgets/bottom_navigation_bar_turistico.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<_Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    // Agrega el mensaje de bienvenida al inicio
    _messages.add(_Message(
      text: "Hola viajero! ¿Qué quieres saber hoy?",
      isUser: false,
    ));
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _messages.add(_Message(text: _generateBotReply(text), isUser: false));
    });

    _controller.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  String _generateBotReply(String userText) {
    // Simula una respuesta del bot
    return "Tú dijiste: \"$userText\".  Aquí tienes información relevante.";
  }

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/mapa');
          break;
        case 2: // Favoritos
          Navigator.pushReplacementNamed(context, '/favoritos');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/chatbot');
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Define colores basados en el modo oscuro/claro
    final appBarColor = isDarkMode ? const Color(0xFF1A237E) : const Color(0xFF007BFF); // Azul oscuro para dark, azul brillante para light
    final backgroundColor = isDarkMode ? Colors.grey[900] : const Color(0xFFE0F7FA); // Fondo oscuro para dark, claro para light
    final backgroundGradientEndColor = isDarkMode ? Colors.grey[850] : Colors.white;
    final userMessageColor = isDarkMode ? const Color(0xFF42A5F5) : const Color(0xFF007BFF); // Azul más suave para dark, brillante para light
    final botMessageColor = isDarkMode ? Colors.grey[700] : const Color(0xFFF8F9FA); // Gris oscuro para dark, muy claro para light
    final userTextColor = Colors.white; // Texto del usuario siempre blanco
    final botTextColor = isDarkMode ? Colors.white : Colors.black87; // Texto del bot blanco para dark, oscuro para light
    final inputContainerColor = isDarkMode ? Colors.grey[800] : Colors.white; // Fondo de la barra de entrada
    final inputFillColor = isDarkMode ? Colors.grey[750] : const Color(0xFFF8F9FA); // Fondo del TextField
    final hintTextColor = isDarkMode ? Colors.grey[400] : Colors.grey.shade600; // Color del hint text
    final sendButtonColor = isDarkMode ? const Color(0xFF42A5F5) : const Color(0xFF007BFF); // Color del botón de enviar
    final boxShadowColor = isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1);


    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatBot'),
        backgroundColor: appBarColor, // Adaptar el color de la AppBar
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundColor!, // Usa el color de fondo adaptado
              backgroundGradientEndColor!, // Usa el color de fin del gradiente adaptado
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return Align(
                    alignment: msg.isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: msg.isUser
                            ? userMessageColor // Color de mensaje de usuario adaptado
                            : botMessageColor, // Color de mensaje de bot adaptado
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: boxShadowColor, // Color de sombra adaptado
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(
                          color: msg.isUser
                              ? userTextColor
                              : botTextColor, // Color de texto adaptado
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Área de entrada de mensajes
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: inputContainerColor, // Color de la barra de entrada adaptado
                boxShadow: [
                  BoxShadow(
                    color: boxShadowColor, // Color de sombra adaptado
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: _sendMessage,
                      decoration: InputDecoration(
                        hintText: 'Escribe tu mensaje...',
                        hintStyle: TextStyle(color: hintTextColor), // Color del hint text adaptado
                        filled: true,
                        fillColor: inputFillColor, // Color del fondo del TextField adaptado
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      style: TextStyle(color: botTextColor), // Color del texto del TextField adaptado
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Botón de enviar
                  IconButton(
                    icon: Icon(Icons.send, color: sendButtonColor), // Color del botón de enviar adaptado
                    onPressed: () => _sendMessage(_controller.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBarTuristico(
        currentIndex: _currentIndex,
        onTabChange: _onTabChange,
        // Assuming BottomNavigationBarTuristico also adapts to dark mode internally
        // or you would need to pass theme-related properties to it.
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;

  _Message({required this.text, required this.isUser});
}