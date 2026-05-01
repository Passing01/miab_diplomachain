import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../models/diplome.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _apiService      = ApiService();
  final _scannerCtrl     = MobileScannerController();
  bool _scanning         = true;
  bool _loading          = false;
  Diplome? _resultat;

  @override
  void dispose() {
    _scannerCtrl.dispose();
    super.dispose();
  }

  Future<void> _onQRDetected(BarcodeCapture capture) async {
    if (!_scanning || _loading) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    setState(() { _scanning = false; _loading = true; });
    await _scannerCtrl.stop();

    final result = await _apiService.verifierParQR(barcode!.rawValue!);

    if (!mounted) return;
    setState(() {
      _loading = false;
      _resultat = result['success'] ? result['diplome'] : Diplome(
        matricule: '', nomComplet: '', diplome: '', mention: '',
        etablissement: '', annee: '', dateDelivrance: '',
        statut: StatutDiplome.introuvable,
      );
    });
  }

  void _recommencer() {
    setState(() { _scanning = true; _resultat = null; });
    _scannerCtrl.start();
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
                child: Row(
                  children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DiploVérif BF',
                          style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                        Text('SCANNER UN DIPLÔME',
                          style: GoogleFonts.epilogue(fontSize: 9, letterSpacing: 2.5,
                            color: Colors.white.withOpacity(0.45))),
                      ],
                    )),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 22),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── CONTENU ──
          Expanded(
            child: _resultat != null
              ? _buildResultat()
              : _buildScanner(),
          ),
        ],
      ),
    );
  }

  Widget _buildScanner() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text('Scanner le QR Code du candidat',
            style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 4),
          Text('Pointez la caméra vers le QR Code du diplôme',
            style: GoogleFonts.epilogue(fontSize: 12, color: AppColors.sub),
            textAlign: TextAlign.center),
          const SizedBox(height: 20),

          // Zone scanner
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 280,
              child: Stack(
                children: [
                  MobileScanner(
                    controller: _scannerCtrl,
                    onDetect: _onQRDetected,
                  ),
                  // Overlay avec viseur
                  CustomPaint(painter: _ScannerOverlayPainter()),
                  if (_loading)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: CircularProgressIndicator(color: AppColors.or)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Assurez-vous que le QR Code est bien centré et éclairé',
            style: GoogleFonts.epilogue(fontSize: 11, color: AppColors.gris3),
            textAlign: TextAlign.center),

          const SizedBox(height: 24),
          Row(children: [
            const Expanded(child: Divider(color: AppColors.gris2)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('ou saisir manuellement',
                style: GoogleFonts.epilogue(fontSize: 11, color: AppColors.gris3)),
            ),
            const Expanded(child: Divider(color: AppColors.gris2)),
          ]),
          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded, color: AppColors.rouge),
            label: Text('Recherche manuelle',
              style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.rouge)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: AppColors.rouge, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _recommencer,
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: const Text('Scanner un autre diplôme'),
          ),
        ],
      ),
    );
  }
}

// Overlay viseur doré
class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    const hw = 120.0;
    const hh = 120.0;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: hw * 2, height: hh * 2),
        const Radius.circular(8)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);

    // Coins dorés
    final cp = Paint()
      ..color = const Color(0xFFF4A900)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 24.0;
    final l = cx - hw; final r = cx + hw;
    final t = cy - hh; final b = cy + hh;

    // Coin haut-gauche
    canvas.drawLine(Offset(l, t + len), Offset(l, t), cp);
    canvas.drawLine(Offset(l, t), Offset(l + len, t), cp);
    // Coin haut-droit
    canvas.drawLine(Offset(r - len, t), Offset(r, t), cp);
    canvas.drawLine(Offset(r, t), Offset(r, t + len), cp);
    // Coin bas-gauche
    canvas.drawLine(Offset(l, b - len), Offset(l, b), cp);
    canvas.drawLine(Offset(l, b), Offset(l + len, b), cp);
    // Coin bas-droit
    canvas.drawLine(Offset(r - len, b), Offset(r, b), cp);
    canvas.drawLine(Offset(r, b), Offset(r, b - len), cp);
  }

  @override
  bool shouldRepaint(_) => false;
}
