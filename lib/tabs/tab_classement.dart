import 'package:flutter/material.dart';
import 'package:flutter_responsive_login_ui/pallete.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_responsive_login_ui/Models/Users.dart';
import 'package:flutter_responsive_login_ui/Models/Pronostic.dart';
import 'package:flutter_responsive_login_ui/widgets/pronosticView/cardModel.dart';

class TabClassement extends StatefulWidget {
  const TabClassement({Key? key}) : super(key: key);

  @override
  _TabClassementState createState() => _TabClassementState();
}

class _TabClassementState extends State<TabClassement> {
  @override
  final List<Map<String, dynamic>> _allUsers = [];
  List<Pronostic> pronosticsList = [];
  bool loadingModal =
      false; //Variable pour l'affichage du chargement dans le Modal

  @override
  initState() {
    super.initState();
    fetchData(); // Appel de la fonction pour récupérer les utilisateurs et les stocker dans _allUsers
  }

  Future<void> fetchData() async {
    await fetchUsers(); // Attendre que fetchUsers() se termine

    setState(() {
      _foundUsers = List.from(
          _allUsers); // Mettre à jour _foundUsers avec les utilisateurs récupérés
    });
  }

//Méthode pour récupérer l'historique des utilisateurs
  Future<List<Pronostic>> fetchPronosticsByPseudo(String pseudo) async {
    String url = "http://localhost:5000/api/pronostics/pseudo";
    Map body = {"pseudo": pseudo};
    print(body);
    var response = await http.Client().post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: json.encode(body));

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == 0) {
        // Cet utilisateur n'a pas de pronostic
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

  Future<void> fetchUsers() async {
    final response =
        await http.get(Uri.parse("http://localhost:5000/api/users"));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final users = jsonResponse['data'];
      print(users);

      for (var user in users) {
        final userData = {
          'rang': user['rang'],
          'pseudo': user['pseudo'],
          'points': user['point']
        };
        print(userData);
        _allUsers.add(userData);
      }
    } else {
      print("Erreur lors de la récupération des utilisateurs");
    }
  }

  // This list holds the data for the list view
  List<Map<String, dynamic>> _foundUsers = [];
  // @override
  // initState() {
  //   fetchUsers();
  //   _foundUsers = _allUsers;

  //   super.initState();
  // }

  // This function is called whenever the text field changes
  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = _allUsers;
    } else {
      results = _allUsers
          .where((user) => user["pseudo"]
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    setState(() {
      _foundUsers = results;
    });

    print(_foundUsers.length);
  }

  Widget build(BuildContext context) {
    final ffem = 1.2; // Facteur d'échelle de police personnalisé
    final fem = 16.0; // Taille de police de base
    return Column(
      children: [
        // Container(
        //   //permet d'ajouter un margin à l'élément Row
        //   margin: EdgeInsets.only(top: 24.0),
        //   child: Row(
        //     //englobe la barre de recherche et l'option de tri
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     mainAxisAlignment: MainAxisAlignment.spaceAround,
        //     children: [
        //       Text("Classement selon le ranking PERL",
        //           style: TextStyle(
        //               fontSize: 14 * ffem,
        //               fontWeight: FontWeight.w500,
        //               color: Colors.black)),
        //       Icon(
        //         Icons.sort,
        //         color: Colors.black,
        //       )
        //     ],
        //   ),
        // ),
        const SizedBox(
          height: 20,
        ),

        TextField(
            onChanged: (value) => _runFilter(value),
            style: TextStyle(color: Pallete.blackColor),
            decoration: const InputDecoration(
              labelText: 'Rechercher un pronostiqueur',
              suffixIcon: Icon(Icons.search, color: Pallete.blackColor),
              labelStyle: TextStyle(
                color: Pallete.blackColor, // Changer la couleur du texte ici
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Pallete.gradient3),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Pallete.blackColor),
              ),
            ),
            cursorColor: Pallete.gradient2),
        const SizedBox(
          height: 20,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView.builder(
              itemCount: _foundUsers.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _showCardModal(_foundUsers[index]);
                  },
                  child: Card(
                    key: ValueKey(_foundUsers[index]["rang"]),
                    color: Pallete.gradient2,
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: Text(
                        _foundUsers[index]["rang"].toString(),
                        style:
                            const TextStyle(fontSize: 24, color: Colors.white),
                      ),
                      title: Text(
                        _foundUsers[index]["pseudo"],
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                          '${_foundUsers[index]["points"].toString()} points',
                          style: TextStyle(color: Colors.white)),
                      trailing: _foundUsers[index]["profileImageUrl"] != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(
                                  _foundUsers[index]["profileImageUrl"]),
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        )
      ],
    );
  }

  //Pour afficher les informations sur les pronostiqueurs lorsqu'on clique sur leur cartes
  void _showCardModal(Map<String, dynamic> cardInfo) {
    // Appel de la fonction pour charger les pronostics
    setState(() {
      loadingModal = true; // Activer le chargement du modal
    });

    fetchPronosticsByPseudo(cardInfo["pseudo"]).then((pronostics) {
      setState(() {
        loadingModal = false; // Désactiver le chargement du modal
      });
      // fetchPronosticsByPseudo(cardInfo["pseudo"]);
      showDialog(
        context: context,
        builder: (context) {
          return Theme(
            data: ThemeData(
              dialogBackgroundColor:
                  Colors.white, // Couleur de fond du dialog en blanc
            ),
            child: Dialog(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Text(
                              "${cardInfo["rang"]}.",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${cardInfo["pseudo"]}.",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ]),
                          Text(
                            "${cardInfo["points"]} points",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Divider(color: Colors.grey),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "Palmarès",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Vainqueurs trouvés"),
                          Text("Durée trouvées"),
                        ],
                      ),
                      Divider(color: Colors.grey),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "Historique",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (loadingModal)
                        CircularProgressIndicator(), // Afficher l'animation de chargement
                      if (!loadingModal)
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: pronosticsList.length,
                          itemBuilder: (context, index) {
                            final pronostic = pronosticsList[index];
                            return PronosticCard(pronosticData: pronostic);
                          },
                        ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Fermer"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Pallete.gradient1, // Couleur de fond du bouton
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }).catchError((error) {
      setState(() {
        loadingModal =
            false; // Désactiver le chargement du modal en cas d'erreur
      });

      // Gérer l'erreur
    });
  }
}
