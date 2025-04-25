import 'package:flutter/material.dart';
import 'dart:async';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Mensaje de bienvenida
    _addBotMessage("¡Hola! Soy tu asistente turístico. ¿En qué puedo ayudarte hoy? Puedes preguntarme sobre atracciones, alojamiento, restaurantes o actividades en Santo Domingo.");
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    
    // Añadir mensaje del usuario
    ChatMessage userMessage = ChatMessage(
      text: text,
      isUser: true,
    );
    
    setState(() {
      _messages.add(userMessage);
      _isTyping = true; // Mostrar indicador de "escribiendo..."
    });
    
    _scrollToBottom();
    
    // Simular respuesta del bot después de un breve retraso
    Timer(Duration(milliseconds: 800), () {
      _getBotResponse(text);
    });
  }

  void _getBotResponse(String userMessage) {
    String botResponse = "";
    userMessage = userMessage.toLowerCase();
    
    // Lógica básica para respuestas
    if (userMessage.contains("hola") || userMessage.contains("saludos")) {
      botResponse = "¡Hola! ¿En qué puedo ayudarte hoy?";
    } 
    else if (userMessage.contains("atraccion") || userMessage.contains("visitar")) {
      botResponse = "Santo Domingo tiene muchas atracciones interesantes. Te recomiendo visitar la cultura Tsáchila, el Parque Zaracay, o dar un paseo por el Jardín Botánico. ¿Te gustaría más información sobre alguno de estos lugares?";
    } 
    else if (userMessage.contains("hotel") || userMessage.contains("alojamiento") || userMessage.contains("hospedaje")) {
      botResponse = "Tenemos excelentes opciones de alojamiento. El Hotel Diana Real y el Grand Hotel Santander son muy populares. ¿Necesitas información sobre precios o ubicación?";
    } 
    else if (userMessage.contains("restaurante") || userMessage.contains("comer") || userMessage.contains("comida")) {
      botResponse = "La gastronomía local es deliciosa. Prueba mariscos en 'Oh Que Rico' o platos típicos en 'Parrilladas'. ¿Buscas algún tipo específico de comida?";
    } 
    else if (userMessage.contains("rio") || userMessage.contains("baño") || userMessage.contains("nadar")) {
      botResponse = "El río San Gabriel y el Balneario Las Vegas de Julio Moreno son excelentes opciones para refrescarse. También está el Balneario Apócali para una experiencia completa con actividades recreativas.";
    } 
    else if (userMessage.contains("parroquia")) {
      botResponse = "Las principales parroquias incluyen Valle Hermoso, San José de Alluriquín, Luz de América, El Esfuerzo, y Santa María del Toachi. Cada una tiene su encanto particular. ¿Sobre cuál te gustaría saber más?";
    } 
    else if (userMessage.contains("gracias")) {
      botResponse = "¡De nada! Estoy aquí para ayudarte con cualquier otra duda sobre turismo en Santo Domingo.";
    } 
    else {
      botResponse = "Lo siento, no tengo información específica sobre eso. ¿Puedo ayudarte con información sobre atracciones turísticas, alojamiento, restaurantes o actividades en Santo Domingo?";
    }
    
    _addBotMessage(botResponse);
  }

  void _addBotMessage(String text) {
    ChatMessage botMessage = ChatMessage(
      text: text,
      isUser: false,
    );
    
    setState(() {
      _isTyping = false;
      _messages.add(botMessage);
    });
    
    _scrollToBottom();
  }

  void _scrollToBottom() {
    // Asegurarse de que el scroll baje al último mensaje
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asistente Turístico'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Color(0xFFF5F5F5),
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(8.0),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (_, int index) {
                  if (index == _messages.length) {
                    // Mostrar indicador de "escribiendo..."
                    return Container(
                      margin: EdgeInsets.only(left: 16, bottom: 16),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF9DAF3A)),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text("Escribiendo..."),
                        ],
                      ),
                    );
                  }
                  return _messages[index];
                },
              ),
            ),
          ),
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: _buildTextComposer(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chatbot',
            backgroundColor: Color(0xFF9DAF3A),
          ),
        ],
        currentIndex: 2,
        selectedItemColor: Color(0xFF9DAF3A),
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/mapa');
          }
        },
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration: InputDecoration(
                hintText: "Escribe tu pregunta...",
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Color(0xFF9DAF3A)),
            onPressed: () {
              if (_textController.text.trim().isNotEmpty) {
                _handleSubmitted(_textController.text);
              }
            },
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: Color(0xFF9DAF3A),
              child: Icon(Icons.assistant, color: Colors.white),
            ),
            SizedBox(width: 8.0),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isUser ? Color(0xFF9DAF3A) : Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          if (isUser) SizedBox(width: 8.0),
        ],
      ),
    );
  }
}