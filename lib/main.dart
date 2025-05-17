import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: DownwardArcSelector(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class DownwardArcSelector extends StatefulWidget {
  @override
  State<DownwardArcSelector> createState() => _DownwardArcSelectorState();
}

class _DownwardArcSelectorState extends State<DownwardArcSelector>
    with SingleTickerProviderStateMixin {
  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.indigo,
    Colors.teal,
    Colors.brown,
  ];

  final List<IconData> icons = [
    Icons.home,
    Icons.star,
    Icons.favorite,
    Icons.lightbulb,
    Icons.music_note,
    Icons.directions_car,
    Icons.flight,
    Icons.phone,
    Icons.map,
    Icons.camera,
  ];

  late AnimationController _controller;
  late Animation<double> _animation;

  int selectedIndex = 4;
  int previousIndex = 4;
  bool isAnimating = false;

  final double radius = 150.0;
  final double iconSize = 24.0;
  final double selectedIconSize = 34.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          previousIndex = selectedIndex;
          isAnimating = false;
        });
        _controller.reset();
      }
    });
  }

  void _navigate(bool forward) {
    if (isAnimating) return;

    setState(() {
      previousIndex = selectedIndex;
      selectedIndex = (selectedIndex + (forward ? 1 : -1) + icons.length) % icons.length;
      isAnimating = true;
    });

    _controller.forward();
  }

  double _getVisualIndex(int i, double centerIndex, int total) {
    double visualIndex = i - centerIndex + total / 2;
    if (visualIndex < 0) visualIndex += total;
    if (visualIndex >= total) visualIndex -= total;
    return visualIndex;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildArcIcons(double animatedIndex) {
    final middleIndex = icons.length / 2;

    return ClipRect(
      child: SizedBox(
        height: radius + 60,
        child: Stack(
          children: List.generate(icons.length, (i) {
            final visualIndex = _getVisualIndex(i, animatedIndex, icons.length);
            double angle = pi * visualIndex / (icons.length - 1);
            double x = radius * cos(angle);
            double y = -radius * sin(angle);

            double distance = (visualIndex - middleIndex).abs();
            double scale = 1.0 + max(0, (1.0 - distance)) * 0.25;

            bool isSelected = visualIndex.round() == middleIndex.round();

            return Positioned(
              top: radius + y,
              left: MediaQuery.of(context).size.width / 2 + x - selectedIconSize / 2,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: colors[i].withOpacity(0.8),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ]
                        : [],
                  ),
                  child: CircleAvatar(
                    radius: isSelected ? selectedIconSize / 2 : iconSize / 2,
                    backgroundColor: colors[i],
                    child: Icon(
                      icons[i],
                      color: Colors.white,
                      size: isSelected ? selectedIconSize * 0.7 : iconSize * 0.7,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (_, __) {
                  double animatedIndex;

                  final isForward = (selectedIndex > previousIndex &&
                      !(selectedIndex == 0 && previousIndex == icons.length - 1)) ||
                      (selectedIndex == 0 && previousIndex == icons.length - 1);

                  if (isAnimating) {
                    animatedIndex = isForward
                        ? previousIndex + _animation.value
                        : previousIndex - _animation.value;

                    if (animatedIndex < 0) animatedIndex += icons.length;
                    if (animatedIndex >= icons.length) animatedIndex -= icons.length;
                  } else {
                    animatedIndex = selectedIndex.toDouble();
                  }

                  return _buildArcIcons(animatedIndex);
                },
              ),
            ),

            // Bottom UI Section
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! < 0) {
                        _navigate(true);
                      } else {
                        _navigate(false);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: colors[selectedIndex],
                            radius: 26,
                            child: Icon(
                              icons[selectedIndex],
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Swipe Left or Right to change selection',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _navigate(false),
                          icon: Icon(Icons.arrow_back),
                          label: Text("Prev"),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton.icon(
                          onPressed: () => _navigate(true),
                          icon: Icon(Icons.arrow_forward),
                          label: Text("Next"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
