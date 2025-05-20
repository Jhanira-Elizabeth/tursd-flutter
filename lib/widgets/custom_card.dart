import 'package:flutter/material.dart';
import 'package:tursd/services/favorite_service.dart'; // Importa el FavoriteService

class CustomCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String? subtitle;
  final Function()? onTap;
  final int puntoTuristicoId; // Añade el ID del punto turístico

  const CustomCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.onTap,
    required this.puntoTuristicoId, // Requiere el ID
  });

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;
  late Animation<Offset> _positionAnimation;
  final FavoriteService _favoriteService = FavoriteService(); // Instancia el servicio
  bool _isFavorite = false; // Estado local para el icono

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _elevationAnimation = Tween<double>(
      begin: 2,
      end: 6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -5.0 / 100),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Verifica si es favorito al inicio
    _checkIsFavorite();
  }

  Future<void> _checkIsFavorite() async {
    final isFavorite =
        await _favoriteService.isPuntoTuristicoFavorite(widget.puntoTuristicoId);
    if (mounted) { //verificamos que el widget está montado antes de llamar a setState
      setState(() {
        _isFavorite = isFavorite;
      });
    }
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
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Transform.translate(
                  offset: _positionAnimation.value *
                      MediaQuery.of(context).size.height,
                  child: Container(
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                            child: Image.asset(
                              widget.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
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
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  'Santo Domingo',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 173, 173, 173),
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
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                ),
                onPressed: () async {
                  // Lógica para añadir/eliminar de favoritos
                  if (_isFavorite) {
                    await _favoriteService
                        .removePuntoTuristicoFromFavorites(widget.puntoTuristicoId);
                  } else {
                    await _favoriteService
                        .addPuntoTuristicoToFavorites(widget.puntoTuristicoId);
                  }
                  if (mounted) { //verificamos que el widget está montado antes de llamar a setState
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

