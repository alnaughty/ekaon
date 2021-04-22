import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_map_location_picker/generated/i18n.dart' as location_picker;

class LocalizationAuth {
  final Iterable<LocalizationsDelegate<dynamic>> delegates = [
    location_picker.S.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate
  ];

  final Iterable<Locale> supportedLocales = [
    const Locale('en', ''),
    const Locale.fromSubtags(languageCode: 'us')
  ];
}