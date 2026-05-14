import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart' as fp;
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../models/diplome.dart';

class RechercheScreen extends StatefulWidget {
  const RechercheScreen({super.key});

  @override
  State<RechercheScreen> createState() => _RechercheScreenState();
}

class _RechercheScreenState extends State<RechercheScreen> {
  final _ctrl = TextEditingController();
  final _apiService = ApiService();
  bool _loading = false;
  Diplome? _resultat;
  bool _searched = false;

  Future<void> _verifier() async {
    final val = _ctrl.text.trim();
    if (val.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _searched = true;
      _resultat = null;
    });

    final result = await _apiService.verifierParMatricule(val);

    if (!mounted) return;
    setState(() {
      _loading = false;
      _resultat = result['success']
          ? result['diplome']
          : Diplome(
              matricule: val,
              nomComplet: '',
              diplome: '',
              mention: '',
              etablissement: '',
              annee: '',
              dateDelivrance: '',
              statut: StatutDiplome.introuvable,
            );
    });
  }

  Future<void> _choisirFichier() async {
    try {
      final fp.FilePickerResult? result = await fp.FilePicker.pickFiles(
        type: fp.FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _loading = true;
          _searched = true;
          _resultat = null;
        });
        final res =
            await _apiService.verifierParFichier(result.files.single.path!);

        if (!mounted) return;
        setState(() {
          _loading = false;
          if (res['success']) {
            _resultat = res['diplome'];
          } else {
            showError(context,
                res['message'] ?? 'Erreur lors de la vérification du fichier');
            _searched = false;
          }
        });
      }
    } catch (e) {
      if (mounted) showError(context, 'Erreur lors de la sélection du fichier');
    }
  }

  void _reinitialiser() {
    _ctrl.clear();
    setState(() {
      _resultat = null;
      _searched = false;
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Recherche Manuelle',
                              style: GoogleFonts.syne(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                          Text('ENTRER UN MATRICULE OU NOM',
                              style: GoogleFonts.epilogue(
                                  fontSize: 9,
                                  letterSpacing: 2.5,
                                  color: Colors.white.withOpacity(0.45))),
                        ],
                      )),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.search_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // Barre de recherche dans le header
                    Row(children: [
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          onSubmitted: (_) => _verifier(),
                          style: GoogleFonts.epilogue(
                              fontSize: 13, color: AppColors.text),
                          decoration: InputDecoration(
                            hintText: 'Ex : UO2-2024-1187 ou SAWADOGO...',
                            fillColor: Colors.white,
                            filled: true,
                            prefixIcon: const Icon(Icons.badge_outlined,
                                color: AppColors.gris3, size: 20),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _verifier,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.or,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.search_rounded,
                              color: AppColors.noir, size: 24),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),

          // ── CONTENU ──
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.rouge))
                : !_searched
                    ? _buildEtatInitial()
                    : _resultat != null
                        ? _buildResultat()
                        : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildEtatInitial() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.gris1,
              borderRadius: BorderRadius.circular(20),
            ),
            child:
                const Center(child: Text('🔍', style: TextStyle(fontSize: 36))),
          ),
          const SizedBox(height: 16),
          Text('Rechercher un diplôme',
              style: GoogleFonts.syne(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text)),
          const SizedBox(height: 8),
          Text(
              'Entrez le matricule ou le nom complet du candidat pour vérifier l\'authenticité de son diplôme.',
              style: GoogleFonts.epilogue(
                  fontSize: 13, color: AppColors.sub, height: 1.6),
              textAlign: TextAlign.center),

          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: _choisirFichier,
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('Importer un diplôme PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.noir,
              minimumSize: const Size(220, 48),
            ),
          ),

          const SizedBox(height: 32),

          // Exemples
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gris1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('EXEMPLES DE RECHERCHE',
                    style: GoogleFonts.epilogue(
                        fontSize: 9,
                        letterSpacing: 2,
                        color: AppColors.sub,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                ...[
                  ('Par matricule', 'UO2-2024-1187'),
                  ('Par nom', 'SAWADOGO Fatimata'),
                ].map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () {
                          _ctrl.text = e.$2;
                          _verifier();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.gris0,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.gris2),
                          ),
                          child: Row(children: [
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.$1,
                                    style: GoogleFonts.epilogue(
                                        fontSize: 10, color: AppColors.sub)),
                                Text(e.$2,
                                    style: GoogleFonts.syne(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.text)),
                              ],
                            )),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                size: 12, color: AppColors.gris3),
                          ]),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultat() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          ResultatCard(diplome: _resultat!),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _reinitialiser,
            icon: const Icon(Icons.refresh_rounded, color: AppColors.rouge),
            label: Text('Nouvelle recherche',
                style: GoogleFonts.syne(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.rouge)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: AppColors.rouge, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
