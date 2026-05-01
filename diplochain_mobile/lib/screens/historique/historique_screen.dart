import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../models/diplome.dart';

class HistoriqueScreen extends StatefulWidget {
  const HistoriqueScreen({super.key});

  @override
  State<HistoriqueScreen> createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends State<HistoriqueScreen> {
  final _apiService = ApiService();
  List<Verification> _verifications = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    setState(() { _loading = true; _error = null; });
    final result = await _apiService.getHistorique();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result['success']) {
        _verifications = result['verifications'];
      } else {
        _error = result['message'];
      }
    });
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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Row(children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Historique',
                        style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                      Text('VOS VÉRIFICATIONS RÉCENTES',
                        style: GoogleFonts.epilogue(fontSize: 9, letterSpacing: 2.5,
                          color: Colors.white.withOpacity(0.45))),
                    ],
                  )),
                  IconButton(
                    onPressed: _charger,
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  ),
                ]),
              ),
            ),
          ),

          // ── CONTENU ──
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.rouge))
              : _error != null
                ? _buildErreur()
                : _verifications.isEmpty
                  ? _buildVide()
                  : _buildListe(),
          ),
        ],
      ),
    );
  }

  Widget _buildListe() {
    return RefreshIndicator(
      color: AppColors.rouge,
      onRefresh: _charger,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _verifications.length,
        itemBuilder: (context, i) {
          final v = _verifications[i];
          return _VerifTile(verification: v);
        },
      ),
    );
  }

  Widget _buildVide() {
    return Center(child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('📋', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 16),
        Text('Aucune vérification',
          style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 8),
        Text('Vos vérifications apparaîtront ici',
          style: GoogleFonts.epilogue(fontSize: 13, color: AppColors.sub)),
      ],
    ));
  }

  Widget _buildErreur() {
    return Center(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(_error ?? 'Erreur', textAlign: TextAlign.center,
            style: GoogleFonts.epilogue(fontSize: 14, color: AppColors.sub)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _charger, child: const Text('Réessayer')),
        ],
      ),
    ));
  }
}

class _VerifTile extends StatelessWidget {
  final Verification verification;
  const _VerifTile({required this.verification});

  @override
  Widget build(BuildContext context) {
    final v = verification;
    final color = switch (v.statut) {
      StatutDiplome.valide      => AppColors.valide,
      StatutDiplome.revoque     => AppColors.revoque,
      StatutDiplome.introuvable => AppColors.gris3,
    };
    final icon = switch (v.statut) {
      StatutDiplome.valide      => '✅',
      StatutDiplome.revoque     => '🚫',
      StatutDiplome.introuvable => '❓',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gris1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
        ),
        title: Text(v.nomCandidat,
          style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(v.diplome,
              style: GoogleFonts.epilogue(fontSize: 11, color: AppColors.sub)),
            const SizedBox(height: 4),
            Row(children: [
              StatutBadge(statut: v.statut),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gris1,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(v.typeVerification == 'qr' ? '📷 QR' : '⌨️ Manuel',
                  style: GoogleFonts.epilogue(fontSize: 9, color: AppColors.sub, fontWeight: FontWeight.w600)),
              ),
            ]),
          ],
        ),
        trailing: Text(
          DateFormat('dd/MM\nHH:mm').format(v.dateVerification),
          style: GoogleFonts.epilogue(fontSize: 10, color: AppColors.gris3),
          textAlign: TextAlign.right,
        ),
      ),
    );
  }
}
