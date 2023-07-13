import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_responsive_login_ui/Models/Users.dart';
import 'package:flutter_responsive_login_ui/Models/CombatSemaine.dart';
import 'package:flutter_responsive_login_ui/Models/Pronostic.dart';
import 'package:flutter_responsive_login_ui/pallete.dart';
import 'package:flutter_responsive_login_ui/widgets/pronosticView/pronostic_dureeRadio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_responsive_login_ui/widgets/pronosticView/bloc_provider/DurationCubit.dart';
import 'package:flutter_responsive_login_ui/widgets/pronosticView/bloc_provider/LutteurCubit.dart';
import 'package:flutter_responsive_login_ui/widgets/gradient_button.dart';
import 'package:quickalert/quickalert.dart';

class PronosticDetailsCard extends StatefulWidget {
  final User user;
  final Combat premierCombat;

  PronosticDetailsCard({required this.user, required this.premierCombat});

  @override
  _PronosticDetailsCardState createState() => _PronosticDetailsCardState();
}

class _PronosticDetailsCardState extends State<PronosticDetailsCard> {
  void _showResultModal(String result, String message) {
    if (result == "success") {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: "Bravo !",
          text: message,
          // autoCloseDuration: Duration(seconds: 3),
          confirmBtnColor: Pallete.blackColor);
    } else if (result == "error") {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: "Désolé!",
          text: message,
          // autoCloseDuration: Duration(seconds: 3),
          confirmBtnColor: Pallete.borderColor);
    }
  }

  Pronostic? pronostic; // Ajout de la variable pronostic

  static Future<bool> isModifiablePronostic(int idCombat) async {
    String url = "http://localhost:5000/api/pronostics/combat";
    Map body = {"combat": idCombat};
    print(body);
    var response = await http.Client().post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: json.encode(body));
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final pronosticData = responseData['data'];
      print(pronosticData);
      if (responseData['success'] == 1 && pronosticData.isNotEmpty) {
        final firstPronostic = pronosticData[0];
        if (firstPronostic['statut_pronostic'] == "ouvert") {
          return true;
        } else {
          return false;
        }
      }
    }
    return false;
  }

  static Future<Pronostic?> getPronosticById(
      int idPronostiqueur, int idCombat) async {
    String url = "http://localhost:5000/api/pronostics/verification";
    Map body = {"id": idPronostiqueur, "combat": idCombat};
    print(body);
    var response = await http.Client().post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: json.encode(body));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final pronosticData = responseData['data'];
      print(pronosticData);
      if (responseData['success'] == 1 && pronosticData.isNotEmpty) {
        final firstPronostic = pronosticData[0];
        return Pronostic(
            idPronostic: firstPronostic['idPronostic'],
            datePronostic: DateTime.parse(firstPronostic['datePronostic']),
            pronostiqueur: firstPronostic['pronostiqueur'],
            combat: firstPronostic['combat'],
            duree: firstPronostic['duree'],
            vainqueur: firstPronostic['vainqueur'],
            prenom_vainqueur: firstPronostic['prenom_vainqueur'],
            nom_vainqueur: firstPronostic['nom_vainqueur'],
            statut: firstPronostic['statut_pronostic']);
      }
    }
    return null;
  }

  Future<bool> updatePronostic(
      pronostic_duree, pronostic_vainqueur, idPronostic) async {
    String url = "http://localhost:5000/api/pronostics/";
    Map body = {
      "duree": pronostic_duree,
      "vainqueur": pronostic_vainqueur,
      "idPronostic": idPronostic
    };
    print(body);
    var response = await http.Client().patch(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: json.encode(body));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['success'] == 1) {
        // La mise à jour a réussi
        print('Mise à jour réussie');
        // Mettre à jour la carte avec les nouvelles données
        final updatedPronostic = await getPronosticById(
            widget.user.id!, widget.premierCombat.idCombat);
        if (updatedPronostic != null) {
          setState(() {
            pronostic = updatedPronostic;
          });
          return true;
        }
      } else {
        // La mise à jour a échoué
        print('Échec de la mise à jour');
        return false;
      }
    } else {
      // Erreur lors de la requête
      print('Erreur lors de la requête');
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Pronostic?>(
      future: getPronosticById(widget.user.id!, widget.premierCombat.idCombat),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Afficher un indicateur de chargement pendant que la requête est en cours
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Afficher un message d'erreur si une erreur s'est produite lors de la requête
          return Text('Erreur : ${snapshot.error}');
        } else if (snapshot.hasData) {
          pronostic = snapshot.data!;
          //Variable pour vérifier si le pronostic est modifiable ou non
          bool isModifiable = pronostic!.statut == "ouvert";

          //Variable pour récupérer le nom complet du vainqueur désigné
          final nomComplet_vainqueur =
              '${pronostic!.prenom_vainqueur} ${pronostic!.nom_vainqueur}';
          //Variable pour la durée désignée dans le pronostic
          String selectedDuration =
              pronostic!.duree!; // Variable pour stocker la durée sélectionnée
          //Variable pour stocker le nom du lutteur désigné dans le pronostic
          String selectedLutteur = pronostic!.prenom_vainqueur!;
          int selectedVainqueur = pronostic!.vainqueur!;
          //Variable indiquant les combattants qui s'opposent
          String cardTitle =
              '${widget.premierCombat.prenomLutteur1} VS ${widget.premierCombat.prenomLutteur2}';

          return Card(
            color: Colors.white70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    cardTitle,
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
                      DetailRow(label: 'Pseudo', value: widget.user.pseudo!),
                      DetailRow(
                          label: 'Date/heure',
                          value: pronostic!.datePronostic.toString()),
                      DetailRow(
                          label: 'Pronostic Durée', value: pronostic!.duree!),
                      DetailRow(
                          label: 'Pronostic Vainqueur',
                          value: nomComplet_vainqueur),
                    ],
                  ),
                ),
                if (isModifiable) // Afficher le bouton uniquement si le statut est "modifiable"
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                              ),
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: 72.0),
                                //Menu déroulant pour le choix du nom du lutteur
                                BlocProvider<LutteurCubit>(
                                  create: (context) =>
                                      LutteurCubit(selectedLutteur),
                                  child: BlocBuilder<LutteurCubit, String>(
                                    builder: (context, lutteurState) {
                                      selectedLutteur =
                                          lutteurState; // Met à jour la variable lors du changement d'état

                                      if (selectedLutteur ==
                                          widget.premierCombat.prenomLutteur1) {
                                        selectedVainqueur =
                                            widget.premierCombat.idLutteur1;
                                      } else {
                                        selectedVainqueur =
                                            widget.premierCombat.idLutteur2;
                                      }

                                      return DropdownButtonFormField<String>(
                                        value: selectedLutteur,
                                        onChanged: (String? newValue) {
                                          context
                                              .read<LutteurCubit>()
                                              .updateLutteur(newValue!);
                                        },
                                        items: [
                                          DropdownMenuItem<String>(
                                            value: widget
                                                .premierCombat.prenomLutteur1,
                                            child: Text(widget
                                                .premierCombat.nomLutteur1),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: widget
                                                .premierCombat.prenomLutteur2,
                                            child: Text(widget
                                                .premierCombat.prenomLutteur2),
                                          ),
                                        ],
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.black),
                                        dropdownColor: Colors.grey,
                                        icon: Icon(Icons.arrow_drop_down_circle,
                                            color: Pallete.gradient2),
                                        decoration: InputDecoration(
                                          labelText: "Vainqueur du combat",
                                          labelStyle: TextStyle(
                                              color: Pallete.gradient1),
                                          prefixIcon: Icon(Icons.emoji_events,
                                              color: Pallete.gradient1),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Pallete.gradient1),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Pallete.borderColor),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                SizedBox(height: 64.0),

                                BlocProvider<DurationCubit>(
                                  create: (context) => DurationCubit(),
                                  child: BlocBuilder<DurationCubit, String>(
                                    builder: (context, durationState) {
                                      selectedDuration =
                                          durationState; // Met à jour la variable lors du changement d'état
                                      return DurationDropdown(
                                        defaultDuration: pronostic!.duree,
                                        onDurationChanged: (String? newValue) {
                                          context
                                              .read<DurationCubit>()
                                              .updateDuration(newValue!);
                                        },
                                      );
                                    },
                                  ),
                                ),

                                SizedBox(height: 32.0),

                                GradientButton(
                                  text: 'Enregistrer Modification',
                                  onPressed: () async {
                                    // Action à effectuer lors du clic sur le bouton "Enregistrer Modification"
                                    isModifiable = await isModifiablePronostic(
                                        widget.premierCombat.idCombat);
                                    print(isModifiable);
                                    if (isModifiable) {
                                      bool isUpdated = await updatePronostic(
                                          selectedDuration,
                                          selectedVainqueur,
                                          pronostic!.idPronostic);
                                      if (isUpdated) {
                                        setState(() {});
                                        Navigator.pop(
                                            context); // Ferme le Modal
                                      }
                                    } else {
                                      //Le pronostic n'est plus modifiable
                                      _showResultModal("error",
                                          "Pronostics clos pour ce combat !");
                                      setState(() {});
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Text('Modifier pronostic'),
                  ),
              ],
            ),
          );
        } else {
          // Aucun pronostic trouvé
          return Text('Aucun pronostic trouvé.');
        }
      },
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
