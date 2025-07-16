import 'dart:html' as html;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void loadGoogleMapsScript() {
  final existing = html.document.querySelector('#google-maps');
  if (existing != null) return; // ya cargado

  final script = html.ScriptElement()
    ..id = 'google-maps'
    ..src = 'https://maps.googleapis.com/maps/api/js?key=${dotenv.env['GOOGLE_MAPS_API_KEY']}'
    ..type = 'text/javascript'
    ..async = true;
  html.document.body?.append(script);
}