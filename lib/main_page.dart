import 'package:flutter/material.dart';
import 'package:flutter_responsive_login_ui/pallete.dart';
import 'package:flutter_responsive_login_ui/tabs/tab_classement.dart';
import 'package:flutter_responsive_login_ui/tabs/tab_combat.dart';
import 'package:flutter_responsive_login_ui/widgets/gradient_button.dart';
import 'package:flutter_responsive_login_ui/widgets/login_field.dart';
import 'package:flutter_responsive_login_ui/widgets/social_button.dart';
import 'package:flutter_responsive_login_ui/signin_screen.dart';
import 'package:flutter_responsive_login_ui/widgets/NavBar.dart';
import 'package:flutter_responsive_login_ui/Models/Users.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MainPage extends StatelessWidget {
  final User user;

  MainPage({required this.user});


  @override
  Widget build(BuildContext context) {
    final ffem = 1.2; // Facteur d'échelle de police personnalisé
    final fem = 16.0; // Taille de police de base

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          drawer: NavBar(pseudo: user.pseudo, email: user.email),
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "PERL",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "${user.pseudo}",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      "${user.points} points",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              TabBar(
                indicatorColor: Pallete.gradient3,
                unselectedLabelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
                tabs: [
                  Tab(
                      child: Text(
                    "Pronostic",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Pallete.blackColor,
                    ),
                  )),
                  Tab(
                      child: Text(
                    "Classement",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Pallete.blackColor),
                  ))
                ],
              ),
              Expanded(
                child: TabBarView(children: [
                  //Section combats
                  TabCombat(user: user),

                  //Section classement
                  TabClassement()
                ]),
              ),
            ],
          ),
        ));
  }
}
