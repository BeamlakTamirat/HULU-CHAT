import 'dart:math' as math;
import 'package:flutter/material.dart';

class LogoPainter extends CustomPainter {
  final Animation<double>? animation;
  final bool showText;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color textColor;

  LogoPainter({
    this.animation,
    this.showText = true,
    this.primaryColor = const Color(0xFF1976D2),
    this.secondaryColor = const Color(0xFF64B5F6),
    this.accentColor = const Color(0xFF0D47A1),
    this.textColor = Colors.white,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    // Draw outer circle with gradient
    final outerPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          secondaryColor,
          primaryColor,
        ],
        radius: 0.8,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, outerPaint);
    
    // Draw inner circle for depth effect
    final innerPaint = Paint()
      ..color = accentColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius * 0.85, innerPaint);
    
    // Draw chat bubble shapes
    _drawChatBubbles(canvas, center, radius, animation?.value ?? 0);
    
    // Draw connecting lines between bubbles
    _drawConnectingLines(canvas, center, radius, animation?.value ?? 0);
    
    // Draw text if needed
    if (showText) {
      _drawLogoText(canvas, center, radius);
    }
  }
  
  void _drawChatBubbles(Canvas canvas, Offset center, double radius, double animValue) {
    final bubblePaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;
      
    final bubbleBorderPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    // Calculate positions for 3 chat bubbles in a triangular pattern
    final double bubbleRadius = radius * 0.25;
    final double orbitRadius = radius * 0.5;
    
    // Animate the bubbles in a circular motion
    final double angle1 = (animValue * 2 * math.pi) + (0 * 2 * math.pi / 3);
    final double angle2 = (animValue * 2 * math.pi) + (1 * 2 * math.pi / 3);
    final double angle3 = (animValue * 2 * math.pi) + (2 * 2 * math.pi / 3);
    
    final Offset bubble1Center = Offset(
      center.dx + orbitRadius * math.cos(angle1),
      center.dy + orbitRadius * math.sin(angle1),
    );
    
    final Offset bubble2Center = Offset(
      center.dx + orbitRadius * math.cos(angle2),
      center.dy + orbitRadius * math.sin(angle2),
    );
    
    final Offset bubble3Center = Offset(
      center.dx + orbitRadius * math.cos(angle3),
      center.dy + orbitRadius * math.sin(angle3),
    );
    
    // Draw the chat bubbles with different shapes
    _drawRoundedBubble(canvas, bubble1Center, bubbleRadius, bubblePaint, bubbleBorderPaint);
    _drawSquareBubble(canvas, bubble2Center, bubbleRadius, bubblePaint, bubbleBorderPaint);
    _drawTriangleBubble(canvas, bubble3Center, bubbleRadius, bubblePaint, bubbleBorderPaint);
  }
  
  void _drawRoundedBubble(Canvas canvas, Offset center, double radius, Paint fillPaint, Paint borderPaint) {
    // Draw a rounded chat bubble
    final RRect bubbleShape = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: radius * 2, height: radius * 1.8),
      Radius.circular(radius * 0.8),
    );
    
    canvas.drawRRect(bubbleShape, fillPaint);
    canvas.drawRRect(bubbleShape, borderPaint);
    
    // Add a small triangle at the bottom to make it look like a chat bubble
    final Path trianglePath = Path()
      ..moveTo(center.dx - radius * 0.3, center.dy + radius * 0.9)
      ..lineTo(center.dx - radius * 0.6, center.dy + radius * 1.3)
      ..lineTo(center.dx, center.dy + radius * 0.9)
      ..close();
    
    canvas.drawPath(trianglePath, fillPaint);
    canvas.drawPath(trianglePath, borderPaint);
  }
  
  void _drawSquareBubble(Canvas canvas, Offset center, double radius, Paint fillPaint, Paint borderPaint) {
    // Draw a square chat bubble with rounded corners
    final RRect bubbleShape = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: radius * 1.8, height: radius * 1.8),
      Radius.circular(radius * 0.3),
    );
    
    canvas.drawRRect(bubbleShape, fillPaint);
    canvas.drawRRect(bubbleShape, borderPaint);
    
    // Add a small triangle at the right to make it look like a chat bubble
    final Path trianglePath = Path()
      ..moveTo(center.dx + radius * 0.9, center.dy)
      ..lineTo(center.dx + radius * 1.3, center.dy + radius * 0.3)
      ..lineTo(center.dx + radius * 0.9, center.dy + radius * 0.6)
      ..close();
    
    canvas.drawPath(trianglePath, fillPaint);
    canvas.drawPath(trianglePath, borderPaint);
  }
  
  void _drawTriangleBubble(Canvas canvas, Offset center, double radius, Paint fillPaint, Paint borderPaint) {
    // Draw a circular chat bubble
    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius, borderPaint);
    
    // Add a small triangle at the left to make it look like a chat bubble
    final Path trianglePath = Path()
      ..moveTo(center.dx - radius, center.dy - radius * 0.2)
      ..lineTo(center.dx - radius * 1.4, center.dy)
      ..lineTo(center.dx - radius, center.dy + radius * 0.2)
      ..close();
    
    canvas.drawPath(trianglePath, fillPaint);
    canvas.drawPath(trianglePath, borderPaint);
  }
  
  void _drawConnectingLines(Canvas canvas, Offset center, double radius, double animValue) {
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Draw pulsing circle in the center
    final pulseRadius = radius * 0.2 * (1 + 0.2 * math.sin(animValue * 4 * math.pi));
    final pulsePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, pulseRadius, pulsePaint);
    canvas.drawCircle(center, pulseRadius, Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
  }
  
  void _drawLogoText(Canvas canvas, Offset center, double radius) {
    // Create a TextPainter to draw the text
    final textSpan = TextSpan(
      text: 'HuluChat',
      style: TextStyle(
        color: textColor,
        fontSize: radius * 0.4,
        fontWeight: FontWeight.bold,
        letterSpacing: radius * 0.02,
      ),
    );
    
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    textPainter.layout();
    
    // Position the text in the center
    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );
    
    // Draw a subtle background for better readability
    final bgRect = Rect.fromCenter(
      center: center,
      width: textPainter.width + radius * 0.2,
      height: textPainter.height + radius * 0.1,
    );
    
    final bgPaint = Paint()
      ..color = accentColor.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    
    final bgRRect = RRect.fromRectAndRadius(
      bgRect,
      Radius.circular(radius * 0.1),
    );
    
    canvas.drawRRect(bgRRect, bgPaint);
    
    // Draw the text
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(LogoPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.showText != showText ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.textColor != textColor;
  }
}

class AnimatedLogo extends StatefulWidget {
  final double size;
  final bool showText;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color textColor;

  const AnimatedLogo({
    super.key,
    this.size = 100,
    this.showText = true,
    this.primaryColor = const Color(0xFF1976D2),
    this.secondaryColor = const Color(0xFF64B5F6),
    this.accentColor = const Color(0xFF0D47A1),
    this.textColor = Colors.white,
  });

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: CustomPaint(
        painter: LogoPainter(
          animation: _controller,
          showText: widget.showText,
          primaryColor: widget.primaryColor,
          secondaryColor: widget.secondaryColor,
          accentColor: widget.accentColor,
          textColor: widget.textColor,
        ),
      ),
    );
  }
}