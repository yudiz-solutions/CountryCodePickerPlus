import 'package:country_code_picker_plus/country_code_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const AppWrapper());
}

List<Locale> list = const [
  Locale('af'), // Afrikaans
  Locale('am'), // Amharic
  Locale('ar'), // Arabic
  Locale('az'), // Azerbaijani
  Locale('be'), // Belarusian
  Locale('bg'), // Bulgarian
  Locale('bn'), // Bengali
  Locale('bs'), // Bosnian
  Locale('ca'), // Catalan
  Locale('cs'), // Czech
  Locale('da'), // Danish
  Locale('de'), // German
  Locale('el'), // Greek
  Locale('en'), // English
  Locale('es'), // Spanish
  Locale('et'), // Estonian
  Locale('fa'), // Persian
  Locale('fi'), // Finnish
  Locale('fr'), // French
  Locale('gl'), // Galician
  Locale('ha'), // Hausa
  Locale('he'), // Hebrew
  Locale('hi'), // Hindi
  Locale('hr'), // Croatian
  Locale('hu'), // Hungarian
  Locale('hy'), // Armenian
  Locale('id'), // Indonesian
  Locale('is'), // Icelandic
  Locale('it'), // Italian
  Locale('ja'), // Japanese
  Locale('ka'), // Georgian
  Locale('kk'), // Kazakh
  Locale('km'), // Khmer
  Locale('ko'), // Korean
  Locale('ku'), // Kurdish
  Locale('ky'), // Kyrgyz
  Locale('lt'), // Lithuanian
  Locale('lv'), // Latvian
  Locale('mk'), // Macedonian
  Locale('ml'), // Malayalam
  Locale('mn'), // Mongolian
  Locale('ms'), // Malay
  Locale('nb'), // Norwegian Bokmål
  Locale('nl'), // Dutch
  Locale('nn'), // Norwegian Nynorsk
  Locale('no'), // Norwegian
  Locale('pl'), // Polish
  Locale('ps'), // Pashto
  Locale('pt'), // Portuguese
  Locale('ro'), // Romanian
  Locale('ru'), // Russian
  Locale('sd'), // Sindhi
  Locale('sk'), // Slovak
  Locale('sl'), // Slovenian
  Locale('so'), // Somali
  Locale('sq'), // Albanian
  Locale('sr'), // Serbian
  Locale('sv'), // Swedish
  Locale('ta'), // Tamil
  Locale('tg'), // Tajik
  Locale('th'), // Thai
  Locale('tk'), // Turkmen
  Locale('tr'), // Turkish
  Locale('tt'), // Tatar
  Locale('uk'), // Ukrainian
  Locale('ug'), // Uyghur
  Locale('ur'), // Urdu
  Locale('uz'), // Uzbek
  Locale('vi'), // Vietnamese
  Locale('zh'), // Chinese
];

// Wrapper widget to manage app state
class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  // Static method to access the state
  static AppWrapperState of(BuildContext context) {
    return context.findAncestorStateOfType<AppWrapperState>()!;
  }

  @override
  State<AppWrapper> createState() => AppWrapperState();
}

class AppWrapperState extends State<AppWrapper> {
  Locale _locale = const Locale('en');

  // Method to change the locale
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyApp(locale: _locale);
  }
}

// Main app widget
class MyApp extends StatelessWidget {
  final Locale locale;

