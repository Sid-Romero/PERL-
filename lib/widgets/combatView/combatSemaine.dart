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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CombatSemaine extends StatefulWidget {
  final User user;
  final Combat combat;
  CombatSemaine({required this.user, required this.combat});

  @override
  _CombatSemaineState createState() => _CombatSemaineState();
}

class _CombatSemaineState extends State<CombatSemaine> {
  List<Combat> combats = []; // Variable pour stocker les combats
  final PronosticVerificationBloc pronosticBloc = PronosticVerificationBloc();

  // Création d'un stream qui émettra la durée restante à intervalles réguliers
  Stream<Duration> countdownStream() {
    DateTime now = DateTime.now();
    DateTime combatDate = DateTime.parse(widget.combat.dateCombat.toString());
    Duration initialDuration = combatDate.difference(now);

    return Stream.periodic(Duration(seconds: 1), (count) {
      DateTime currentTime = DateTime.now();
      Duration remainingDuration = combatDate.difference(currentTime);

      return remainingDuration;
    });
  }

  @override
  Widget build(BuildContext context) {
    int id = widget.user.id!;
    Combat CombatData = widget.combat;
    final statut_pronostic = CombatData.statut_pronostic;
    print(statut_pronostic);

    String nomCompletLutteur1 =
        '${CombatData.prenomLutteur1} ${CombatData.nomLutteur1}';
    String nomCompletLutteur2 =
        '${CombatData.prenomLutteur2} ${CombatData.nomLutteur2}';
    DateTime date = CombatData.dateCombat;
    String formattedDate = DateFormat('dd/MM/yyyy')
        .format(date); // Format personnalisé, ex: 20/06/2023

    //Si le combat est toujours pronostiquable alors on affiche
    //soit les options de pronostics si l'utilisateur n'a pas encore pronostiqué
    //soit la liste des pronostics concernant ce combat
    if (statut_pronostic == "ouvert") {
      return Column(
        children: [
          //Annonce du combat de la semaine
          Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(nomCompletLutteur1,
                        style: TextStyle(color: Pallete.blackColor)),
                    Text(nomCompletLutteur2,
                        style: TextStyle(color: Pallete.blackColor)),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage('path/to/photo1.jpg'),
                      radius: 30.0,
                    ),
                    Column(
                      children: [
                        Text(formattedDate,
                            style: TextStyle(color: Pallete.blackColor)),
                        SizedBox(height: 12.0),
                        Text('Il vous reste',
                            style: TextStyle(color: Pallete.blackColor)),
                        SizedBox(height: 12.0),
                        StreamBuilder<Duration>(
                          stream: countdownStream(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              Duration remainingDuration = snapshot.data!;

                              // Extraire les heures, les minutes et les secondes de la durée restante
                              int remainingHours = remainingDuration.inHours;
                              int remainingMinutes =
                                  remainingDuration.inMinutes.remainder(60);
                              int remainingSeconds =
                                  remainingDuration.inSeconds.remainder(60);

                              return Text(
                                '$remainingHours heures, $remainingMinutes minutes, $remainingSeconds secondes',
                                style: TextStyle(color: Colors.red),
                              );
                            } else {
                              return Text(
                                'Chargement du temps restant...',
                                style: TextStyle(color: Pallete.blackColor),
                              );
                            }
                          },
                        )
                      ],
                    ),
                    CircleAvatar(
                      backgroundImage: AssetImage('path/to/photo2.jpg'),
                      radius: 30.0,
                    ),
                  ],
                ),
              ],
            ),
          ),

          //On invoque ici l'affichage en fonction de si ou non l'utilisateur a un pronostic en cours
          BlocProvider(
            create: (context) =>
                pronosticBloc..verifyPronostic(id, CombatData.idCombat),
            child: BlocBuilder<PronosticVerificationBloc, bool>(
              builder: (context, success) {
                if (success == true) {
                  // Afficher la vue lorsque success == true
                  return PronosticDetailsCard(
                      user: widget.user, premierCombat: CombatData);
                } else {
                  // Afficher la vue lorsque success == false
                  return PronosticOptions(
                      user: widget.user, premierCombat: CombatData);
                }
              },
            ),
          ),
        ],
      );
    } else {
      return AllPronostics(combatId: CombatData.idCombat);
    }
  }
}
