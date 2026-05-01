enum StatutDiplome { valide, revoque, introuvable }

class Diplome {
  final String matricule;
  final String nomComplet;
  final String diplome;
  final String mention;
  final String etablissement;
  final String annee;
  final String dateDelivrance;
  final StatutDiplome statut;
  final String? motifRevocation;
  final String? dateRevocation;

  Diplome({
    required this.matricule,
    required this.nomComplet,
    required this.diplome,
    required this.mention,
    required this.etablissement,
    required this.annee,
    required this.dateDelivrance,
    required this.statut,
    this.motifRevocation,
    this.dateRevocation,
  });

  factory Diplome.fromJson(Map<String, dynamic> json) {
    return Diplome(
      matricule:       json['matricule'] ?? '',
      nomComplet:      json['nom_complet'] ?? '',
      diplome:         json['diplome'] ?? '',
      mention:         json['mention'] ?? '',
      etablissement:   json['etablissement'] ?? '',
      annee:           json['annee'] ?? '',
      dateDelivrance:  json['date_delivrance'] ?? '',
      statut: _parseStatut(json['statut']),
      motifRevocation: json['motif_revocation'],
      dateRevocation:  json['date_revocation'],
    );
  }

  static StatutDiplome _parseStatut(String? s) {
    switch (s) {
      case 'valide':   return StatutDiplome.valide;
      case 'revoque':  return StatutDiplome.revoque;
      default:         return StatutDiplome.introuvable;
    }
  }
}

class Verification {
  final String id;
  final String matricule;
  final String nomCandidat;
  final String diplome;
  final StatutDiplome statut;
  final DateTime dateVerification;
  final String typeVerification; // 'qr' ou 'manuel'

  Verification({
    required this.id,
    required this.matricule,
    required this.nomCandidat,
    required this.diplome,
    required this.statut,
    required this.dateVerification,
    required this.typeVerification,
  });
}

class Recruteur {
  final String id;
  final String nom;
  final String entreprise;
  final String email;
  final String token;

  Recruteur({
    required this.id,
    required this.nom,
    required this.entreprise,
    required this.email,
    required this.token,
  });

  factory Recruteur.fromJson(Map<String, dynamic> json) {
    return Recruteur(
      id:         json['id'] ?? '',
      nom:        json['nom'] ?? '',
      entreprise: json['entreprise'] ?? '',
      email:      json['email'] ?? '',
      token:      json['token'] ?? '',
    );
  }
}
