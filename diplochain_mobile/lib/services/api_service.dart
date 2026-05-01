import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diplome.dart';

class ApiService {
  static const String baseUrl = 'https://api.diplovérif.bf/v1';
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));

    // Intercepteur pour ajouter le token automatiquement
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));
  }

  // ── AUTHENTIFICATION ──

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        // Sauvegarder le token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('recruteur_nom', data['recruteur']['nom']);
        await prefs.setString('recruteur_entreprise', data['recruteur']['entreprise']);
        await prefs.setString('recruteur_email', data['recruteur']['email']);
        return {'success': true, 'recruteur': Recruteur.fromJson(data['recruteur'])};
      }
      return {'success': false, 'message': 'Identifiants incorrects'};
    } on DioException catch (e) {
      return {'success': false, 'message': _handleError(e)};
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  // ── VÉRIFICATION DIPLÔME ──

  Future<Map<String, dynamic>> verifierParMatricule(String matricule) async {
    try {
      final response = await _dio.get('/diplomes/verifier', queryParameters: {
        'matricule': matricule,
      });

      if (response.statusCode == 200) {
        final diplome = Diplome.fromJson(response.data['diplome']);
        return {'success': true, 'diplome': diplome};
      }
      return {'success': false, 'message': 'Diplôme introuvable'};
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return {'success': false, 'statut': StatutDiplome.introuvable, 'message': 'Aucun diplôme trouvé avec ce matricule'};
      }
      return {'success': false, 'message': _handleError(e)};
    }
  }

  Future<Map<String, dynamic>> verifierParQR(String qrData) async {
    try {
      final response = await _dio.post('/diplomes/verifier-qr', data: {
        'qr_data': qrData,
      });

      if (response.statusCode == 200) {
        final diplome = Diplome.fromJson(response.data['diplome']);
        return {'success': true, 'diplome': diplome};
      }
      return {'success': false, 'message': 'QR Code invalide'};
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return {'success': false, 'statut': StatutDiplome.introuvable, 'message': 'QR Code non reconnu'};
      }
      return {'success': false, 'message': _handleError(e)};
    }
  }

  // ── HISTORIQUE ──

  Future<Map<String, dynamic>> getHistorique({int page = 1}) async {
    try {
      final response = await _dio.get('/verifications/historique', queryParameters: {
        'page': page,
        'per_page': 20,
      });

      if (response.statusCode == 200) {
        final List data = response.data['data'];
        final verifications = data.map((v) => Verification(
          id:               v['id'],
          matricule:        v['matricule'],
          nomCandidat:      v['nom_candidat'],
          diplome:          v['diplome'],
          statut:           Diplome._parseStatut(v['statut']),
          dateVerification: DateTime.parse(v['date']),
          typeVerification: v['type'],
        )).toList();
        return {'success': true, 'verifications': verifications};
      }
      return {'success': false, 'message': 'Erreur de chargement'};
    } on DioException catch (e) {
      return {'success': false, 'message': _handleError(e)};
    }
  }

  // ── GESTION ERREURS ──

  String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connexion trop lente. Vérifiez votre réseau.';
      case DioExceptionType.connectionError:
        return 'Impossible de joindre le serveur. Vérifiez votre connexion.';
      default:
        return e.response?.data?['message'] ?? 'Une erreur est survenue.';
    }
  }
}
