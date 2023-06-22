import 'package:flutter/material.dart';
import 'package:flutter_responsive_login_ui/pallete.dart';
import 'package:quickalert/quickalert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_responsive_login_ui/Models/CombatSemaine.dart';
import 'package:flutter_responsive_login_ui/Models/Users.dart';
import 'package:flutter_responsive_login_ui/widgets/pronosticView/bloc_provider/pronostic_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PronosticOptions extends StatefulWidget {
  final User user;
  final Combat premierCombat;

  PronosticOptions({required this.user, required this.premierCombat});

  @override
  _PronosticOptionsState createState() => _PronosticOptionsState();
}

class _PronosticOptionsState extends State<PronosticOptions> {
  //Variable pour les boutons de votes du vainqueur du combat
  int selectedButton = 0;
  //Variable pour savoir si l'utilisateur a au moins sélectionné un vainqueur
  bool hasSelectedWinner = false;

  void _onWinnerSelected() {
    setState(() {
      hasSelectedWinner = true;
    });
  }

  //Variable vis-à-vis de la durée du combat
  String selectedDuration = 'Moins d\'une minute';
  List<String> durationList = [
    'Moins d\'une minute',
    '1 à 2 minutes',
    '2 à 3 minutes',
    '3 à 4 minutes',
    '4 à 5 minutes',
    'Plus de 5 minutes',
  ];

  void _showResultModal(String result) {
    if (result == "success") {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: "Bravo !",
          text: 'Pronostic réalisé avec succès !',
          // autoCloseDuration: Duration(seconds: 3),
          confirmBtnColor: Pallete.blackColor);
    } else if (result == "error") {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.warning,
          title: "Attention!",
          text: 'Choisissez au moins un vainqueur !',
          // autoCloseDuration: Duration(seconds: 3),
          confirmBtnColor: Pallete.borderColor);
    }
  }

  Future<bool> createPronostic(
      int idPronostiqueur, int idCombat, int winner, String duration) async {
    // Créer un objet contenant les données à envoyer à l'API
    Map<String, dynamic> data = {
      'vainqueur': winner,
      'duree': duration,
      'pronostiqueur': idPronostiqueur, // Remplacez par l'id de l'utilisateur
      'combat': idCombat, // Remplacez par l'id du combat
    };

    // Convertir les données en format JSON
    String jsonData = jsonEncode(data);
    print(jsonData);

    // Envoyer les données à l'API via une requête POST
    String url = 'http://localhost:5000/api/pronostics/';
    var response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'}, body: jsonData);

    // Vérifier le code de statut de la réponse
    if (response.statusCode == 200) {
      // Succès : les données ont été envoyées à l'API
      print('Pronostic créé avec succès');
      return true;
    } else {
      // Erreur : la requête n'a pas abouti
      print('Erreur lors de la création du pronostic : ${response.statusCode}');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    const int maxCharacterLimit = 15; // Limite maximale de caractères
    String buttonText1 =
        '${widget.premierCombat.prenomLutteur1} ${widget.premierCombat.nomLutteur1}';
    if (buttonText1.length > maxCharacterLimit) {
      buttonText1 = buttonText1.substring(0, maxCharacterLimit) + '...';
    }

    String buttonText2 =
        '${widget.premierCombat.prenomLutteur2} ${widget.premierCombat.nomLutteur2}';
    if (buttonText2.length > maxCharacterLimit) {
      buttonText2 = buttonText2.substring(0, maxCharacterLimit) + '...';
    }
    PronosticVerificationBloc pronosticBloc =
        context.read<PronosticVerificationBloc>();
    return Column(children: [
      //_______________Partie pronostics_________________

      //diviseur -vainqueur-
      Container(
        padding: EdgeInsets.all(16.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Divider(
              color: Colors.grey,
              height: 1.0,
              thickness: 1.0,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Vainqueur',
                style: TextStyle(
                  backgroundColor: Pallete.backgroundColor,
                  color: Pallete.blackColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      //Boutons pour connaître le vainqueur

      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (selectedButton == 2) {
                      selectedButton = 0; // Annuler la sélection
                    } else {
                      selectedButton = 2; // Sélectionner le bouton 1
                    }
                  });
                  _onWinnerSelected();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(150, 50),
                  primary: selectedButton == 2
                      ? Pallete.borderColor
                      : Pallete.gradient1,
                  side: BorderSide(color: Pallete.gradient1),
                ),
                child: Text(
                  buttonText1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize:
                        16, // Ajustez la taille de la police selon vos besoins
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (selectedButton == 3) {
                      selectedButton = 0; // Annuler la sélection
                    } else {
                      selectedButton = 3; // Sélectionner le bouton 2
                    }
                  });
                  _onWinnerSelected();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(150, 50),
                  primary: selectedButton == 3
                      ? Pallete.borderColor
                      : Pallete.gradient1,
                  side: BorderSide(color: Pallete.gradient1),
                ),
                child: Text(
                  buttonText2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize:
                        16, // Ajustez la taille de la police selon vos besoins
                  ),
                ),
              ),
            ],
          )
        ],
      ),

      //divisieur -duree-

      Container(
        padding: EdgeInsets.all(16.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Divider(
              color: Colors.grey,
              height: 1.0,
              thickness: 1.0,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Durée du combat',
                style: TextStyle(
                  backgroundColor: Pallete.backgroundColor,
                  color: Pallete.blackColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),

      //dropdown -duree-
      DropdownButtonFormField<String>(
        value: selectedDuration,
        onChanged: (String? newValue) {
          setState(() {
            selectedDuration = newValue!;
          });
        },
        items: [
          DropdownMenuItem<String>(
            value: 'Non voté',
            child: Text('Non voté'),
          ),
          ...durationList.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ],
        style: TextStyle(fontSize: 16.0, color: Colors.black),
        dropdownColor: Colors.grey,
        icon: Icon(Icons.arrow_drop_down_circle, color: Pallete.gradient2),
        decoration: InputDecoration(
          labelText: "Durée du combat",
          labelStyle: TextStyle(color: Pallete.borderColor),
          prefixIcon: Icon(Icons.schedule_rounded, color: Pallete.gradient1),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Pallete.gradient1),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Pallete.borderColor),
          ),
        ),
      ),
      // Boutons pour pronostiquer

      Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: ElevatedButton(
          onPressed: () async {
            if (hasSelectedWinner) {
              // Récupérer le lutteur sélectionné
              int winner = widget.premierCombat.idLutteur1;
              if (selectedButton == 2) {
                int winner = widget.premierCombat.idLutteur2;
              }

              // Récupérer la durée sélectionnée
              String? duree = selectedDuration;

              // Appeler la fonction createPronostic
              bool successPronostique = await createPronostic(
                widget.user.id!,
                widget.premierCombat.idCombat,
                winner,
                duree,
              );
              if (successPronostique) {
                // Afficher le modal
                _showResultModal("success");
                pronosticBloc.changePronostic(true);
              } else {
                _showResultModal("error");
                pronosticBloc.changePronostic(false);
              }
            }
          },
          child: Text('Pronostiquer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Pallete.gradient2,
            minimumSize: Size(200, 50),
          ),
        ),
      ),
    ]);
  }
}
