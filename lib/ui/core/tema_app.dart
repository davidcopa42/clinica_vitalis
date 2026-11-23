import 'package:flutter/material.dart';

/// Temas claro y oscuro de la app.
abstract final class TemaApp {
  static const colorSemilla = Colors.blue;

  static final claro = ThemeData(colorSchemeSeed: colorSemilla);

  static final oscuro = ThemeData(
    colorSchemeSeed: colorSemilla,
    brightness: Brightness.dark,
  );
}
