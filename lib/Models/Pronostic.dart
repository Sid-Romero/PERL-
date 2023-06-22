class Pronostic {
  int? idPronostic;
  DateTime? datePronostic;
  int? pronostiqueur;
  int? combat;
  String? duree;
  int? vainqueur;
  String? statut;
  String? prenom_vainqueur;
  String? nom_vainqueur;
  String? pseudo; // Champ supplémentaire pour le pseudo
  Pronostic({
    required this.idPronostic,
    required this.datePronostic,
    required this.pronostiqueur,
    required this.combat,
    required this.duree,
    required this.vainqueur,
    required this.statut,
    required this.prenom_vainqueur,
    required this.nom_vainqueur,
    this.pseudo,
  });
}
