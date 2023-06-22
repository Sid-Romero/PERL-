import 'package:flutter/material.dart';
import 'package:flutter_responsive_login_ui/pallete.dart';

class NavBar extends StatelessWidget {
  final String? pseudo;
  final String? email;

  const NavBar({
    required this.pseudo,
    required this.email,
  });
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(pseudo!),
            accountEmail: Text(email!),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.network(
                  'https://oflutter.com/wp-content/uploads/2021/02/girl-profile.png',
                  fit: BoxFit.cover,
                  width: 90,
                  height: 90,
                ),
              ),
            ),
            decoration: BoxDecoration(color: Pallete.gradient2),
          ),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text('Favoris'),
            onTap: () => null,
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('Liste des combats'),
            onTap: () => null,
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Historique de vos pronostics'),
            onTap: () => null,
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            trailing: ClipOval(
              child: Container(
                color: Colors.red,
                width: 20,
                height: 20,
                child: Center(
                  child: Text(
                    '8',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Paramètres'),
            onTap: () => null,
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text('Confidentialité'),
            onTap: () => null,
          ),
          Divider(),
          ListTile(
            title: Text('Déconnexion'),
            leading: Icon(Icons.exit_to_app),
            onTap: () => null,
          ),
        ],
      ),
    );
  }
}
