import 'package:flutter/material.dart';
import 'package:tursd/services/favorite_service.dart';
import 'package:tursd/models/punto_turistico.dart';
import 'package:provider/provider.dart'; 
import '../providers/theme_provider.dart'; 


class CustomCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String? subtitle;
  final Function()? onTap;
  final dynamic item; // <--- CAMBIO IMPORTANTE: Ahora es dynamic y se llama 'item'

  const CustomCard({
    super.key,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.onTap,
    required this.item, // <--- CAMBIO IMPORTANTE: Ahora es requerido y se llama 'item'
  });

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;
  late Animation<Offset> _positionAnimation;
  final FavoriteService _favoriteService = FavoriteService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Ajusta la elevación y la posición de la animación para ser sutil
    _elevationAnimation = Tween<double>(
      begin: 4, // Elevación inicial más consistente
      end: 8,  // Aumenta un poco la elevación al pasar el mouse
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.01), // Mueve ligeramente hacia arriba (1% de la altura)
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _checkIsFavorite();
  }

  Future<void> _checkIsFavorite() async {
    int? itemId;
    bool favoriteStatus = false;

    // Aquí se verifica el tipo de 'item'
    if (widget.item is PuntoTuristico) {
      itemId = widget.item.id;
      favoriteStatus = await _favoriteService.isPuntoTuristicoFavorite(itemId!);
    } else if (widget.item is LocalTuristico) {
      itemId = widget.item.id;
      favoriteStatus = await _favoriteService.isLocalTuristicoFavorite(itemId!);
    } else {
      // Si el item no es ni PuntoTuristico ni LocalTuristico, no puede ser favorito.
      // Esto es para el caso de las categorías, por ejemplo.
      favoriteStatus = false;
    }

    if (mounted) {
      setState(() {
        _isFavorite = favoriteStatus;
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
    // Accede al tema actual para adaptar los colores
    final theme = Theme.of(context);
    final bool canBeFavorite = widget.item is PuntoTuristico || widget.item is LocalTuristico;

    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Transform.translate(
              offset: _positionAnimation.value * MediaQuery.of(context).size.height,
              child: Card( // Usamos directamente Card en lugar de Container con BoxDecoration
                color: theme.colorScheme.surface, // Color de fondo de la tarjeta según el tema
                elevation: _elevationAnimation.value, // Elevación animada
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias, // Para que la imagen respete los bordes redondeados
                child: Stack( // Usamos Stack para superponer el botón de favoritos
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Image.asset(
                            widget.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Adapta el color de fondo para la imagen de error
                              return Container(
                                color: theme.colorScheme.surfaceVariant, // Un color que se adapta al tema
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: theme.colorScheme.onSurfaceVariant, // Color del icono que contrasta
                                  size: 50,
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurface, // Color del título según el tema
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (widget.subtitle != null && widget.subtitle!.isNotEmpty)
                                Text(
                                  widget.subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.7), // Color del subtítulo según el tema
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Botón de favoritos, solo visible si el item puede ser favorito
                    if (canBeFavorite)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector( // Usamos GestureDetector para tener más control sobre el tap
                          onTap: () async {
                            // Lógica para añadir/eliminar de favoritos
                            if (widget.item is PuntoTuristico) {
                              final puntoId = widget.item.id;
                              if (_isFavorite) {
                                await _favoriteService.removePuntoTuristicoFromFavorites(puntoId);
                              } else {
                                await _favoriteService.addPuntoTuristicoToFavorites(puntoId);
                              }
                            } else if (widget.item is LocalTuristico) {
                              final localId = widget.item.id;
                              if (_isFavorite) {
                                await _favoriteService.removeLocalTuristicoFromFavorites(localId);
                              } else {
                                await _favoriteService.addLocalTuristicoToFavorites(localId);
                              }
                            }
                            if (mounted) {
                              setState(() {
                                _isFavorite = !_isFavorite;
                              });
                            }
                          },
                          child: Container( // Envuelve el icono en un Container para el fondo circular
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withOpacity(0.8), // Fondo semitransparente que se adapta al tema
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: _isFavorite ? Colors.red : theme.colorScheme.onSurface.withOpacity(0.7), // Color del corazón
                              size: 24,
                            ),
                          ),
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