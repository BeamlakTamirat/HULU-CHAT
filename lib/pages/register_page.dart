import 'dart:math';
import 'dart:ui' as ui;
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  // Text controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmpwController = TextEditingController();

  // Animation controllers
  late AnimationController _bubblesController;
  late AnimationController _formController;
  late AnimationController _wavesController;
  late AnimationController _registerButtonController;
  late AnimationController _particlesController;
  late AnimationController _fieldFocusController;

  // Animations
  late Animation<double> _bubblesAnimation;
  late Animation<double> _formAnimation;
  late Animation<double> _registerButtonAnimation;

  // Form field animations - for staggered appearance
  late List<Animation<double>> _fieldAnimations;

  // Particles and floating bubbles
  final List<FloatingBubble> _floatingBubbles = [];
  final List<Particle> _particles = [];
  bool _isRegistering = false;
  bool _isKeyboardVisible = false;

  // Messages for typing animation
  final String _welcomeMessage = "Create an Account";
  String _displayedWelcomeText = "";
  int _welcomeTextIndex = 0;
  bool _showCursor = true;

  // Focus nodes for form fields
  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  // Currently active field for focus effect
  int _activeFieldIndex = -1;

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

    // Register button animation controller
    _registerButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Particles animation controller
    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Field focus animation controller
    _fieldFocusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

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

    // Register button animation
    _registerButtonAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _registerButtonController,
        curve: Curves.easeInOut,
      ),
    );

    // Create staggered animations for form fields
    _fieldAnimations = List.generate(5, (index) {
      final delay = 0.2 + (index * 0.1);
      return CurvedAnimation(
        parent: _formController,
        curve: Interval(delay, delay + 0.4, curve: Curves.easeOut),
      );
    });

    // Start animations
    _bubblesController.forward();

    // Animate the welcome text typing effect
    _animateWelcomeText();

    // Show form after welcome animation
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        _formController.forward();
      }
    });

    // Set up focus listeners
    _setupFocusListeners();

    // Monitor keyboard visibility
    KeyboardVisibilityController().onChange.listen((bool visible) {
      setState(() {
        _isKeyboardVisible = visible;
      });

      if (visible) {
        // When keyboard appears, scroll to make form visible
        Future.delayed(const Duration(milliseconds: 300), () {
          _scrollToFocusedField();
        });
      }
    });
  }

  void _scrollToFocusedField() {
    // This would be implemented to ensure the focused field is visible
    // when the keyboard appears
  }

  void _setupFocusListeners() {
    _firstNameFocus.addListener(() {
      if (_firstNameFocus.hasFocus) {
        setState(() => _activeFieldIndex = 0);
        _spawnFocusParticles(0);
      }
    });

    _lastNameFocus.addListener(() {
      if (_lastNameFocus.hasFocus) {
        setState(() => _activeFieldIndex = 1);
        _spawnFocusParticles(1);
      }
    });

    _emailFocus.addListener(() {
      if (_emailFocus.hasFocus) {
        setState(() => _activeFieldIndex = 2);
        _spawnFocusParticles(2);
      }
    });

    _passwordFocus.addListener(() {
      if (_passwordFocus.hasFocus) {
        setState(() => _activeFieldIndex = 3);
        _spawnFocusParticles(3);
      }
    });

    _confirmPasswordFocus.addListener(() {
      if (_confirmPasswordFocus.hasFocus) {
        setState(() => _activeFieldIndex = 4);
        _spawnFocusParticles(4);
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
      Color(0xFF42A5F5), // Sky Blue
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

  void _spawnFocusParticles(int fieldIndex) {
    // Get field position based on index
    final random = Random();
    double yPosition = 200.0 + (fieldIndex * 70.0); // Approximated position

    for (int i = 0; i < 8; i++) {
      final particle = Particle(
        position: Offset(MediaQuery.of(context).size.width * 0.5, yPosition),
        color: Color(0xFF64B5F6),
        size: 2 + random.nextDouble() * 4,
        speedX: -2 + random.nextDouble() * 4,
        speedY: -1 + random.nextDouble() * 2,
        lifespan: 0.3 + random.nextDouble() * 0.3,
      );

      setState(() {
        _particles.add(particle);
      });

      Future.delayed(Duration(milliseconds: (particle.lifespan * 800).round()),
          () {
        if (mounted) {
          setState(() {
            _particles.remove(particle);
          });
        }
      });
    }
  }

  void _spawnParticles(Offset position, Color color) {
    final random = Random();

    for (int i = 0; i < 15; i++) {
      final particle = Particle(
        position: position,
        color: color,
        size: 2 + random.nextDouble() * 6,
        speedX: -1.5 + random.nextDouble() * 3.0,
        speedY: -1.5 + random.nextDouble() * 3.0,
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _pwController.dispose();
    _confirmpwController.dispose();

    _bubblesController.dispose();
    _formController.dispose();
    _wavesController.dispose();
    _registerButtonController.dispose();
    _particlesController.dispose();
    _fieldFocusController.dispose();

    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();

    super.dispose();
  }

  // Register user
  Future<void> register() async {
    if (_isRegistering) return;

    // Check if passwords match
    if (_pwController.text.trim() != _confirmpwController.text.trim()) {
      // Show error animation with particles
      _spawnParticles(
        Offset(MediaQuery.of(context).size.width / 2,
            MediaQuery.of(context).size.height * 0.8),
        Colors.redAccent,
      );

      // Show error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Color(0xFF1A237E),
          title: Text(
            "Password Error",
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            "Passwords don't match!",
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
      return;
    }

    setState(() {
      _isRegistering = true;
    });

    // Show loading animation
    _registerButtonController.forward();
    _registerButtonController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _registerButtonController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _registerButtonController.forward();
      }
    });

    // Spawn some particles for visual feedback
    _spawnParticles(
      Offset(MediaQuery.of(context).size.width / 2,
          MediaQuery.of(context).size.height * 0.8),
      Color(0xFF2196F3),
    );

    // Get auth service
    final auth = AuthService();

    try {
      // Register user
      await auth.signUpWithEmailPassword(
        _emailController.text.trim(),
        _pwController.text,
      );

      // Update display name with first and last name if provided
      if (_firstNameController.text.isNotEmpty ||
          _lastNameController.text.isNotEmpty) {
        String displayName =
            "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}";
        await auth.updateDisplayName(displayName.trim());
      }

      // Navigate to home
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // Stop loading animation
      _registerButtonController.reset();
      setState(() {
        _isRegistering = false;
      });

      // Show error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Color(0xFF1A237E),
          title: Text(
            "Registration Failed",
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
      body: KeyboardDismissOnTap(
        child: Stack(
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
                      // Conditionally show logo and title based on keyboard visibility
                      if (!_isKeyboardVisible) ...[
                        const SizedBox(height: 20),

                        // App logo with pulse animation
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.95, end: 1.05),
                          duration: Duration(milliseconds: 2000),
                          curve: Curves.easeInOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      Color(0xFF64B5F6),
                                      Color(0xFF1976D2),
                                    ],
                                    radius: 0.8,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF2196F3).withOpacity(0.6),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Main icon
                                    Icon(
                                      Icons.person_add_outlined,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                    // Decorative elements
                                    Positioned(
                                      bottom: 25,
                                      right: 20,
                                      child: Container(
                                        width: 15,
                                        height: 15,
                                        decoration: BoxDecoration(
                                          color: Color(0xFF64B5F6),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Small accent line
                                    Positioned(
                                      bottom: 22,
                                      left: 22,
                                      child: Container(
                                        width: 16,
                                        height: 3,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          onEnd: () {
                            setState(() {});
                          },
                        ),

                        const SizedBox(height: 30),

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

                        const SizedBox(height: 10),

                        // Subtitle
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 800),
                          opacity: _welcomeTextIndex >= _welcomeMessage.length
                              ? 1.0
                              : 0.0,
                          child: Text(
                            "Join the chat revolution",
                            style: TextStyle(
                              color: Color(0xFF90CAF9),
                              fontSize: 16,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ] else
                        const SizedBox(height: 15),

                      // Register form with scale and slide-up animation
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
                                // First Name field with animation
                                FadeTransition(
                                  opacity: _fieldAnimations[0],
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.3, 0),
                                      end: Offset.zero,
                                    ).animate(_fieldAnimations[0]),
                                    child: _buildTextField(
                                      controller: _firstNameController,
                                      hintText: "First Name",
                                      icon: Icons.person_outline,
                                      focusNode: _firstNameFocus,
                                      index: 0,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 15),

                                // Last Name field with animation
                                FadeTransition(
                                  opacity: _fieldAnimations[1],
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.3, 0),
                                      end: Offset.zero,
                                    ).animate(_fieldAnimations[1]),
                                    child: _buildTextField(
                                      controller: _lastNameController,
                                      hintText: "Last Name",
                                      icon: Icons.person_outline,
                                      focusNode: _lastNameFocus,
                                      index: 1,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 15),

                                // Email field with animation
                                FadeTransition(
                                  opacity: _fieldAnimations[2],
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.3, 0),
                                      end: Offset.zero,
                                    ).animate(_fieldAnimations[2]),
                                    child: _buildTextField(
                                      controller: _emailController,
                                      hintText: "Email",
                                      icon: Icons.email_outlined,
                                      focusNode: _emailFocus,
                                      index: 2,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 15),

                                // Password field with animation
                                FadeTransition(
                                  opacity: _fieldAnimations[3],
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.3, 0),
                                      end: Offset.zero,
                                    ).animate(_fieldAnimations[3]),
                                    child: _buildTextField(
                                      controller: _pwController,
                                      hintText: "Password",
                                      icon: Icons.lock_outline,
                                      isPassword: true,
                                      focusNode: _passwordFocus,
                                      index: 3,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 15),

                                // Confirm Password field with animation
                                FadeTransition(
                                  opacity: _fieldAnimations[4],
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.3, 0),
                                      end: Offset.zero,
                                    ).animate(_fieldAnimations[4]),
                                    child: _buildTextField(
                                      controller: _confirmpwController,
                                      hintText: "Confirm Password",
                                      icon: Icons.lock_outline,
                                      isPassword: true,
                                      focusNode: _confirmPasswordFocus,
                                      index: 4,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 25),

                                // Register button with animation
                                FadeTransition(
                                  opacity: _formAnimation,
                                  child: GestureDetector(
                                    onTap: register,
                                    child: ScaleTransition(
                                      scale: _registerButtonAnimation,
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
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                          child: _isRegistering
                                              ? SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 3,
                                                  ),
                                                )
                                              : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.person_add,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      "Register Now",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Login now
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 800),
                        opacity: _formController.value,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account?",
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
                                  "Login",
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

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build text fields with consistent styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    required FocusNode focusNode,
    required int index,
  }) {
    final isActive = _activeFieldIndex == index;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Color(0xFF64B5F6).withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Color(0xFF90CAF9).withOpacity(0.7)),
          prefixIcon: Icon(icon,
              color: isActive
                  ? Color(0xFF64B5F6)
                  : Color(0xFF64B5F6).withOpacity(0.7)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF1976D2).withOpacity(0.5)),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF2196F3), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          fillColor: isActive
              ? Color(0xFF1A237E).withOpacity(0.4)
              : Color(0xFF1A237E).withOpacity(0.3),
          filled: true,
        ),
      ),
    );
  }
}

// KeyboardDismissOnTap widget to handle keyboard dismissal
class KeyboardDismissOnTap extends StatelessWidget {
  final Widget child;

  const KeyboardDismissOnTap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: child,
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

    // Create a new paint with the desired color
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
