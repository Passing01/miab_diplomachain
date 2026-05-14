import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey          = GlobalKey<FormState>();
  final _nomCtrl          = TextEditingController();
  final _prenomCtrl       = TextEditingController();
  final _usernameCtrl     = TextEditingController();
  final _emailCtrl        = TextEditingController();
  final _passwordCtrl     = TextEditingController();
  final _confirmPassCtrl  = TextEditingController();
  final _companyCtrl      = TextEditingController();
  final _jobTitleCtrl     = TextEditingController();
  final _phoneCtrl        = TextEditingController();
  final _apiService       = ApiService();
  bool _loading           = false;
  bool _obscurePassword   = true;
  bool _obscureConfirm    = true;
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
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPassCtrl.dispose();
    _companyCtrl.dispose();
    _jobTitleCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_passwordCtrl.text != _confirmPassCtrl.text) {
      showError(context, 'Les mots de passe ne correspondent pas');
      return;
    }

    setState(() => _loading = true);

    final result = await _apiService.register(
      username: _usernameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      firstName: _prenomCtrl.text.trim(),
      lastName: _nomCtrl.text.trim(),
      company: _companyCtrl.text.trim(),
      jobTitle: _jobTitleCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success']) {
      showSuccess(context, 'Inscription réussie ! Veuillez vous connecter.');
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      });
    } else {
      showError(context, result['message'] ?? 'Erreur lors de l\'inscription');
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
                    const SizedBox(height: 40),

                    // Logo
                    const AppLogo(),
                    const SizedBox(height: 24),

                    // Titre
                    Text('DiploVérif BF',
                      style: GoogleFonts.syne(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 6),
                    Text('CRÉER UN COMPTE RECRUTEUR',
                      style: GoogleFonts.epilogue(fontSize: 11, letterSpacing: 3,
                        color: Colors.white.withOpacity(0.45))),

                    const SizedBox(height: 32),

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
                            Text('Inscription',
                              style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text)),
                            const SizedBox(height: 4),
                            Text('Créez votre compte pour vérifier les diplômes',
                              style: GoogleFonts.epilogue(fontSize: 12, color: AppColors.sub)),
                            const SizedBox(height: 20),

                            // Prénom et Nom
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('PRÉNOM', style: GoogleFonts.epilogue(
                                        fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w600, color: AppColors.sub)),
                                      const SizedBox(height: 6),
                                      TextFormField(
                                        controller: _prenomCtrl,
                                        decoration: const InputDecoration(
                                          hintText: 'Ex: Jean',
                                          prefixIcon: Icon(Icons.person_outline, color: AppColors.gris3, size: 20),
                                        ),
                                        validator: (v) {
                                          if (v == null || v.isEmpty) return 'Prénom requis';
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('NOM', style: GoogleFonts.epilogue(
                                        fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w600, color: AppColors.sub)),
                                      const SizedBox(height: 6),
                                      TextFormField(
                                        controller: _nomCtrl,
                                        decoration: const InputDecoration(
                                          hintText: 'Ex: Dupont',
                                          prefixIcon: Icon(Icons.person_outline, color: AppColors.gris3, size: 20),
                                        ),
                                        validator: (v) {
                                          if (v == null || v.isEmpty) return 'Nom requis';
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Nom d'utilisateur
                            Text('NOM D\'UTILISATEUR', style: GoogleFonts.epilogue(
                              fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w600, color: AppColors.sub)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _usernameCtrl,
                              decoration: const InputDecoration(
                                hintText: 'Ex: jean.dupont',
                                prefixIcon: Icon(Icons.alternate_email, color: AppColors.gris3, size: 20),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Nom d\'utilisateur requis';
                                if (v.length < 3) return 'Minimum 3 caractères';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Email
                            Text('EMAIL', style: GoogleFonts.epilogue(
                              fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w600, color: AppColors.sub)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'Ex: jean@entreprise.com',
                                prefixIcon: Icon(Icons.mail_outline, color: AppColors.gris3, size: 20),
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
                            const SizedBox(height: 16),

                            // Confirmation mot de passe
                            Text('CONFIRMER LE MOT DE PASSE', style: GoogleFonts.epilogue(
                              fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w600, color: AppColors.sub)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _confirmPassCtrl,
                              obscureText: _obscureConfirm,
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.gris3, size: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: AppColors.gris3, size: 20),
                                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Confirmation requise';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Entreprise
                            Text('ENTREPRISE / ORGANISATION', style: GoogleFonts.epilogue(
                              fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w600, color: AppColors.sub)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _companyCtrl,
                              decoration: const InputDecoration(
                                hintText: 'Ex: Groupe RH Plus',
                                prefixIcon: Icon(Icons.business_outlined, color: AppColors.gris3, size: 20),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Entreprise requise';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Poste
                            Text('POSTE / FONCTION', style: GoogleFonts.epilogue(
                              fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w600, color: AppColors.sub)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _jobTitleCtrl,
                              decoration: const InputDecoration(
                                hintText: 'Ex: Responsable RH',
                                prefixIcon: Icon(Icons.work_outline, color: AppColors.gris3, size: 20),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Poste requis';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Téléphone
                            Text('TÉLÉPHONE', style: GoogleFonts.epilogue(
                              fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w600, color: AppColors.sub)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                hintText: 'Ex: +226 XX XX XX XX',
                                prefixIcon: Icon(Icons.phone_outlined, color: AppColors.gris3, size: 20),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Téléphone requis';
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Bouton d'inscription
                            ElevatedButton(
                              onPressed: _loading ? null : _register,
                              child: _loading
                                ? const SizedBox(width: 20, height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('S\'inscrire'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

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
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                      child: Text('Déjà inscrit ? Se connecter',
                        style: GoogleFonts.epilogue(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
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
