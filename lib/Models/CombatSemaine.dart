class Combat {
  final int idCombat;
  final int idLutteur1;
  final int idLutteur2;
  final String nomLutteur1;
  final String prenomLutteur1;
  final String nomLutteur2;
  final String prenomLutteur2;
  final int? vainqueur;
  final DateTime dateCombat;
  final int pointDuCombat;
  final String? lieu;
  final String? typeVictoire;
  final int? typeCombat;
  final String? dureeCombat;
  final String? statut_pronostic;

  Combat({
    required this.idLutteur1,
    required this.idLutteur2,
    required this.idCombat,
    required this.nomLutteur1,
    required this.prenomLutteur1,
    required this.nomLutteur2,
    required this.prenomLutteur2,
    required this.vainqueur,
    required this.dateCombat,
    required this.pointDuCombat,
    required this.lieu,
    required this.typeVictoire,
    required this.typeCombat,
    required this.dureeCombat,
    required this.statut_pronostic
  });
}
