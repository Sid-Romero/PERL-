import 'package:flutter/material.dart';
import 'package:flutter_responsive_login_ui/pallete.dart';
import 'package:flutter_responsive_login_ui/widgets/pronosticView/allPronostics.dart';
import 'package:flutter_responsive_login_ui/widgets/pronosticView/pronostic_card.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_responsive_login_ui/Models/CombatSemaine.dart';
import 'package:flutter_responsive_login_ui/Models/Users.dart';
import 'package:flutter_responsive_login_ui/Models/Pronostic.dart';
import 'package:flutter_responsive_login_ui/widgets/pronosticView/pronostic_options.dart';
import 'package:flutter_responsive_login_ui/widgets/pronosticView/bloc_provider/pronostic_bloc.dart';
import 'package:flutter_responsive_login_ui/widgets/combatView/combatSemaine.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TabCombat extends StatefulWidget {
  final User user;
  TabCombat({required this.user});

  @override
  _TabCombatState createState() => _TabCombatState();
}

class _TabCombatState extends State<TabCombat> {
  bool isLoading = true;
  List<Combat> combats = []; // Variable pour stocker les combats
  final PronosticVerificationBloc pronosticBloc = PronosticVerificationBloc();
  int _currentIndex = 0;
  PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    getCombatDeLaSemaine().then((List<Combat> combatsData) {
      setState(() {
        combats = combatsData; // Mettre à jour les combats
        isLoading = false; // Masquer l'animation de chargement
      });
    }).catchError((error) {
      print("Erreur lors de la récupération des combats : $error");
      // Gérer l'erreur en cas d'échec de la requête
      setState(() {
        isLoading = false; // Masquer l'animation de chargement en cas d'erreur
      });
    });
  }

  Future<List<Combat>> getCombatDeLaSemaine() async {
    String url = "http://localhost:5000/api/combats/combat";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'];

        List<Combat> combats = data.map((item) {
          return Combat(
              idCombat: item['idCombat'],
              idLutteur1: item['id_lutteur1'],
              idLutteur2: item['id_lutteur2'],
              nomLutteur1: item['nom_lutteur1'],
              prenomLutteur1: item['prenom_lutteur1'],
              nomLutteur2: item['nom_lutteur2'],
              prenomLutteur2: item['prenom_lutteur2'],
              vainqueur: item['vainqueur'],
              dateCombat: DateTime.parse(item['dateCombat']),
              pointDuCombat: item['pointDuCombat'],
              lieu: item['lieu'],
              typeVictoire: item['type_victoire'],
              typeCombat: item['typeCombat'],
              dureeCombat: item['dureeCombat'],
              statut_pronostic: item['statut_pronostic']);
        }).toList();
        print(combats);
        return combats;
      } else {
        throw Exception(
            'Erreur lors de la requête GET : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la requête GET : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(), // Animation de chargement
      );

      //S'il n'y a qu'un seul combat en cours de pronostic
    } else if (combats.length == 1) {
      return CombatSemaine(user: widget.user, combat: combats[0]);
    } else if (combats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(
              'svgs/oops.svg',
              width: 600,
              height: 600,
            ),
            Text(
              'Aucun combat en cours... Veuillez revenir plus tard pour pronostiquer !',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    //S'il y a plus d'un combat en cours de pronostic
    else {
      return Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: combats.map((combat) {
            return CombatSemaine(user: widget.user, combat: combat);
          }).toList(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              _pageController.animateToPage(
                index,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            });
          },
          items: combats.asMap().entries.map((entry) {
            // Crée un élément de navigation pour chaque combat avec l'ordre du combat
            int index = entry.key + 1;
            Combat combat = entry.value;
            return BottomNavigationBarItem(
              icon: Icon(
                Icons.sports_mma,
                color: Colors.white, // Couleur blanche pour l'icône
              ),
              activeIcon: Icon(
                Icons.sports_mma,
                color: Pallete
                    .gradient3, // Couleur verte pour les icônes sélectionnées
              ),
              label: 'Combat $index',
            );
          }).toList(),
          selectedItemColor: Pallete
              .gradient3, // Couleur verte pour l'élément de navigation sélectionné
          unselectedItemColor: Colors
              .white, // Couleur blanche pour les autres éléments de navigation
          backgroundColor: Pallete
              .gradient1, // Couleur marron foncé pour l'arrière-plan du BottomNavigationBar
        ),
      );
    }
  }
}
