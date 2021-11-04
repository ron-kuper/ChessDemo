import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OpeningPlayer {
  OpeningPlayer.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      name = json['name'];
      rating = json['rating'];
    }
  }

  String? name;
  int? rating;
}

class OpeningGame {
  OpeningGame.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      id = json['id'];
      winner = json['winner'];
      white = OpeningPlayer.fromJson(json['white']);
      black = OpeningPlayer.fromJson(json['black']);
      year = json['year'];
      month = json['month'];
    }
  }

  String? id;
  String? winner;
  OpeningPlayer? white;
  OpeningPlayer? black;
  int? year;
  String? month;
}

class OpeningMove {
  OpeningMove.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      uci = json['uci'];
      san = json['san'];
      averageRating = json['averageRating'];
      white = json['white'];
      draws = json['draws'];
      black = json['black'];
      game = OpeningGame.fromJson(json['game']);
    }
  }

  String? uci;
  String? san;
  int? averageRating;
  int? white;
  int? draws;
  int? black;
  OpeningGame? game;
}

class OpeningInfo {
  OpeningInfo.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      eco = json['eco'];
      name = json['name'];
    }
  }

  String? eco;
  String? name;
}

class Openings {
  Openings();

  static Future<Openings>? fetchOpenings(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return Openings.fromJson(jsonDecode(response.body));
    } else {
      debugPrint('Fetch failed, code = ' + response.statusCode.toString());
      throw Exception('Fetch failed');
    }
  }

  Openings.fromJson(Map<String, dynamic> json) {
    white = json['white'];
    draws = json['draws'];
    black = json['black'];
    moves = <OpeningMove>[];
    json['moves'].forEach((m) => moves!.add(OpeningMove.fromJson(m)));
    topGames = <OpeningGame>[];
    json['topGames'].forEach((g) => topGames!.add(OpeningGame.fromJson(g)));
    opening = OpeningInfo.fromJson(json['opening']);
  }

  int? white;
  int? draws;
  int? black;
  List<OpeningMove>? moves;
  List<OpeningGame>? topGames;
  OpeningInfo? opening;
}
