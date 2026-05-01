import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diplome.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, 127.0.0.1 for iOS
  static const String baseUrl = 'http://192.168.1.95:8000/api';
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));

    // Interceptor to add JWT Token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  // ── AUTHENTIFICATION ──

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post('/accounts/api/login/', data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['access']);
        await prefs.setString('refresh', data['refresh']);
        
        // We should fetch user profile after login to get name/company
        return await getProfile();
      }
      return {'success': false, 'message': 'Identifiants incorrects'};
    } on DioException catch (e) {
      return {'success': false, 'message': _handleError(e)};
    }
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String company,
    required String jobTitle,
    required String phone,
  }) async {
    try {
      final response = await _dio.post('/accounts/api/register/', data: {
        'username': username,
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'role': 'recruiter',
        'company_name': company,
        'job_title': jobTitle,
        'phone_number': phone,
      });

      if (response.statusCode == 201) {
        // Auto-login after register? Or just return success
        return {'success': true, 'message': 'Inscription réussie'};
      }
      return {'success': false, 'message': 'Erreur lors de l\'inscription'};
    } on DioException catch (e) {
      return {'success': false, 'message': _handleError(e)};
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/accounts/api/profile/');
      if (response.statusCode == 200) {
        final data = response.data;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('recruteur_nom', '${data['first_name']} ${data['last_name']}');
        await prefs.setString('recruteur_entreprise', data['company_name'] ?? '');
        await prefs.setString('recruteur_email', data['email']);
        
        // Return a recruteur object (using simple Map or existing model)
        return {
          'success': true, 
          'recruteur': Recruteur(
            id: data['id'].toString(),
            nom: '${data['first_name']} ${data['last_name']}',
            entreprise: data['company_name'] ?? '',
            email: data['email'],
            token: prefs.getString('token') ?? '',
          )
        };
      }
      return {'success': false, 'message': 'Erreur de profil'};
    } on DioException catch (e) {
      return {'success': false, 'message': _handleError(e)};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ── VÉRIFICATION DIPLÔME ──

  Future<Map<String, dynamic>> verifierParMatricule(String identifier) async {
    try {
      final response = await _dio.get('/core/verify/', queryParameters: {
        'id': identifier,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final diplome = Diplome(
          matricule: data['data']['student_id_number'],
          nomComplet: '${data['student_first_name']} ${data['student_last_name']}',
          diplome: data['degree_name'],
          mention: data['data']['mention'] ?? 'N/A',
          etablissement: data['institution_name'],
          annee: data['data']['graduation_date'].split('-')[0],
          dateDelivrance: data['data']['graduation_date'],
          statut: data['is_blockchain_verified'] ? StatutDiplome.valide : StatutDiplome.valide, // If found in DB, it's valid for now
        );
        return {'success': true, 'diplome': diplome};
      }
      return {'success': false, 'message': 'Diplôme introuvable'};
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return {'success': false, 'statut': StatutDiplome.introuvable, 'message': 'Aucun diplôme trouvé'};
      }
      return {'success': false, 'message': _handleError(e)};
    }
  }

  Future<Map<String, dynamic>> verifierParFichier(String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _dio.post('/core/verify/', data: formData);

      if (response.statusCode == 200) {
        final data = response.data;
        final diplome = Diplome(
          matricule: data['data']['student_id_number'],
          nomComplet: '${data['student_first_name']} ${data['student_last_name']}',
          diplome: data['degree_name'],
          mention: data['data']['mention'] ?? 'N/A',
          etablissement: data['institution_name'],
          annee: data['data']['graduation_date'].split('-')[0],
          dateDelivrance: data['data']['graduation_date'],
          statut: data['is_blockchain_verified'] ? StatutDiplome.valide : StatutDiplome.valide,
        );
        return {'success': true, 'diplome': diplome};
      }
      return {'success': false, 'message': 'Diplôme introuvable'};
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return {'success': false, 'statut': StatutDiplome.introuvable, 'message': 'Fichier non reconnu'};
      }
      return {'success': false, 'message': _handleError(e)};
    }
  }

  // Handle QR Data (often contains the ID)
  Future<Map<String, dynamic>> verifierParQR(String qrData) async {
    // Usually the QR contains the 12-char unique identifier
    return verifierParMatricule(qrData);
  }

  // ── HISTORIQUE ──

  Future<Map<String, dynamic>> getHistorique() async {
    try {
      final response = await _dio.get('/core/verifications/');

      if (response.statusCode == 200) {
        final List data = response.data;
        final verifications = data.map((v) => Verification(
          id:               v['id'].toString(),
          matricule:        v['student_id'] ?? '',
          nomCandidat:      '${v['student_name']} ${v['student_last_name']}',
          diplome:          v['degree_name'] ?? '',
          statut:           StatutDiplome.valide, 
          dateVerification: DateTime.parse(v['verified_at']),
          typeVerification: 'qr', 
        )).toList();
        return {'success': true, 'verifications': verifications};
      }
      return {'success': false, 'message': 'Erreur de chargement'};
    } on DioException catch (e) {
      return {'success': false, 'message': _handleError(e)};
    }
  }

  String _handleError(DioException e) {
    if (e.response?.data != null && e.response?.data is Map) {
      return e.response?.data['error'] ?? e.response?.data['message'] ?? e.response?.data['detail'] ?? 'Erreur serveur';
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Délai de connexion dépassé';
      case DioExceptionType.connectionError:
        return 'Impossible de joindre le serveur (Vérifiez votre connexion)';
      default:
        return 'Une erreur est survenue';
    }
  }
}
