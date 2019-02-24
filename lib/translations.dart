import 'package:flutter/material.dart';

class Translations {
  Translations(this.locale);

  final Locale locale;

  static Translations of(BuildContext context) {
    return Localizations.of<Translations>(context, Translations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'Sync Images & Videos',

      'homeTitle': "Home",

      'Ok': "Ok",

      'thumbnailsChecking': 'Checking thumbnails',
      'thumbnailsCreating': 'Creating thumbnails',

      'permissionOpenSettings': 'Open settings',
      'permissionRequiredTitle': 'Permission',
      'permissionReadExternalStorageRequiredText': 'The app will not work if you do not allow it to read from external storage',
    },
    'sv': {
      'appName': 'Synchronisera Bilder & Videos',

      'homeTitle': "Hem",

      'Ok': "Ok",

      'thumbnailsChecking': 'Kontrollerar thumbnails',
      'thumbnailsCreating': 'Skapar thumbnails',

      'permissionOpenSettings': 'Öppna inställningar',
      'permissionRequiredTitle': 'Tillåtelse',
      'permissionReadExternalStorageRequiredText': 'Appen fungerar inte om du inte tillåter den att läsa från extern lagring',
    },
  };

  String get appName {
    return _localizedValues[locale.languageCode]['appName'];
  }

  String get homeTitle {
    return _localizedValues[locale.languageCode]['homeTitle'];
  }

  String get Ok {
    return _localizedValues[locale.languageCode]['Ok'];
  }

  String get thumbnailsChecking {
    return _localizedValues[locale.languageCode]['thumbnailsChecking'];
  }
  String get thumbnailsCreating {
    return _localizedValues[locale.languageCode]['thumbnailsCreating'];
  }

  String get permissionOpenSettings {
    return _localizedValues[locale.languageCode]['permissionOpenSettings'];
  }
  String get permissionRequiredTitle {
    return _localizedValues[locale.languageCode]['permissionRequiredTitle'];
  }
  String get permissionReadExternalStorageRequiredText {
    return _localizedValues[locale.languageCode]['permissionReadExternalStorageRequiredText'];
  }
}