import 'package:flutter/material.dart';

class CustomCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String? subtitle;
  final Function()? onTap;

  const CustomCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.onTap,
  }) : super(key: key);

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;
  late Animation<Offset> _positionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _elevationAnimation = Tween<double>(begin: 2, end: 6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -5.0 / 100),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: _positionAnimation.value * MediaQuery.of(context).size.height,
              child: Container(
                width: 181,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: _elevationAnimation.value * 2,
                      spreadRadius: _elevationAnimation.value / 3,
                      offset: Offset(0, _elevationAnimation.value / 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Imagen con tamaño fijo
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      child: Image.network(
                        widget.imageUrl,
                        width: 181,
                        height: 147,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 181,
                            height: 147,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.image_not_supported, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    // Contenido con altura dinámica
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFA3CF3D), // Color verde similar al de tu diseño
                            ),
                          ),
                          if (widget.subtitle != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                widget.subtitle!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Ejemplo de uso en un StatelessWidget
class CardExampleScreen extends StatelessWidget {
  const CardExampleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Turismo'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Alojamiento',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFA3CF3D),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  CustomCard(
                    imageUrl: 'https://via.placeholder.com/181x147',
                    title: 'Hotel Cariamanga',
                    onTap: () => print('Hotel Cariamanga seleccionado'),
                  ),
                  CustomCard(
                    imageUrl: 'https://via.placeholder.com/181x147',
                    title: 'Hotel Diana Real',
                    subtitle: 'Cómodo hotel en el centro de la ciudad',
                    onTap: () => print('Hotel Diana Real seleccionado'),
                  ),
                  CustomCard(
                    imageUrl: 'https://via.placeholder.com/181x147',
                    title: 'Grand Hotel Santander',
                    subtitle: 'Hotel con servicio completo y comodidades de lujo para una estancia perfecta. Incluye piscina, restaurante y hermosas vistas.',
                    onTap: () => print('Grand Hotel Santander seleccionado'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Atracciones',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFA3CF3D),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  CustomCard(
                    imageUrl: 'https://via.placeholder.com/181x147',
                    title: 'Balneario Turístico Apcaolii',
                    onTap: () => print('Balneario Turístico Apcaolii seleccionado'),
                  ),
                  CustomCard(
                    imageUrl: 'https://via.placeholder.com/181x147',
                    title: 'La Piedra del Gorila',
                    subtitle: 'Formación rocosa natural con forma única que atrae a visitantes de toda la región.',
                    onTap: () => print('La Piedra del Gorila seleccionado'),
                  ),
                  CustomCard(
                    imageUrl: 'https://via.placeholder.com/181x147',
                    title: 'Balneario Los Vegas de Julia Moreno',
                    subtitle: 'Refrescante balneario natural con aguas cristalinas, áreas para picnic y camping, ideal para disfrutar en familia.',
                    onTap: () => print('Balneario Los Vegas de Julia Moreno seleccionado'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}