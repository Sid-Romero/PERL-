import 'package:flutter/material.dart';
import 'package:flutter_responsive_login_ui/main_page.dart';
import 'package:flutter_responsive_login_ui/pallete.dart';
import 'package:flutter_responsive_login_ui/widgets/gradient_button.dart';
import 'package:flutter_responsive_login_ui/widgets/login_field.dart';
import 'package:flutter_responsive_login_ui/widgets/social_button.dart';
import 'package:flutter_responsive_login_ui/signin_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_responsive_login_ui/Models/Users.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  

  final _formfield = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool passToggle = true;
  bool isLoading = false; // Ajout de la variable isLoading

  //Définition de la méthode de connexion
  var jsonResponse;
  Future<bool> LogIn(String loginValue, String pass) async {
    String url = "http://localhost:5000/api/users/login";
    Map body = {"email": loginValue, "motDePasse": pass, "pseudo": loginValue};
    print(body);

    var res = await http.Client().post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: json.encode(body));
    if (res.statusCode == 200) {
      print("Response status: ${res.statusCode}");
      var jsonResponse = res.body;
      print(jsonResponse);
      var data = json.decode(jsonResponse);

      int success = data['success'];
      String message = data['message'];

      if (success == 1) {
        var userData = data['data'];

        //Récupération et stockage des données de l'utilisateur
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('id', userData['id']);
        prefs.setString('nom', userData['nom']);
        prefs.setString('prenom', userData['prenom']);
        prefs.setString('email', userData['email']);
        prefs.setString('pseudo', userData['pseudo']);
        prefs.setInt('point', userData['point']);

        //test
        print(prefs.getString('nom'));
        print(prefs.getString('prenom'));

        if (prefs.getString('nom') != null &&
            prefs.getString('prenom') != null &&
            prefs.getString('email') != null &&
            prefs.getString('pseudo') != null &&
            prefs.getInt('point') != null) {
          return true;
        }
        //Debug
        // int id = userData['id'];
        // String? nom = userData['nom'];
        // String? prenom = userData['prenom'];
        // int? point = userData['point'];
        // print('ID: $id');
        // print('Nom: $nom');
        // print('Prénom: $prenom');
        // print('point: $point');
      } else {
        print('La connexion a échoué. Message: $message');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('errorMessage', message);
        return false;
      }
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
              children: [
                const SizedBox(height: 80),
                const Text(
                  'Bon retour !',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 50,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 50),

                const SizedBox(height: 15),

                //email input
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: "Email ou pseudo",
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
                      return "Entrez un email ou pseudo valide";
                    }
                    // if (!isValidEmail(value)) {
                    //   return "Entrez un email valide";
                    // }
                  },
                ),
                SizedBox(
                  height: 24,
                ),
                //password input

                TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: passwordController,
                    obscureText: !passToggle,
                    style: TextStyle(color: Colors.black),
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
                      if (value!.isEmpty) {
                        return "Entrez un mot de passe";
                      }
                    }),

                SizedBox(height: 60),

                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (_formfield.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });

                            bool isLoggedIn = await LogIn(
                              emailController.text,
                              passwordController.text,
                            );

                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            if (isLoggedIn) {
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

                              final snackBar = SnackBar(
                                content: Text(errorMessage!),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              );

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }

                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(395, 55),
                    backgroundColor: isLoading
                        ? Pallete.gradient1.withOpacity(0.8)
                        : Pallete.gradient1,
                    shadowColor: Colors.transparent,
                  ),
                  child: AnimatedOpacity(
                    opacity: isLoading ? 0.5 : 1.0,
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
                          builder: (context) => const RegistrationScreen()),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 24.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Pas de compte ? ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: 'Créez-en un !',
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

  bool isValidLoginPassword(String password) {
    return !(password.isEmpty);
  }
}
