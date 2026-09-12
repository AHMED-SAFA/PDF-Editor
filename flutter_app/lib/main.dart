import 'dart:ui';
import 'package:flutter/material.dart';

import 'core/api_client.dart';
import 'features/translate/translate_page.dart';
import 'features/watermark/watermark_page.dart';

void main() {
  runApp(const PdfEditorApp());
}

class PdfEditorApp extends StatelessWidget {
  const PdfEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Editor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        colorScheme: const ColorScheme.dark(
          background: Color(0xFF0F0F1A),
          surface: Color(0xFF161625),
          primary: Colors.cyanAccent,
          secondary: Colors.purpleAccent,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF161625).withOpacity(0.8),
          indicatorColor: Colors.purpleAccent.withOpacity(0.3),
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const IconThemeData(
                color: Colors.cyanAccent,
                shadows: [
                  Shadow(
                    color: Colors.cyanAccent,
                    blurRadius: 10,
                  )
                ],
              );
            }
            return const IconThemeData(color: Colors.white54);
          }),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const TextStyle(
                color: Colors.cyanAccent,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              );
            }
            return const TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            );
          }),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PdfApiClient _client = PdfApiClient();
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      TranslatePage(key: const ValueKey('translate'), client: _client),
      WatermarkPage(key: const ValueKey('watermark'), client: _client),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AppBar(
              backgroundColor: const Color(0xFF161625).withOpacity(0.65),
              elevation: 0,
              centerTitle: true,
              title: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.purpleAccent, Colors.cyanAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Text(
                  'PDF Editor',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: pages[_index],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (index) => setState(() => _index = index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.translate_rounded),
                  label: 'Translate',
                ),
                NavigationDestination(
                  icon: Icon(Icons.branding_watermark_rounded),
                  label: 'Watermark',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
