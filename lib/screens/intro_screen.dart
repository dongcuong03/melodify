import 'package:flutter/material.dart';
import 'auth/login_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _textAnimation;
  late Animation<double> _buttonAnimation;
  late Animation<double> _buttonSlideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Animation cho chữ và icon
    _textAnimation = Tween<double>(begin: -100, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    // Animation cho nút (opacity)
    _buttonAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.7, 1.0, curve: Curves.easeInOut), // Bắt đầu nhanh hơn
      ),
    );

    // Animation cho vị trí của nút
    _buttonSlideAnimation = Tween<double>(begin: -200, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.7, 1.0, curve: Curves.easeInOut), // Bắt đầu nhanh hơn
      ),
    );

    // Bắt đầu animation cho chữ và icon
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.black87,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Chữ và icon di chuyển từ trên xuống
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _textAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _textAnimation.value),
                        child: child,
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Melodify',
                            style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 16),
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: Color(0x80005609),
                          ),
                          SizedBox(width: 8),
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: Color(0xBF005609),
                          ),
                          SizedBox(width: 8),
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Color(0xff005609),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Nút ElevatedButton di chuyển từ trái sang phải
              AnimatedBuilder(
                animation: _buttonSlideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_buttonSlideAnimation.value, 0),
                    child: Opacity(
                      opacity: _buttonAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    fixedSize: const Size(230, 60),
                  ),
                  child: const Text(
                    'BẮT ĐẦU',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
