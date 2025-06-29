import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState {
  final String? username;
  final int themeColor;
  final String? currency;

  AppState({
    this.username,
    required this.themeColor,
    this.currency,
  });

  static Future<AppState> getState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int themeColor = prefs.getInt("themeColor") ?? Colors.green.value;
    final String? username = prefs.getString("username");
    final String? currency = prefs.getString("currency");
    return AppState(
      username: username,
      themeColor: themeColor,
      currency: currency,
    );
  }

  AppState copyWith({
    String? username,
    int? themeColor,
    String? currency,
  }) {
    return AppState(
      username: username ?? this.username,
      themeColor: themeColor ?? this.themeColor,
      currency: currency ?? this.currency,
    );
  }
}

class AppCubit extends Cubit<AppState> {
  AppCubit(AppState initialState) : super(initialState);

  Future<void> updateUsername(String username) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("username", username);
    emit(await AppState.getState());
  }

  Future<void> updateCurrency(String currency) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("currency", currency);
    emit(await AppState.getState());
  }

  Future<void> updateThemeColor(int color) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("themeColor", color);
    emit(await AppState.getState());
  }

  Future<void> reset() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("currency");
    await prefs.remove("themeColor");
    await prefs.remove("username");
    emit(await AppState.getState());
  }
}