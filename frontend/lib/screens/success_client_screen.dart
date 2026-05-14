import 'package:flutter/material.dart';
import 'login_screen.dart';

class SuccessClientScreen extends StatefulWidget {
  const SuccessClientScreen({super.key});

  @override
  State<SuccessClientScreen> createState() => _SuccessClientScreenState();
}

// Añadimos TickerProviderStateMixin para poder usar animaciones por tiempo
class _SuccessClientScreenState extends State<SuccessClientScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentIndex = 0;

  // ── LISTA DE IMÁGENES (Fondo) ──
  // La primera es tu asset local, las otras son de muestra (puedes poner las tuyas)
  final List<String> _imagenes = [
    'assets/bg_registro.png',
    'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=800&auto=format&fit=crop&q=80',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Configuramos el controlador para que dure exactamente 5 segundos
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // Cada vez que la animación avanza, repintamos para que la barra se llene
    _animationController.addListener(() {
      setState(() {});
    });

    // Cuando termina la animación de 5 segundos, pasamos a la siguiente foto
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _avanzarSiguienteImagen();
      }
    });

    // Arrancamos la animación de la primera imagen
    _animationController.forward();
  }

  void _avanzarSiguienteImagen() {
    if (_currentIndex < _imagenes.length - 1) {
      // Si hay más fotos, avanza a la siguiente
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      // Si es la última, vuelve a empezar (efecto bucle)
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _alCambiarDePagina(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Reiniciamos el tiempo (0 a 5 segundos) para la nueva foto
    _animationController.reset();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. CARRUSEL DE IMÁGENES (PAGEVIEW) ──
          PageView.builder(
            controller: _pageController,
            onPageChanged: _alCambiarDePagina,
            itemCount: _imagenes.length,
            itemBuilder: (context, index) {
              final isAsset = _imagenes[index].startsWith('assets');
              return Image(
                image: isAsset ? AssetImage(_imagenes[index]) as ImageProvider : NetworkImage(_imagenes[index]),
                fit: BoxFit.cover,
              );
            },
          ),

          // ── 2. CAPA DE GRADIENTE OSCURO FIJO SOBRE EL CARRUSEL ──
          // Esto asegura que el texto se lea bien independientemente de la foto que haya detrás
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.9), // Muy oscuro abajo para el botón
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // ── 3. CAPA DE CONTENIDO (BARRAS, TEXTOS Y BOTÓN) ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // ── BARRAS DE PROGRESO ESTILO STORIES ──
                  Row(
                    children: List.generate(_imagenes.length, (index) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3.0),
                          child: _buildStoryProgressBar(index),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 30),

                  // ── TEXTO SUPERIOR ──
                  const Text(
                    "REVELA TU ESTILO NATURAL\nCON UN CUIDADO PREMIUM DISEÑADO\nPARA REALZAR TU VERDADERA ESENCIA.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      letterSpacing: 1.2,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Aviso del correo
                  Text(
                    "* Se ha enviado un código de verificación a tu correo.",
                    style: TextStyle(
                      color: const Color(0xFFE96D71).withOpacity(0.9), // pinkAccent
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Spacer(),

                  // ── TEXTO INFERIOR ──
                  const Text(
                    "TU ESTILO, TU\nBARBERO, A UN\nSOLO TOQUE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── BOTÓN DESLIZANTE (SWIPE TO START) ──
                  SwipeToStartButton(
                    onSwipeComplete: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (Route<dynamic> route) => false,
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Lógica matemática para saber cuánto llenar cada barrita
  Widget _buildStoryProgressBar(int index) {
    double percent = 0.0;
    if (index < _currentIndex) {
      percent = 1.0; // Fotos pasadas: barra completamente llena
    } else if (index == _currentIndex) {
      percent = _animationController.value; // Foto actual: llenándose (0.0 a 1.0)
    } else {
      percent = 0.0; // Fotos futuras: barra vacía
    }

    return Container(
      height: 3,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: percent, // Esto dibuja el progreso basado en el porcentaje
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// WIDGET PERSONALIZADO: BOTÓN DESLIZANTE (Swipe To Start)
// (Sin modificaciones, funciona perfectamente igual)
// ==========================================================
class SwipeToStartButton extends StatefulWidget {
  final VoidCallback onSwipeComplete;

  const SwipeToStartButton({super.key, required this.onSwipeComplete});

  @override
  State<SwipeToStartButton> createState() => _SwipeToStartButtonState();
}

class _SwipeToStartButtonState extends State<SwipeToStartButton> {
  double _dragPosition = 0.0;
  bool _isDragging = false;
  bool _isCompleted = false;
  final double _thumbSize = 54.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth;
          final double maxDragPosition = maxWidth - _thumbSize - 12;

          return Container(
            height: 66,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isCompleted ? "¡Vamos!" : "Empezar",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.keyboard_double_arrow_right_rounded,
                        color: Colors.white.withOpacity(0.4),
                        size: 20,
                      ),
                    ],
                  ),
                ),
                AnimatedPositioned(
                  duration: _isDragging ? Duration.zero : const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  left: 6 + _dragPosition,
                  child: GestureDetector(
                    onHorizontalDragStart: (details) {
                      if (!_isCompleted) setState(() => _isDragging = true);
                    },
                    onHorizontalDragUpdate: (details) {
                      if (!_isCompleted) {
                        setState(() {
                          _dragPosition += details.delta.dx;
                          if (_dragPosition < 0) _dragPosition = 0;
                          if (_dragPosition >= maxDragPosition) {
                            _dragPosition = maxDragPosition;
                            _isCompleted = true;
                            _isDragging = false;
                            widget.onSwipeComplete();
                          }
                        });
                      }
                    },
                    onHorizontalDragEnd: (details) {
                      if (!_isCompleted) {
                        setState(() {
                          _isDragging = false;
                          _dragPosition = 0.0;
                        });
                      }
                    },
                    child: Container(
                      width: _thumbSize,
                      height: _thumbSize,
                      decoration: const BoxDecoration(
                          color: Color(0xFF262626),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            )
                          ]
                      ),
                      child: const Icon(
                        Icons.content_cut_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }
}