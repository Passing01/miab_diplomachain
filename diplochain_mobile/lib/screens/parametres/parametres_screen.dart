import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';

class ParametresScreen extends StatefulWidget {
  const ParametresScreen({super.key});

  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  final _apiService = ApiService();
  String _nom        = '';
  String _entreprise = '';
  String _email      = '';

  @override
  void initState() {
    super.initState();
    _chargerProfil();
  }

  Future<void> _chargerProfil() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nom        = prefs.getString('recruteur_nom')        ?? '';
      _entreprise = prefs.getString('recruteur_entreprise') ?? '';
      _email      = prefs.getString('recruteur_email')      ?? '';
    });
  }

  Future<void> _deconnecter() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Déconnexion', style: GoogleFonts.syne(fontWeight: FontWeight.w700)),
        content: Text('Voulez-vous vraiment vous déconnecter ?',
          style: GoogleFonts.epilogue()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler', style: GoogleFonts.epilogue(color: AppColors.sub))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
            child: Text('Déconnecter', style: GoogleFonts.epilogue()),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _apiService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ── HEADER ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2C0009), Color(0xFF6B0016)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: Column(
                  children: [
                    Row(children: [
                      Text('Paramètres',
                        style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                    ]),
                    const SizedBox(height: 20),

                    // Avatar profil
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.or,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: Text(
                          _nom.isNotEmpty ? _nom[0].toUpperCase() : 'R',
                          style: GoogleFonts.syne(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.noir),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(_nom, style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text(_entreprise, style: GoogleFonts.epilogue(fontSize: 12, color: Colors.white.withOpacity(0.55))),
                  ],
                ),
              ),
            ),
          ),

          // ── CONTENU ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Infos compte
                _Section(title: 'MON COMPTE', children: [
                  _InfoTile(icon: Icons.person_outline_rounded,  label: 'Nom',        value: _nom),
                  _InfoTile(icon: Icons.business_rounded,        label: 'Entreprise', value: _entreprise),
                  _InfoTile(icon: Icons.email_outlined,          label: 'Email',      value: _email),
                ]),

                const SizedBox(height: 16),

                // Préférences
                _Section(title: 'PRÉFÉRENCES', children: [
                  _SwitchTile(icon: Icons.notifications_outlined, label: 'Notifications', value: true),
                  _SwitchTile(icon: Icons.vibration_rounded,      label: 'Vibration',     value: true),
                ]),

                const SizedBox(height: 16),

                // À propos
                _Section(title: 'À PROPOS', children: [
                  _ActionTile(icon: Icons.info_outline_rounded,  label: 'Version de l\'app', trailing: 'v1.0.0'),
                  _ActionTile(icon: Icons.policy_outlined,       label: 'Politique de confidentialité'),
                  _ActionTile(icon: Icons.help_outline_rounded,  label: 'Aide & Support'),
                ]),

                const SizedBox(height: 24),

                // Déconnexion
                ElevatedButton.icon(
                  onPressed: _deconnecter,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Se déconnecter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.rouge,
                    minimumSize: const Size(double.infinity, 52),
                  ),
                ),

                const SizedBox(height: 24),

                // Footer
                Center(child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _dot(AppColors.rouge), const SizedBox(width: 6),
                    _dot(AppColors.vert),  const SizedBox(width: 6),
                    _dot(AppColors.or),
                  ]),
                  const SizedBox(height: 8),
                  Text('DiploVérif BF — Burkina Faso 2025–2026',
                    style: GoogleFonts.epilogue(fontSize: 10, color: AppColors.gris3, letterSpacing: 0.5)),
                ])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color c) => Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle));
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: GoogleFonts.epilogue(
            fontSize: 9, letterSpacing: 2, color: AppColors.sub, fontWeight: FontWeight.w600)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gris1),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.sub, size: 20),
      title: Text(label, style: GoogleFonts.epilogue(fontSize: 11, color: AppColors.sub)),
      trailing: Text(value, style: GoogleFonts.epilogue(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
    );
  }
}

class _SwitchTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool value;
  const _SwitchTile({required this.icon, required this.label, required this.value});

  @override
  State<_SwitchTile> createState() => _SwitchTileState();
}

class _SwitchTileState extends State<_SwitchTile> {
  late bool _val;

  @override
  void initState() { super.initState(); _val = widget.value; }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(widget.icon, color: AppColors.sub, size: 20),
      title: Text(widget.label, style: GoogleFonts.epilogue(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.text)),
      trailing: Switch(value: _val, onChanged: (v) => setState(() => _val = v), activeColor: AppColors.rouge),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  const _ActionTile({required this.icon, required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.sub, size: 20),
      title: Text(label, style: GoogleFonts.epilogue(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.text)),
      trailing: trailing != null
        ? Text(trailing!, style: GoogleFonts.epilogue(fontSize: 12, color: AppColors.gris3))
        : const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.gris3),
    );
  }
}
