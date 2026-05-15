import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/diplome.dart';
import '../theme/app_theme.dart';

// ── BADGE STATUT ──
class StatutBadge extends StatelessWidget {
  final StatutDiplome statut;
  const StatutBadge({super.key, required this.statut});

  @override
  Widget build(BuildContext context) {
    final (label, color, bg, icon) = switch (statut) {
      StatutDiplome.valide       => ('Valide',       AppColors.valide,  AppColors.valideBg,  '✓'),
      StatutDiplome.revoque      => ('Révoqué',      AppColors.revoque, AppColors.revoqueBg, '✗'),
      StatutDiplome.introuvable  => ('Introuvable',  AppColors.gris3,   AppColors.gris1,     '?'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(icon, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.epilogue(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

// ── CARTE RÉSULTAT ──
class ResultatCard extends StatelessWidget {
  final Diplome diplome;
  const ResultatCard({super.key, required this.diplome});

  @override
  Widget build(BuildContext context) {
    final isValide  = diplome.statut == StatutDiplome.valide;
    final isRevoque = diplome.statut == StatutDiplome.revoque;
    final color     = isValide ? AppColors.valide : isRevoque ? AppColors.revoque : AppColors.gris3;
    final bgColor   = isValide ? AppColors.valideBg : isRevoque ? AppColors.revoqueBg : AppColors.gris1;
    final icon      = isValide ? '✅' : isRevoque ? '🚫' : '❓';
    final label     = isValide ? 'DIPLÔME AUTHENTIQUE' : isRevoque ? 'DIPLÔME RÉVOQUÉ' : 'INTROUVABLE';
    final sublabel  = isValide
        ? 'Valide et enregistré officiellement'
        : isRevoque
          ? 'Non valide pour recrutement'
          : 'Aucun diplôme trouvé';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
              border: Border(bottom: BorderSide(color: color.withOpacity(0.2))),
            ),
            child: Row(children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
                  Text(sublabel, style: GoogleFonts.epilogue(fontSize: 11, color: color.withOpacity(0.75))),
                ],
              )),
            ]),
          ),

          // Infos diplôme
          if (diplome.statut != StatutDiplome.introuvable)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _InfoRow('Nom complet',    diplome.nomComplet),
                _InfoRow('Matricule',      diplome.matricule),
                _InfoRow('Diplôme',        diplome.diplome),
                _InfoRow('Mention',        diplome.mention),
                _InfoRow('Établissement',  diplome.etablissement),
                _InfoRow('Délivré le',     diplome.dateDelivrance),
                if (isRevoque && diplome.motifRevocation != null)
                  _InfoRow('Motif', diplome.motifRevocation!, valueColor: AppColors.revoque),
                if (isRevoque && diplome.dateRevocation != null)
                  _InfoRow('Révoqué le', diplome.dateRevocation!),
              ]),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label.toUpperCase(),
              style: GoogleFonts.epilogue(fontSize: 9, letterSpacing: 1.5,
                color: AppColors.sub, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value,
              style: GoogleFonts.epilogue(fontSize: 13, fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.text)),
          ),
        ],
      ),
    );
  }
}

// ── CHARGEMENT ──
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.rouge),
      ),
    );
  }
}

// ── LOGO APP ──
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size * 0.25),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Center(child: Text('🎓', style: TextStyle(fontSize: size * 0.45))),
    );
  }
}

// ── ERREUR SNACKBAR ──
void showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message, style: GoogleFonts.epilogue(color: Colors.white)),
    backgroundColor: AppColors.rouge,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ));
}

void showSuccess(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message, style: GoogleFonts.epilogue(color: Colors.white)),
    backgroundColor: AppColors.vert,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ));
}
