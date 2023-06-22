import 'package:flutter/material.dart';
import 'package:flutter_responsive_login_ui/Models/Pronostic.dart';

class PronosticCard extends StatelessWidget {
  final Pronostic pronosticData;

  PronosticCard({required this.pronosticData});

  @override
  Widget build(BuildContext context) {
    final pseudo = pronosticData.pseudo;
    final datePronostic = pronosticData.datePronostic;
    final duree = pronosticData.duree;
    final nomCompletVainqueur =
        '${pronosticData.prenom_vainqueur} ${pronosticData.nom_vainqueur}';

    return Card(
      color: Colors.white70,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Détails pronostic',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(
            color: Colors.black,
            height: 1,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailRow(label: 'Pseudo', value: pseudo!),
                SizedBox(height: 10),
                DetailRow(label: 'Date/heure', value: datePronostic.toString()),
                SizedBox(height: 10),
                DetailRow(label: 'Pronostic Durée', value: duree!),
                SizedBox(height: 10),
                DetailRow(
                    label: 'Pronostic Vainqueur', value: nomCompletVainqueur),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
