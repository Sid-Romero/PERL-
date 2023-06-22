import 'package:flutter/material.dart';
import 'package:flutter_responsive_login_ui/widgets/gradient_button.dart';
import 'package:flutter_responsive_login_ui/widgets/login_field.dart';
import 'package:flutter_responsive_login_ui/widgets/social_button.dart';
import 'package:flutter_responsive_login_ui/login_screen.dart';
import 'package:flutter_responsive_login_ui/pallete.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_responsive_login_ui/Models/Users.dart';
import 'package:flutter_responsive_login_ui/main_page.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formfield = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final pseudoController = TextEditingController();
  final numberController = TextEditingController();
  bool passToggle = true;
  bool isLoading = false;

  Future<bool> signIn(String email, String pass, String nomComplet,
      String? numeroTel, String pseudo) async {
    String url = "http://localhost:5000/api/users";
    //Récupération du nom et du prénom

    //On sépare les groupes de mots
    var arrayNom = nomComplet.split(' ');

    //Normalement, le dernier mot constitue le nom
    String nom = arrayNom[arrayNom.length - 1];

    //On récupère le reste des autres groupes de mots sauf le dernier qui représente le nom
    String prenom = arrayNom.sublist(0, arrayNom.length - 1).join(' ');

    Map body = {
      "email": email,
      "motDePasse": pass,
      "prenom": prenom,
      "nom": nom,
      "numeroTel": numeroTel,
      "pseudo": pseudo
    };
    print(body);

    var res = await http.Client().post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: json.encode(body));
    print("Response status: ${res.statusCode}");
    var jsonResponse = res.body;
    print(jsonResponse);
    var data = json.decode(jsonResponse);

    int success = data['success'];
    String message = data['message'];
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (res.statusCode == 200) {
      if (success == 1) {
        var userData = data['data'];
        //Récupération et stockage des données de l'utilisateur
        prefs.setInt('id', userData['id']);
        prefs.setString('nom', userData['nom']);
        prefs.setString('prenom', userData['prenom']);
        prefs.setString('email', userData['email']);
        prefs.setString('pseudo', userData['pseudo']);
        prefs.setInt('point', userData['point']);

        if (prefs.getString('nom') != null &&
            prefs.getString('prenom') != null &&
            prefs.getString('email') != null &&
            prefs.getString('pseudo') != null &&
            prefs.getInt('point') != null) {
          return true;
        }
        return false;
      } else {
        message = "Erreur lors de l'inscription";
        prefs.setString('errorMessage', message);
        return false;
      }
      //debug
      // String? nom = data['nom'];
      // String? prenom = data['prenom'];
      // String? point = data['point'];
      // print('Nom: $nom');
      // print('Prénom: $prenom');
      // print('Point: $point');
    } else {
      prefs.setString('errorMessage', message);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formfield,
            child: Column(
              mainAxisAlignment: MainAxisAlignment
                  .center, // Centrer les éléments verticalement
              children: [
                SizedBox(
                  height: 32,
                ),
                const Text(
                  'Inscription',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 50,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  height: 36,
                ),

                TextFormField(
                    keyboardType: TextInputType.name,
                    controller: nameController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: "Nom complet",
                      labelStyle: TextStyle(color: Pallete.gradient3),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people, color: Pallete.gradient3),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Pallete.gradient1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Pallete.borderColor),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Entrez un nom complet";
                      }
                      if (!isValidFullName(value.trim())) {
                        return "Entrez un nom complet valide";
                      }
                    }),
                SizedBox(
                  height: 24,
                ),

                TextFormField(
                  keyboardType: TextInputType.name,
                  controller: pseudoController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: "Pseudo",
                    labelStyle: TextStyle(color: Pallete.gradient3),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.people, color: Pallete.gradient3),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Pallete.gradient1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Pallete.borderColor),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Entrez un pseudonyme";
                    }
                  },
                ),

                SizedBox(
                  height: 24,
                ),

                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: Pallete.gradient3),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email, color: Pallete.gradient3),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Pallete.gradient1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Pallete.borderColor),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Entrez un email";
                    }
                    if (!isValidEmail(value.trim())) {
                      return "Entrez un email valide";
                    }
                  },
                ),
                SizedBox(
                  height: 24,
                ),
                //password input

                TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    obscureText: !passToggle,
                    style: TextStyle(color: Colors.black),
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: "Mot de passe",
                      labelStyle: TextStyle(color: Pallete.gradient3),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock, color: Pallete.gradient3),
                      suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            passToggle = !passToggle;
                          });
                        },
                        child: Icon(passToggle
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Pallete.gradient1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Pallete.borderColor),
                      ),
                    ),
                    validator: (value) {
                      final valueTrimmed = value!.trim();
                      if (value!.isEmpty) {
                        return "Entrez un mot de passe";
                      } else if (valueTrimmed.length < 6)
                        return "Le mot de passe doit contenir au moins 6 caractères !";
                    }),

                SizedBox(
                  height: 24,
                ),

                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: numberController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: "Numéro de téléphone",
                    labelStyle: TextStyle(color: Pallete.gradient3),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone, color: Pallete.gradient3),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Pallete.gradient1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Pallete.borderColor),
                    ),
                  ),
                ),

                SizedBox(height: 60),

                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (_formfield.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });

                            bool isRegistered = await signIn(
                              emailController.text,
                              passwordController.text,
                              nameController.text,
                              numberController.text,
                              pseudoController.text,
                            );

                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            if (isRegistered) {
                              int? id = prefs.getInt('id');
                              String? nom = prefs.getString('nom');
                              String? prenom = prefs.getString('prenom');
                              String? email = prefs.getString('email');
                              String? pseudo = prefs.getString('pseudo');
                              int? point = prefs.getInt('point');

                              User user = User(
                                id: id,
                                nom: nom,
                                prenom: prenom,
                                email: email,
                                pseudo: pseudo,
                                points: point,
                              );

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MainPage(user: user)),
                              );
                            } else {
                              String? errorMessage =
                                  prefs.getString('errorMessage');

                              if (errorMessage ==
                                      "L\'adresse email existe déjà." ||
                                  errorMessage ==
                                      "Le pseudo est déjà utilisé.") {
                                final snackBar = SnackBar(
                                  content: Text(errorMessage!),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  action: SnackBarAction(
                                    label: "Se connecter",
                                    onPressed: () {
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen());
                                    },
                                  ),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              } else {
                                final snackBar = SnackBar(
                                  content: Text(errorMessage!),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            }

                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(395, 55),
                    backgroundColor: isLoading
                        ? Pallete.gradient1.withOpacity(0.5)
                        : Pallete.gradient1,
                    shadowColor: Colors.transparent,
                  ),
                  child: AnimatedOpacity(
                    opacity: isLoading ? 0.8 : 1.0,
                    duration: Duration(milliseconds: 300),
                    child: isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Commencer',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                            ),
                          ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 24.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Déjà un compte ? ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: 'Connectez-vous !',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool isValidEmail(String email) {
    RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool isValidFullName(String fullName) {
    RegExp nameRegex = RegExp(r'^[a-zA-Z-]+\s[a-zA-Z-]+$');

    // Vérifier si la chaîne ne contient que des lettres ou des tirets et des espaces
    return nameRegex.hasMatch(fullName);
  }
}
