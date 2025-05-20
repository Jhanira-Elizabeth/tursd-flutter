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
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatBot'),
        backgroundColor: const Color(0xFF007BFF), // Azul, moderno
        elevation: 0, // Sin sombra
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600, // Ligeramente más grueso
          fontSize: 20,
        ),
      ),
      body: Container(
        // Color de fondo para el cuerpo
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0F7FA), // Un azul muy claro
              Colors.white,
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
                            ? const Color(0xFF007BFF) // Azul para el usuario
                            : const Color(0xFFF8F9FA), // Gris muy claro para el bot
                        borderRadius: BorderRadius.circular(24), // Más redondeado
                        boxShadow: [
                          // Sutil sombra
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(
                          color: msg.isUser ? Colors.white : Colors.black87,
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
                color: Colors.white,
                boxShadow: [
                  // Sombra superior para separar la entrada
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
                        hintStyle: TextStyle(color: Colors.grey.shade600),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA), // Gris claro
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Botón de enviar
                  IconButton(
                    icon: const Icon(Icons.send,
                        color:
                            Color(0xFF007BFF)), // Azul de acento para el botón
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
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;

  _Message({required this.text, required this.isUser});
}
