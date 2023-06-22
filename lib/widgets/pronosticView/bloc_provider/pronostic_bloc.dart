import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

//Ici se fait la vérification de si, oui ou non, un utilisateur a déjà fait un pronostic

class PronosticVerificationBloc extends Cubit<bool> {
  PronosticVerificationBloc() : super(false);

  Future<void> verifyPronostic(int idPronostiqueur, int idCombat) async {
    String url = "http://localhost:5000/api/pronostics/verification";
    Map body = {"id": idPronostiqueur, "combat": idCombat};
  
    var response = await http.Client().post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: json.encode(body));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      // print(responseData);
      final success = responseData['success'];
      // print(success);

      if (success == 1) {
        emit(true);
      } else {
        emit(false);
      }
    }
  }
  void changePronostic(bool success) {
  emit(success);
}

}
