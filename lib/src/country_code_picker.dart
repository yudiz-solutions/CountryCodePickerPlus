import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:country_code_picker_plus/src/constants.dart';
import 'package:country_code_picker_plus/src/country_code_picker_dialog.dart';

import 'country.dart';

enum CountryCodePickerMode { dialog, dropdown, bottomSheet }

class CountryCodePicker extends StatefulWidget {
  final ValueChanged<Country>? onChanged;
  final ValueChanged<Country?>? onInit;
  final String? initialSelection;
  final List<String> favorite;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;
  final bool showCountryOnly;
  final InputDecoration searchDecoration;
  final TextStyle? searchStyle;
  final TextStyle? dialogTextStyle;
  final WidgetBuilder? emptySearchBuilder;
  final Function(Country?)? builder;
  final bool enabled;
  final TextOverflow textOverflow;
  final Icon closeIcon;

  /// Barrier color of ModalBottomSheet
  final Color? barrierColor;

  /// Background color of ModalBottomSheet
  final Color? backgroundColor;

  /// BoxDecoration for dialog
  final BoxDecoration? boxDecoration;

  /// the size of the selection dialog
  final Size? dialogSize;

  /// Background color of selection dialog
  final Color? dialogBackgroundColor;

  /// used to customize the country list
  final List<String>? countryFilter;

  /// shows the name of the country instead of the dialcode
  final bool showOnlyCountryWhenClosed;

  /// aligns the flag and the Text left
  ///
  /// additionally this option also fills the available space of the widget.
  /// this is especially useful in combination with [showOnlyCountryWhenClosed],
  /// because longer country names are displayed in one line
  final bool alignLeft;

  /// shows the flag
  final bool showFlag;

  final bool hideMainText;

  final bool? showFlagMain;

  final bool? showFlagDialog;

  /// Width of the flag images
  final double flagWidth;

  /// Use this property to change the order of the options
  final Comparator<Country>? comparator;

  /// Set to true if you want to hide the search part
  final bool hideSearch;

  /// Set to true if you want to hide the close icon dialog
  final bool hideCloseIcon;

  /// Set to true if you want to show drop down button
  final bool showDropDownButton;

  /// [BoxDecoration] for the flag image
  final Decoration? flagDecoration;

  /// An optional argument for injecting a list of countries
  /// with customized codes.
  final List<Map<String, String>> countryList;

  final EdgeInsetsGeometry dialogItemPadding;

  final EdgeInsetsGeometry searchPadding;
  final CountryCodePickerMode mode;

  const CountryCodePicker({
    this.onChanged,
    this.onInit,
    this.initialSelection,
    this.favorite = const [],
    this.textStyle,
    this.padding = const EdgeInsets.all(8.0),
    this.showCountryOnly = false,
    this.searchDecoration = const InputDecoration(),
    this.searchStyle,
    this.dialogTextStyle,
    this.emptySearchBuilder,
    this.showOnlyCountryWhenClosed = false,
    this.alignLeft = false,
    this.showFlag = true,
    this.showFlagDialog,
    this.hideMainText = false,
    this.showFlagMain,
    this.flagDecoration,
    this.builder,
    this.flagWidth = 32.0,
    this.enabled = true,
    this.textOverflow = TextOverflow.ellipsis,
    this.barrierColor,
    this.backgroundColor,
    this.boxDecoration,
    this.comparator,
    this.countryFilter,
    this.hideSearch = false,
    this.hideCloseIcon = false,
    this.showDropDownButton = false,
    this.dialogSize,
    this.dialogBackgroundColor,
    this.closeIcon = const Icon(Icons.close),
    this.countryList = countryCodes,
    this.dialogItemPadding =
        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    this.searchPadding = const EdgeInsets.symmetric(horizontal: 24),
    super.key,
    this.mode = CountryCodePickerMode.dialog,
  });

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() {
    List<Map<String, String>> jsonList = countryList;

    List<Country> elements =
        jsonList.map((json) => Country.fromJson(json)).toList();

    if (comparator != null) {
      elements.sort(comparator);
    }

    if (countryFilter != null && countryFilter!.isNotEmpty) {
      final uppercaseCustomList =
          countryFilter!.map((criteria) => criteria.toUpperCase()).toList();
      elements = elements
          .where((criteria) =>
              uppercaseCustomList.contains(criteria.code) ||
              uppercaseCustomList.contains(criteria.name) ||
              uppercaseCustomList.contains(criteria.dialCode))
          .toList();
    }

    return CountryCodePickerState(elements);
  }
}

