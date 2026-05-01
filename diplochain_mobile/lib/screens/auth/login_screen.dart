import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey        = GlobalKey<FormState>();
  final _emailCtrl      = TextEditingController();
  final _passwordCtrl   = TextEditingController();
  final _apiService     = ApiService();
  bool _loading         = false;
  bool _obscurePassword = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final result = await _apiService.login(_emailCtrl.text.trim(), _passwordCtrl.text);

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success']) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      showError(context, result['message'] ?? 'Erreur de connexion');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fond dégradé
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2C0009), Color(0xFF6B0016), Color(0xFF2C0009)],
              ),
            ),
          ),

          // Cercles décoratifs
          Positioned(top: -80, right: -80,
            child: Container(width: 260, height: 260,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: AppColors.rouge.withOpacity(0.15)))),
          Positioned(bottom: -60, left: -60,
            child: Container(width: 200, height: 200,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: AppColors.or.withOpacity(0.08)))),

          // Contenu
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // Logo
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const Center(child: Text('🎓', style: TextStyle(fontSize: 36))),
                    ),
                    const SizedBox(height: 24),

                    // Titre
                    Text('DiploVérif BF',
                      style: GoogleFonts.syne(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 6),
                    Text('ESPACE RECRUTEUR',
                      style: GoogleFonts.epilogue(fontSize: 11, letterSpacing: 3,
                        color: Colors.white.withOpacity(0.45))),

                    const SizedBox(height: 48),

                    // Formulaire
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2),
                          blurRadius: 30, offset: const Offset(0, 10))],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Connexion',
                              style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text)),
                            const SizedBox(height: 4),
                            Text('Connectez-vous pour vérifier les diplômes',
                              style: GoogleFonts.epilogue(fontSize: 12, color: AppColors.sub)),
                            const SizedBox(height: 24),

                            // Email
                            Text('EMAIL', style: GoogleFonts.epilogue(
                              fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w600, color: AppColors.sub)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'recruteur@entreprise.bf',
                                prefixIcon: Icon(Icons.email_outlined, color: AppColors.gris3, size: 20),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Email requis';
                                if (!v.contains('@')) return 'Email invalide';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Mot de passe
                            Text('MOT DE PASSE', style: GoogleFonts.epilogue(
                              fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w600, color: AppColors.sub)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.gris3, size: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: AppColors.gris3, size: 20),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Mot de passe requis';
                                if (v.length < 6) return 'Minimum 6 caractères';
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),

                            // Mot de passe oublié
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: Text('Mot de passe oublié ?',
                                  style: GoogleFonts.epilogue(fontSize: 12, color: AppColors.rouge, fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Bouton
                            ElevatedButton(
                              onPressed: _loading ? null : _login,
                              child: _loading
                                ? const SizedBox(width: 20, height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Se connecter'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Drapeau BF
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      _flagDot(AppColors.rouge),
                      const SizedBox(width: 8),
                      _flagDot(AppColors.vert),
                      const SizedBox(width: 8),
                      _flagDot(AppColors.or),
                    ]),
                    const SizedBox(height: 12),
                    Text('Burkina Faso — 2025–2026',
                      style: GoogleFonts.epilogue(fontSize: 11, color: Colors.white.withOpacity(0.3),
                        letterSpacing: 1)),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),

          if (_loading) const LoadingOverlay(),
        ],
      ),
    );
  }

  Widget _flagDot(Color color) => Container(
    width: 10, height: 10,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
