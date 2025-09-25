//
// AppLocalizations: Loads and provides localized strings for the app.
// Supports English, Sinhala, and Tamil.
//

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Loads and provides localized strings for the current locale
class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  /// Delegate for Flutter localization system
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// Gets localization instance from widget tree
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// Loads language JSON file and parses translations
  Future<bool> load() async {
    final langCode = locale.languageCode;
    final path =
        'assets/language/${langCode == "si"
            ? "si"
            : langCode == "ta"
            ? "ta"
            : "en"}.json';
    final jsonString = await rootBundle.loadString(path);
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    return true;
  }

  /// Translates a key to the localized string
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

// Delegate for loading and supporting localizations
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  /// Supported language codes
  @override
  bool isSupported(Locale locale) =>
      ['en', 'si', 'ta'].contains(locale.languageCode);

  /// Loads localization for the given locale
  @override
  Future<AppLocalizations> load(Locale locale) async {
    var localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  /// Reloading is not required for this delegate
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