class CountryCodePickerState extends State<CountryCodePicker> {
  Country? selectedItem;
  List<Country> elements = [];
  List<Country> favoriteElements = [];

  CountryCodePickerState(this.elements);

  @override
  Widget build(BuildContext context) {
    Widget internalWidget;

    if (widget.mode == CountryCodePickerMode.dropdown) {
      return DropdownButtonHideUnderline(
        child: DropdownButton<Country>(
          iconSize: widget.showDropDownButton ? 24.0 : 0.0,
          value: selectedItem,
          style: widget.textStyle ?? Theme.of(context).textTheme.labelLarge,
          items: elements
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Padding(
                      padding: widget.padding,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.showFlag)
                            Container(
                              margin: const EdgeInsets.only(right: 8.0),
                              decoration: widget.flagDecoration,
                              clipBehavior: widget.flagDecoration == null
                                  ? Clip.none
                                  : Clip.hardEdge,
                              child: Image.asset(
                                e.flagUri,
                                package: 'country_code_picker_plus',
                                width: widget.flagWidth,
                              ),
                            ),
                          Text(
                            e.toString(),
                            style: widget.textStyle ??
                                Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
          onChanged: widget.enabled
              ? (Country? value) {
                  selectedItem = value;
                  if (selectedItem != null) {
                    _publishSelection(selectedItem!);
                  }
                }
              : null,
        ),
      );
    }

    if (widget.builder != null) {
      internalWidget = InkWell(
        onTap: widget.enabled ? showCountryCodePickerDialog : null,
        child: widget.builder!(selectedItem),
      );
    } else {
      internalWidget = InkWell(
        onTap: widget.enabled ? showCountryCodePickerDialog : null,
        child: Padding(
          padding: widget.padding,
          child: Flex(
            direction: Axis.horizontal,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (widget.showFlagMain != null
                  ? widget.showFlagMain!
                  : widget.showFlag)
                Flexible(
                  flex: widget.alignLeft ? 0 : 1,
                  fit: widget.alignLeft ? FlexFit.tight : FlexFit.loose,
                  child: Container(
                    clipBehavior: widget.flagDecoration == null
                        ? Clip.none
                        : Clip.hardEdge,
                    decoration: widget.flagDecoration,
                    margin: widget.alignLeft
                        ? const EdgeInsets.only(right: 16.0, left: 8.0)
                        : const EdgeInsets.only(right: 16.0),
                    child: Image.asset(
                      selectedItem!.flagUri,
                      package: 'country_code_picker_plus',
                      width: widget.flagWidth,
                    ),
                  ),
                ),
              if (!widget.hideMainText)
                Flexible(
                  fit: widget.alignLeft ? FlexFit.tight : FlexFit.loose,
                  child: Text(
                    widget.showOnlyCountryWhenClosed
                        ? selectedItem!.toCountryStringOnly()
                        : selectedItem.toString(),
                    style: widget.textStyle ??
                        Theme.of(context).textTheme.labelLarge,
                    overflow: widget.textOverflow,
                  ),
                ),
              if (widget.showDropDownButton)
                Flexible(
                  flex: widget.alignLeft ? 0 : 1,
                  fit: widget.alignLeft ? FlexFit.tight : FlexFit.loose,
                  child: Padding(
                      padding: widget.alignLeft
                          ? const EdgeInsets.only(right: 16.0, left: 8.0)
                          : const EdgeInsets.only(right: 16.0),
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey,
                        size: widget.flagWidth,
                      )),
                ),
            ],
          ),
        ),
      );
    }
    return internalWidget;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _onInit(selectedItem);
  }

  @override
  void didUpdateWidget(CountryCodePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialSelection != widget.initialSelection) {
      if (widget.initialSelection != null) {
        selectedItem = elements.firstWhere(
            (criteria) =>
                (criteria.code.toUpperCase() ==
                    widget.initialSelection!.toUpperCase()) ||
                (criteria.dialCode == widget.initialSelection) ||
                (criteria.name.toUpperCase() ==
                    widget.initialSelection!.toUpperCase()),
            orElse: () => elements[0]);
      } else {
        selectedItem = elements[0];
      }
      _onInit(selectedItem);
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.initialSelection != null) {
      selectedItem = elements.firstWhere(
          (item) =>
              (item.code.toUpperCase() ==
                  widget.initialSelection!.toUpperCase()) ||
              (item.dialCode == widget.initialSelection) ||
              (item.name.toUpperCase() ==
                  widget.initialSelection!.toUpperCase()),
          orElse: () => elements[0]);
    } else {
      selectedItem = elements[0];
    }

    favoriteElements = elements
        .where((item) =>
            widget.favorite.firstWhereOrNull((criteria) =>
                item.code.toUpperCase() == criteria.toUpperCase() ||
                item.dialCode == criteria ||
                item.name.toUpperCase() == criteria.toUpperCase()) !=
            null)
        .toList();
  }

  Future<dynamic> _showCountryCodeBottomSheet() async {
    return await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return CountryCodePickerDialog(
            elements,
            favoriteElements,
            showCountryOnly: widget.showCountryOnly,
            emptySearchBuilder: widget.emptySearchBuilder,
            searchDecoration: widget.searchDecoration,
            searchStyle: widget.searchStyle,
            textStyle: widget.dialogTextStyle,
            boxDecoration: widget.boxDecoration,
            showFlag: widget.showFlagDialog ?? widget.showFlag,
            flagWidth: widget.flagWidth,
            size: widget.dialogSize,
            backgroundColor: widget.dialogBackgroundColor,
            barrierColor: widget.barrierColor,
            hideSearch: widget.hideSearch,
            hideCloseIcon: widget.hideCloseIcon,
            closeIcon: widget.closeIcon,
            flagDecoration: widget.flagDecoration,
            dialogItemPadding: widget.dialogItemPadding,
            searchPadding: widget.searchPadding,
          );
        });
  }

  Future<dynamic> _showCountryCodeDialog() async {
    return await showDialog(
      barrierColor: widget.barrierColor ?? Colors.grey.withOpacity(0.5),
      context: context,
      builder: (context) => Center(
        child: Dialog(
          child: CountryCodePickerDialog(
            elements,
            favoriteElements,
            showCountryOnly: widget.showCountryOnly,
            emptySearchBuilder: widget.emptySearchBuilder,
            searchDecoration: widget.searchDecoration,
            searchStyle: widget.searchStyle,
            textStyle: widget.dialogTextStyle,
            boxDecoration: widget.boxDecoration,
            showFlag: widget.showFlagDialog ?? widget.showFlag,
            flagWidth: widget.flagWidth,
            size: widget.dialogSize,
            backgroundColor: widget.dialogBackgroundColor,
            barrierColor: widget.barrierColor,
            hideSearch: widget.hideSearch,
            hideCloseIcon: widget.hideCloseIcon,
            closeIcon: widget.closeIcon,
            flagDecoration: widget.flagDecoration,
            dialogItemPadding: widget.dialogItemPadding,
            searchPadding: widget.searchPadding,
          ),
        ),
      ),
    );
  }

  void showCountryCodePickerDialog() async {
    dynamic item;
    switch (widget.mode) {
      case CountryCodePickerMode.dialog:
        item = await _showCountryCodeDialog();
        break;

      case CountryCodePickerMode.bottomSheet:
        item = await _showCountryCodeBottomSheet();
        break;
      case CountryCodePickerMode.dropdown:
        break;
    }
    if (item != null) {
      setState(() {
        selectedItem = item;
      });

      _publishSelection(item);
    }
  }

  void _publishSelection(Country countryCode) {
    if (widget.onChanged != null) {
      widget.onChanged!(countryCode);
    }
  }

  void _onInit(Country? countryCode) {
    if (widget.onInit != null) {
      widget.onInit!(countryCode);
    }
  }
}
