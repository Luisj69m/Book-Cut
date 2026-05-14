import 'dart:ui';
import 'package:flutter/material.dart';

class GlassToast {
  static void showSuccess(BuildContext context, String title, String message) {
    _showToast(context, title, message, const Color(0xFF00E676), Icons.check_circle_outline_rounded);
  }

  static void showError(BuildContext context, String title, String message) {
    _showToast(context, title, message, const Color(0xFFFF5252), Icons.error_outline_rounded);
  }

  static void showWarning(BuildContext context, String title, String message) {
    _showToast(context, title, message, const Color(0xFFFFD740), Icons.warning_amber_rounded);
  }

  static void _showToast(BuildContext context, String title, String message, Color color, IconData icon) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        title: title,
        message: message,
        color: color,
        icon: icon,
        onDismissed: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }
}

class _ToastWidget extends StatefulWidget {
  final String title;
  final String message;
  final Color color;
  final IconData icon;
  final VoidCallback onDismissed;

  const _ToastWidget({
    required this.title,
    required this.message,
    required this.color,
    required this.icon,
    required this.onDismissed,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    // Animación de entrada (Desliza desde arriba)
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, -1.5), end: const Offset(0, 0))
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    // Animación de la barra de progreso (3 segundos)
    _progressController = AnimationController(vsync: this, duration: const Duration(seconds: 3));

    _startSequence();
  }

  void _startSequence() async {
    // 1. Entra la notificación
    await _slideController.forward();
    // 2. La barra empieza a consumirse
    await _progressController.forward();
    // 3. Se retira hacia arriba
    await _slideController.reverse();
    // 4. Se destruye el widget
    widget.onDismissed();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10, // Justo debajo del notch/batería
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _slideAnimation,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6), // Cristal oscuro
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: widget.color.withOpacity(0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: widget.color.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))
                    ]
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: widget.color.withOpacity(0.2), shape: BoxShape.circle),
                            child: Icon(widget.icon, color: widget.color, size: 24),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 2),
                                Text(widget.message, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // BARRA DE PROGRESO INFERIOR
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height: 3,
                            width: MediaQuery.of(context).size.width * (1.0 - _progressController.value),
                            color: widget.color,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}