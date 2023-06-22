class User {
  int? id;
  String? nom;
  String? prenom;
  String? email;
  String? pseudo;
  int? points;
  User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.pseudo,
    required this.points,
  });

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   data['email'] = this.email;
  //   data['username'] = this.username;
  //   return data;
  // }
}
