import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mishra_milk_cash/core/constants/app_colors.dart';

/// Subtle floating particles background with animated glowing dots
class ParticleBackground extends StatefulWidget {
  final Widget child;

  const ParticleBackground({super.key, required this.child});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Create a small number of particles for subtle effect
    _particles = List.generate(18, (_) => _generateParticle());
  }

  _Particle _generateParticle() {
    return _Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      radius: _random.nextDouble() * 2.5 + 0.8,
      speed: _random.nextDouble() * 0.015 + 0.005,
      opacity: _random.nextDouble() * 0.3 + 0.05,
      color: _random.nextBool()
          ? AppColors.primaryPurple
          : AppColors.primaryBlue,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _ParticlePainter(
              particles: _particles,
              progress: _controller.value,
            ),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _Particle {
  double x;
  double y;
  final double radius;
  final double speed;
  final double opacity;
  final Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
    required this.color,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final animatedY = (p.y + progress * p.speed * 10) % 1.0;
      final animatedX = p.x + sin(progress * 2 * pi + p.y * 6) * 0.02;

      final paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.radius * 2);

      canvas.drawCircle(
        Offset(animatedX * size.width, animatedY * size.height),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
