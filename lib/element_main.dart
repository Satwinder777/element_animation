import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planet Swipe Animation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const PlanetSwipeScreen(),
    );
  }
}

class PlanetSwipeScreen extends StatefulWidget {
  const PlanetSwipeScreen({Key? key}) : super(key: key);

  @override
  State<PlanetSwipeScreen> createState() => _PlanetSwipeScreenState();
}

class _PlanetSwipeScreenState extends State<PlanetSwipeScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  double _dragStartPosition = 0;

  // Define your planets/elements
  final List<PlanetData> _planets = [
    PlanetData(
      name: "Sun",
      color: Colors.orange,
      symbol: "☉",
      description: "The center of our solar system",
    ),
    PlanetData(
      name: "Mercury",
      color: Colors.grey.shade400,
      symbol: "☿",
      description: "The smallest planet",
    ),
    PlanetData(
      name: "Venus",
      color: Colors.amber.shade600,
      symbol: "♀",
      description: "The hottest planet",
    ),
    PlanetData(
      name: "Earth",
      color: Colors.blue.shade700,
      symbol: "♁",
      description: "Our home planet",
    ),
    PlanetData(
      name: "Mars",
      color: Colors.red.shade700,
      symbol: "♂",
      description: "The red planet",
    ),
  ];

  // Satellite positions (small circles around the main planet)
  final List<Offset> _satellitePositions = [
    const Offset(-0.8, -0.3),  // top left
    const Offset(0, -0.9),     // top
    const Offset(0.8, -0.3),   // top right
    const Offset(0.9, 0.5),    // bottom right
    const Offset(-0.9, 0.5),   // bottom left
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.8,
      initialPage: _currentIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSwipeLeft() {
    if (_currentIndex < _planets.length - 1) {
      _pageController.animateToPage(
        _currentIndex + 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onSwipeRight() {
    if (_currentIndex > 0) {
      _pageController.animateToPage(
        _currentIndex - 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragStart: (details) {
          _dragStartPosition = details.globalPosition.dx;
        },
        onHorizontalDragEnd: (details) {
          final dragDistance = _dragStartPosition - details.globalPosition.dx;
          if (dragDistance > 50) {
            _onSwipeLeft();
          } else if (dragDistance < -50) {
            _onSwipeRight();
          }
        },
        child: Stack(
          children: [
            // Background stars
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                  image: NetworkImage('https://hebbkx1anhila5yf.public.blob.vercel-storage.com/Screenshot_2025-05-14-23-52-01-69_3081a2e5b87d37b79e4fee2cba606e46.jpg-KVorR7ddqaC1RtrQPJbuXCyF2Gb7G3.jpeg'),
                  fit: BoxFit.cover,
                  opacity: 0.3,
                ),
              ),
            ),

            // Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemCount: _planets.length,
                    itemBuilder: (context, index) {
                      // Calculate scale factor based on distance from current
                      final double scale = _currentIndex == index ? 1.0 : 0.8;

                      return TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0.8, end: scale),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        builder: (context, double value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: PlanetWidget(
                          planet: _planets[index],
                          isActive: _currentIndex == index,
                          satellitePositions: _satellitePositions,
                        ),
                      );
                    },
                  ),
                ),

                // Planet name and description
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.2),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    key: ValueKey<int>(_currentIndex),
                    children: [
                      Text(
                        _planets[_currentIndex].name,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _planets[_currentIndex].description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // Navigation indicators
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _planets.length,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        height: 10,
                        width: _currentIndex == index ? 30 : 10,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? _planets[index].color
                              : Colors.grey.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ),

                // Swipe instructions
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    "< Swipe to navigate >",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PlanetData {
  final String name;
  final Color color;
  final String symbol;
  final String description;

  PlanetData({
    required this.name,
    required this.color,
    required this.symbol,
    required this.description,
  });
}

class PlanetWidget extends StatelessWidget {
  final PlanetData planet;
  final bool isActive;
  final List<Offset> satellitePositions;

  const PlanetWidget({
    Key? key,
    required this.planet,
    required this.isActive,
    required this.satellitePositions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main planet
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  planet.color,
                  planet.color.withOpacity(0.7),
                  planet.color.withOpacity(0.5),
                ],
                stops: const [0.4, 0.7, 1.0],
              ),
              boxShadow: isActive
                  ? [
                BoxShadow(
                  color: planet.color.withOpacity(0.6),
                  blurRadius: 30,
                  spreadRadius: 10,
                )
              ]
                  : [],
            ),
            child: Center(
              child: Text(
                planet.symbol,
                style: const TextStyle(
                  fontSize: 60,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Satellite elements (small circles around the planet)
          if (isActive)
            ...satellitePositions.map((position) {
              return Positioned(
                left: MediaQuery.of(context).size.width * 0.4 * (1 + position.dx),
                top: MediaQuery.of(context).size.height * 0.25 * (1 + position.dy),
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: planet.color.withOpacity(0.7),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(
                          planet.name.codeUnitAt(0),
                        ),
                        style: TextStyle(
                          color: planet.color,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),

          // Orbit lines (only visible when active)
          if (isActive)
            ...List.generate(
              satellitePositions.length,
                  (index) => TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (index * 100)),
                builder: (context, double value, child) {
                  return CustomPaint(
                    size: const Size(300, 300),
                    painter: OrbitPainter(
                      progress: value,
                      color: planet.color.withOpacity(0.3),
                      startPoint: Offset.zero,
                      endPoint: satellitePositions[index] * 150,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class OrbitPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Offset startPoint;
  final Offset endPoint;

  OrbitPainter({
    required this.progress,
    required this.color,
    required this.startPoint,
    required this.endPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final actualEnd = Offset(
      center.dx + endPoint.dx * progress,
      center.dy + endPoint.dy * progress,
    );

    // Draw dotted line
    final path = Path();
    path.moveTo(center.dx, center.dy);
    path.lineTo(actualEnd.dx, actualEnd.dy);

    final dashWidth = 5.0;
    final dashSpace = 3.0;
    final dashPath = Path();

    final distance = (actualEnd - center).distance;
    final dashCount = distance / (dashWidth + dashSpace);

    final dx = (actualEnd.dx - center.dx) / dashCount;
    final dy = (actualEnd.dy - center.dy) / dashCount;

    var startX = center.dx;
    var startY = center.dy;

    for (int i = 0; i < dashCount.floor(); i++) {
      if (i % 2 == 0) {
        dashPath.moveTo(startX, startY);
        dashPath.lineTo(startX + dx, startY + dy);
      }
      startX += dx;
      startY += dy;
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(OrbitPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}