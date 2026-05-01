import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../scanner/scanner_screen.dart';
import '../recherche/recherche_screen.dart';
import '../historique/historique_screen.dart';
import '../parametres/parametres_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ScannerScreen(),
    RechercheScreen(),
    HistoriqueScreen(),
    ParametresScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.gris1, width: 1)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
            blurRadius: 12, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                _NavItem(icon: Icons.qr_code_scanner_rounded, label: 'Scanner',    index: 0, current: _currentIndex, onTap: _onTap),
                _NavItem(icon: Icons.search_rounded,           label: 'Recherche',  index: 1, current: _currentIndex, onTap: _onTap),
                _NavItem(icon: Icons.history_rounded,          label: 'Historique', index: 2, current: _currentIndex, onTap: _onTap),
                _NavItem(icon: Icons.settings_rounded,         label: 'Paramètres', index: 3, current: _currentIndex, onTap: _onTap),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(int index) => setState(() => _currentIndex = index);
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final void Function(int) onTap;

  const _NavItem({required this.icon, required this.label,
    required this.index, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trait actif
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: isActive ? 24 : 0,
              decoration: BoxDecoration(
                color: AppColors.rouge,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 6),
            Icon(icon, size: 22,
              color: isActive ? AppColors.rouge : AppColors.gris3),
            const SizedBox(height: 3),
            Text(label,
              style: GoogleFonts.epilogue(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? AppColors.rouge : AppColors.gris3,
              )),
          ],
        ),
      ),
    );
  }
}
