import 'package:flutter/material.dart';
import 'package:flutter_responsive_login_ui/Models/Pronostic.dart';
import 'package:flutter_responsive_login_ui/widgets/pronosticView/cardModel.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AllPronostics extends StatefulWidget {
  final int combatId;

  AllPronostics({required this.combatId});

  @override
  _AllPronosticsState createState() => _AllPronosticsState();
}

class _AllPronosticsState extends State<AllPronostics> {
  List<Pronostic> pronosticsList = [];

  @override
  void initState() {
    super.initState();
    _fetchPronostics();
  }

  Future<void> _fetchPronostics() async {
    try {
      List<Pronostic> pronostics =
          await fetchPronosticsForCombat(widget.combatId);
      setState(() {
        pronosticsList = pronostics;
      });
    } catch (error) {
      print('Erreur lors de la récupération des pronostics : $error');
    }
  }

  Future<List<Pronostic>> fetchPronosticsForCombat(int combatId) async {
    String url = "http://localhost:5000/api/pronostics/combat";
    Map body = {"combat": combatId};
    print(body);
    var response = await http.Client().post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: json.encode(body));

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == 0) {
        // Le combat n'a pas de pronostic
        return [];
      } else {
        final pronosticsData = responseData['data'] as List<dynamic>;

        List<Pronostic> pronostics = pronosticsData
            .map((data) => Pronostic(
                  idPronostic: data['idPronostic'],
                  datePronostic: DateTime.parse(data['datePronostic']),
                  pronostiqueur: data['pronostiqueur'],
                  combat: data['combat'],
                  duree: data['duree'],
                  vainqueur: data['vainqueur'],
                  statut: data['statut'],
                  prenom_vainqueur: data['prenom_vainqueur'],
                  nom_vainqueur: data['nom_vainqueur'],
                  pseudo: data['pseudo'],
                ))
            .toList();
        setState(() {
          pronosticsList = pronostics;
        });
        return pronostics;
      }
    } else {
      throw Exception('Failed to fetch pronostics ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (pronosticsList.isEmpty) {
      // Aucun pronostic, afficher un message personnalisé
      return Center(
        child: Text(
          "Aucun pronostic disponible pour ce combat.",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      // Afficher la liste des pronostics dans un ListView
      return ListView.builder(
        itemCount: pronosticsList.length,
        itemBuilder: (context, index) {
          final pronostic = pronosticsList[index];
          return PronosticCard(pronosticData: pronostic);
        },
      );
    }
  }
}