  const MyApp({
    super.key,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Country Picker Demo',
      locale: locale,
      // Use the passed locale
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        // Required material delegates
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        // Your country localizations
        CountryLocalizations.delegate,
      ],
      supportedLocales: list,
      home: const Example(),
    );
  }
}

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  Locale currentLocale = const Locale('en');

  String message = "";
  String _selectedCountryCode1 = '+1';

  Country? _selectedCountry;

  bool _isPhoneNumberValid = false;

  Future<void> _validatePhoneNumber(String value, String countryCode) async {
    try {
      final isValid = await PhoneService.parsePhoneNumber(value, countryCode);
      _isPhoneNumberValid = isValid ?? false;
    } catch (e) {
      _isPhoneNumberValid = false;
    }
  }

  _printCountryCode(Country? country) {
    if (country != null) {
      debugPrint(country.name);
      debugPrint(country.code);
      debugPrint(country.dialCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Country Code Picker Example'),
        actions: [
          // Language switcher
          PopupMenuButton<Locale>(
              onSelected: (Locale locale) {
                setState(() {
                  currentLocale = locale;
                });
                // Update app locale
                AppWrapper.of(context).setLocale(locale);
              },
              itemBuilder: (BuildContext context) => list
                  .map((local) => PopupMenuItem<Locale>(
                        value: local,
                        child: Text(local.languageCode.toUpperCase()),
                      ))
                  .toList()),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'TextField 1 (default):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _buildTextField(CountryCodePicker(
                onChanged: (country) {
                  setState(() {
                    _selectedCountryCode1 = country.dialCode ?? '';
                  });
                  _printCountryCode(country);
                },
                initialSelection: 'US',
                favorite: [_selectedCountryCode1],
                showFlag: true,
                showDropDownButton: true,
              )),
              const SizedBox(height: 20),
              const Text(
                'TextField 2 (dropdown):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _buildTextField(
                CountryCodePicker(
                  mode: CountryCodePickerMode.dropdown,
                  onChanged: (country) {
                    _printCountryCode(country);
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'TextField 3 (dialog):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _buildTextField(
                CountryCodePicker(
                  mode: CountryCodePickerMode.dialog,
                  onChanged: (country) {
                    _printCountryCode(country);
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'TextField 4 (bottomSheet):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _buildTextField(
                CountryCodePicker(
                  mode: CountryCodePickerMode.bottomSheet,
                  onChanged: (country) {
                    _printCountryCode(country);
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'TextField 5 (show flag):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _buildTextField(
                CountryCodePicker(
                  onChanged: (country) {
                    _printCountryCode(country);
                  },
                  initialSelection: 'IN',
                  showFlag: true,
                  showCountryOnly: true,
                  showOnlyCountryWhenClosed: true,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'TextField 6 (searchable):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _buildTextField(
                CountryCodePicker(
                  onChanged: (country) {
                    _printCountryCode(country);
                  },
                  initialSelection: 'BR',
                  showFlag: true,
                  showCountryOnly: true,
                  showOnlyCountryWhenClosed: true,
                  searchDecoration: const InputDecoration(
                    labelText: 'Search country',
                    hintText: 'Start typing to search',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'TextField 7 (hide main text):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _buildTextField(
                CountryCodePicker(
                  onChanged: (country) {
                    _printCountryCode(country);
                  },
                  initialSelection: 'CA',
                  hideMainText: true,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'TextField 8 (hide search field):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _buildTextField(
                CountryCodePicker(
                  onChanged: (country) {
                    _printCountryCode(country);
                  },
                  initialSelection: 'AU',
                  showFlag: true,
                  showCountryOnly: true,
                  showOnlyCountryWhenClosed: true,
                  showDropDownButton: true,
                  showFlagDialog: true,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'TextField 9 (align left):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _buildTextField(
                CountryCodePicker(
                  onChanged: (country) {
                    _printCountryCode(country);
                  },
                  initialSelection: 'FR',
                  alignLeft: true,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'TextField 10 (specific country only):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _buildTextField(
                CountryCodePicker(
                  onChanged: (country) {
                    _printCountryCode(country);
                  },
                  initialSelection: 'JP',
                  favorite: ['+81'],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'TextField 11 (with text style):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _buildTextField(
                CountryCodePicker(
                  onChanged: (country) {
                    _printCountryCode(country);
                  },
                  initialSelection: 'NG',
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'TextField 12 (dark mode):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _buildTextField(
                CountryCodePicker(
                  onChanged: (country) {
                    _printCountryCode(country);
                  },
                  initialSelection: 'GB',
                  dialogBackgroundColor: Colors.black,
                  dialogTextStyle: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'TextField 13 (custom border):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _buildTextField(
                CountryCodePicker(
                  onChanged: (country) {
                    _printCountryCode(country);
                  },
                  initialSelection: 'ZA',
                  boxDecoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'TextField 13 (change dropdown icon):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              _buildTextField(
                CountryCodePicker(
                  onChanged: (country) {
                    _printCountryCode(country);
                  },
                  mode: CountryCodePickerMode.dropdown,
                  initialSelection: 'ZA',
                  boxDecoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  icon: const Icon(Icons.expand_more),
                  iconDisabledColor: Colors.grey,
                  iconEnabledColor: Colors.black,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'TextFormField 14 (phone number validation):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Form(
                autovalidateMode: AutovalidateMode.always,
                child: TextFormField(
                    onChanged: (value) {
                      if (_selectedCountry != null) {
                        _validatePhoneNumber(value, _selectedCountry!.code);
                      }
                    },
                    textAlign: TextAlign.start,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                        hintText: '(123) 456-7890',
                        prefixIcon: CountryCodePicker(
                          onInit: (Country? country) {
                            _selectedCountry = country;
                          },
                          onChanged: (Country? country) {
                            _selectedCountry = country;
                          },
                          // flag can be styled with BoxDecoration's `borderRadius` and `shape` fields
                          flagDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                          ),
                          initialSelection: 'IN',
                        )),
                    style: Theme.of(context).textTheme.labelLarge,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      PhoneNumberFormatter(),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }

                      if (!_isPhoneNumberValid) {
                        return 'Invalid phone number';
                      }

                      return null;
                    }),
              ),
              const SizedBox(height: 20),
              const Text(
                'Custom TextField 15 (input with country code):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              PhoneInputField(
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    hintText: '91 123-456-7890',
                  ),
                  onPhoneNumberValidated: (isValid, phoneNUmber) {
                    if (isValid) {
                      debugPrint('Phone number: ${phoneNUmber!.number}');
                      debugPrint(
                          'Internationalized phone number: ${phoneNUmber.internationalizedPhoneNumber}');
                      debugPrint('ISO code: ${phoneNUmber.toString()}');

                      message = 'Valid phone number ${phoneNUmber.toString()}';
                    } else {
                      debugPrint('Invalid phone number');
                      message = 'Invalid phone number';
                    }
                    setState(() {});
                  }),
              Text(message),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(Widget prefixIcon) {
    return TextField(
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        PhoneNumberFormatter(),
      ],
      textAlign: TextAlign.start,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        hintText: 'Enter phone number',
      ),
    );
  }
}
