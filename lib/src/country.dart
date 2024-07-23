class Country {
  final String name;

  final String flagUri;

  final String code;

  final String dialCode;

  Country(
      {this.name = "", this.code = "", this.flagUri = "", this.dialCode = ""});

  @override
  String toString() => dialCode;

  String toLongString() => "$dialCode ${toCountryStringOnly()}";

  String toCountryStringOnly() {
    return '$_cleanName';
  }

  String? get _cleanName {
    return name.replaceAll(RegExp(r'[[\]]'), '').split(',').first;
  }

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
        name: json['en_short_name'],
        code: json['alpha_2_code'],
        dialCode: json['dial_code'],
        flagUri: 'assets/flags/${json['alpha_2_code'].toLowerCase()}.png');
  }
}
