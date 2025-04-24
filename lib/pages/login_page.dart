import 'dart:math';
import 'dart:ui' as ui;
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/components/logo_painter.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  // Text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  // Animation controllers
  late AnimationController _bubblesController;
  late AnimationController _formController;
  late AnimationController _wavesController;
  late AnimationController _loginButtonController;
  late AnimationController _particlesController;

  // Animations
  late Animation<double> _bubblesAnimation;
  late Animation<double> _formAnimation;
  late Animation<double> _loginButtonAnimation;

  // Particles and floating bubbles
  final List<FloatingBubble> _floatingBubbles = [];
  final List<Particle> _particles = [];
  bool _isLoggingIn = false;
  final bool _isKeyboardVisible = false;

  // Messages for typing animation
  final String _welcomeMessage = "Welcome to HuluChat";
  String _displayedWelcomeText = "";
  int _welcomeTextIndex = 0;
  bool _showCursor = true;

  @override
  void initState() {
    super.initState();

    // Generate floating bubbles
    _generateFloatingBubbles();

    // Bubbles animation controller
    _bubblesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    // Form animation controller
    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Waves animation controller
    _wavesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Login button animation controller
    _loginButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Particles animation controller
    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Bubbles animation
    _bubblesAnimation = CurvedAnimation(
      parent: _bubblesController,
      curve: Curves.easeOut,
    );

    // Form animation
    _formAnimation = CurvedAnimation(
      parent: _formController,
      curve: Curves.elasticOut,
    );

    // Login button animation
    _loginButtonAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _loginButtonController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    _bubblesController.forward();

    // Animate the welcome text typing effect
    _animateWelcomeText();

    // Show form after welcome animation
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _formController.forward();
      }
    });
  }

  void _generateFloatingBubbles() {
    final random = Random();
    for (int i = 0; i < 20; i++) {
      _floatingBubbles.add(
        FloatingBubble(
          position: Offset(
            random.nextDouble() * 400,
            random.nextDouble() * 800,
          ),
          size: 10 + random.nextDouble() * 30,
          speed: 0.5 + random.nextDouble() * 1.5,
          opacity: 0.1 + random.nextDouble() * 0.4,
          color: _getRandomBlueColor(random),
        ),
      );
    }
  }

  Color _getRandomBlueColor(Random random) {
    final List<Color> blueShades = [
      Color(0xFF0D47A1), // Deep Blue
      Color(0xFF1976D2), // Blue
      Color(0xFF2196F3), // Light Blue
      Color(0xFF64B5F6), // Very Light Blue
      Color(0xFF90CAF9), // Pale Blue
      Color(0xFF3949AB), // Indigo
      Color(0xFF1A237E), // Dark Indigo
    ];
    return blueShades[random.nextInt(blueShades.length)];
  }

  void _animateWelcomeText() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_welcomeTextIndex < _welcomeMessage.length) {
        setState(() {
          _displayedWelcomeText =
              _welcomeMessage.substring(0, _welcomeTextIndex + 1);
          _welcomeTextIndex++;
        });
        _animateWelcomeText();
      } else {
        // Start blinking cursor
        _blinkCursor();
      }
    });
  }

  void _blinkCursor() {
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showCursor = !_showCursor;
        });
        _blinkCursor();
      }
    });
  }

  void _spawnParticles(Offset position, Color color) {
    final random = Random();

    for (int i = 0; i < 10; i++) {
      final particle = Particle(
        position: position,
        color: color,
        size: 2 + random.nextDouble() * 6,
        speedX: -1 + random.nextDouble() * 2,
        speedY: -1 + random.nextDouble() * 2,
        lifespan: 0.6 + random.nextDouble() * 0.4,
      );

      setState(() {
        _particles.add(particle);
      });

      Future.delayed(Duration(milliseconds: (particle.lifespan * 1000).round()),
          () {
        if (mounted) {
          setState(() {
            _particles.remove(particle);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pwController.dispose();
    _bubblesController.dispose();
    _formController.dispose();
    _wavesController.dispose();
    _loginButtonController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  // Sign in user
  void signIn() async {
    if (_isLoggingIn) return;

    setState(() {
      _isLoggingIn = true;
    });

    // Show loading animation
    _loginButtonController.forward();
    _loginButtonController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _loginButtonController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _loginButtonController.forward();
      }
    });

    // Spawn some particles for visual feedback
    _spawnParticles(
      Offset(MediaQuery.of(context).size.width / 2,
          MediaQuery.of(context).size.height * 0.75),
      Color(0xFF2196F3),
    );

    // Get auth service
    final authService = AuthService();

    try {
      await authService.signInWithEmailPassword(
        _emailController.text,
        _pwController.text,
      );
    } catch (e) {
      // Stop loading animation
      _loginButtonController.reset();
      setState(() {
        _isLoggingIn = false;
      });

      // Show error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Color(0xFF1A237E),
          title: Text(
            "Login Failed",
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            e.toString(),
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "OK",
                style: TextStyle(color: Color(0xFF90CAF9)),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xFF0D2B45),
      body: Stack(
        children: [
          // Animated wave background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _wavesController,
              builder: (context, child) {
                return CustomPaint(
                  painter: WavePainter(
                    waveAnimation: _wavesController.value,
                    waveColor: Color(0xFF1A237E),
                  ),
                );
              },
            ),
          ),

          // Floating bubbles
          ...List.generate(_floatingBubbles.length, (index) {
            final bubble = _floatingBubbles[index];
            return AnimatedBuilder(
              animation: _bubblesController,
              builder: (context, child) {
                bubble.position = Offset(
                  bubble.position.dx,
                  bubble.position.dy - bubble.speed,
                );

                if (bubble.position.dy < -bubble.size) {
                  bubble.position = Offset(
                    bubble.position.dx,
                    size.height + bubble.size,
                  );
                }

                return Positioned(
                  left: bubble.position.dx,
                  top: bubble.position.dy,
                  child: Opacity(
                    opacity: bubble.opacity,
                    child: Container(
                      width: bubble.size,
                      height: bubble.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: bubble.color,
                        boxShadow: [
                          BoxShadow(
                            color: bubble.color.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Particles
          ...List.generate(_particles.length, (index) {
            final particle = _particles[index];
            return AnimatedBuilder(
              animation: _particlesController,
              builder: (context, child) {
                particle.position = Offset(
                  particle.position.dx + particle.speedX,
                  particle.position.dy + particle.speedY,
                );

                return Positioned(
                  left: particle.position.dx,
                  top: particle.position.dy,
                  child: Opacity(
                    opacity: particle.lifespan,
                    child: Container(
                      width: particle.size,
                      height: particle.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: particle.color,
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // Advanced animated logo
                    AnimatedLogo(
                      size: 120,
                      showText: true,
                      primaryColor: Color(0xFF1976D2),
                      secondaryColor: Color(0xFF64B5F6),
                      accentColor: Color(0xFF0D47A1),
                      textColor: Colors.white,
                    ),

                    const SizedBox(height: 40),

                    // Typing effect welcome message
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: _displayedWelcomeText,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          if (_showCursor)
                            TextSpan(
                              text: "|",
                              style: TextStyle(
                                color: Color(0xFF64B5F6),
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Subtitle
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 800),
                      opacity: _welcomeTextIndex >= _welcomeMessage.length
                          ? 1.0
                          : 0.0,
                      child: Text(
                        "Simply chat, simply connect.",
                        style: TextStyle(
                          color: Color(0xFF90CAF9),
                          fontSize: 16,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Login form with scale and slide-up animation
                    ScaleTransition(
                      scale: _formAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(_formAnimation),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          margin: EdgeInsets.symmetric(horizontal: 25),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Color(0xFF1976D2).withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF0D47A1).withOpacity(0.2),
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Email textfield with custom style
                              TextField(
                                controller: _emailController,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: "Email",
                                  hintStyle: TextStyle(
                                      color:
                                          Color(0xFF90CAF9).withOpacity(0.7)),
                                  prefixIcon: Icon(Icons.email,
                                      color: Color(0xFF64B5F6)),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Color(0xFF1976D2).withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFF2196F3)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  fillColor: Color(0xFF1A237E).withOpacity(0.3),
                                  filled: true,
                                ),
                              ),

                              const SizedBox(height: 15),

                              // Password textfield with custom style
                              TextField(
                                controller: _pwController,
                                obscureText: true,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: "Password",
                                  hintStyle: TextStyle(
                                      color:
                                          Color(0xFF90CAF9).withOpacity(0.7)),
                                  prefixIcon: Icon(Icons.lock,
                                      color: Color(0xFF64B5F6)),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Color(0xFF1976D2).withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFF2196F3)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  fillColor: Color(0xFF1A237E).withOpacity(0.3),
                                  filled: true,
                                ),
                              ),

                              const SizedBox(height: 25),

                              // Sign in button with animation
                              GestureDetector(
                                onTap: signIn,
                                child: ScaleTransition(
                                  scale: _loginButtonAnimation,
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF1976D2),
                                          Color(0xFF2196F3),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFF1976D2)
                                              .withOpacity(0.5),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: _isLoggingIn
                                          ? SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 3,
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.login_rounded,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  "Sign In",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    letterSpacing: 1.2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Register now
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 800),
                      opacity: _formController.value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: Color(0xFF90CAF9),
                            ),
                          ),
                          const SizedBox(width: 5),
                          GestureDetector(
                            onTap: widget.onTap,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xFF2196F3),
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                "Register now",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Wave background painter
class WavePainter extends CustomPainter {
  final double waveAnimation;
  final Color waveColor;

  WavePainter({
    required this.waveAnimation,
    required this.waveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;

    final gradient = ui.Gradient.linear(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      [
        Color(0xFF0D47A1).withOpacity(0.8),
        Color(0xFF1A237E).withOpacity(0.3),
      ],
    );

    final gradientPaint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;

    final path = Path();

    // First wave
    path.moveTo(0, size.height * 0.8);

    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height * 0.8 +
            sin((i / size.width * 4 * pi) + (waveAnimation * 2 * pi)) * 20,
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, gradientPaint);

    // Second wave
    final path2 = Path();
    path2.moveTo(0, size.height * 0.85);

    for (double i = 0; i <= size.width; i++) {
      path2.lineTo(
        i,
        size.height * 0.85 +
            sin((i / size.width * 3 * pi) + (waveAnimation * 2 * pi)) * 15,
      );
    }

    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    // Create a new paint with the desired color instead of using copyWith
    final secondWavePaint = Paint()
      ..color = Color(0xFF1976D2).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path2, secondWavePaint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}

// Floating bubble class
class FloatingBubble {
  Offset position;
  final double size;
  final double speed;
  final double opacity;
  final Color color;

  FloatingBubble({
    required this.position,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.color,
  });
}

// Particle class for effects
class Particle {
  Offset position;
  final double speedX;
  final double speedY;
  final double size;
  final Color color;
  double lifespan;

  Particle({
    required this.position,
    required this.speedX,
    required this.speedY,
    required this.size,
    required this.color,
    required this.lifespan,
  });
}
