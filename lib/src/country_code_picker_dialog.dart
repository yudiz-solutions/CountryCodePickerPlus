import 'package:flutter/material.dart';

import 'country.dart';

/// CountryCodePicker dialog used for selection of the country code
class CountryCodePickerDialog extends StatefulWidget {
  final List<Country> elements;
  final bool? showCountryOnly;
  final InputDecoration searchDecoration;
  final TextStyle? searchStyle;
  final TextStyle? textStyle;
  final BoxDecoration? boxDecoration;
  final WidgetBuilder? emptySearchBuilder;
  final bool? showFlag;
  final double flagWidth;
  final Decoration? flagDecoration;
  final Size? size;
  final bool hideSearch;
  final bool hideCloseIcon;
  final Icon? closeIcon;

  /// Background color of CountryCodePickerDialog
  final Color? backgroundColor;

  /// Boxshaow color of CountryCodePickerDialog that matches CountryCodePicker barrier color
  final Color? barrierColor;

  /// elements passed as favorite
  final List<Country> favoriteElements;

  final EdgeInsetsGeometry dialogItemPadding;

  final EdgeInsetsGeometry searchPadding;

  CountryCodePickerDialog(
      this.elements,
      this.favoriteElements, {
        super.key,
        this.showCountryOnly,
        this.emptySearchBuilder,
        InputDecoration searchDecoration = const InputDecoration(),
        this.searchStyle,
        this.textStyle,
        this.boxDecoration,
        this.showFlag,
        this.flagDecoration,
        this.flagWidth = 32,
        this.size,
        this.backgroundColor,
        this.barrierColor,
        this.hideSearch = false,
        this.hideCloseIcon = false,
        this.closeIcon,
        this.dialogItemPadding =
        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        this.searchPadding = const EdgeInsets.symmetric(horizontal: 24),
      }) : searchDecoration = searchDecoration.prefixIcon == null
      ? searchDecoration.copyWith(prefixIcon: const Icon(Icons.search))
      : searchDecoration;

  @override
  State<StatefulWidget> createState() => _CountryCodePickerDialogState();
}

class _CountryCodePickerDialogState extends State<CountryCodePickerDialog> {
  /// this is useful for filtering purpose
  late List<Country> filteredElements;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(0.0),
    child: Container(
      clipBehavior: Clip.hardEdge,
      width: widget.size?.width ?? MediaQuery.of(context).size.width,
      height:
      widget.size?.height ?? MediaQuery.of(context).size.height * 0.90,
      decoration: widget.boxDecoration ??
          BoxDecoration(
            color: widget.backgroundColor ?? Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            boxShadow: [
              BoxShadow(
                color: widget.barrierColor ?? Colors.grey.withOpacity(1),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.hideCloseIcon)
            IconButton(
              padding: EdgeInsets.zero,
              iconSize: 20,
              icon: widget.closeIcon!,
              onPressed: () => Navigator.pop(context),
            ),
          if (!widget.hideSearch)
            Padding(
              padding: widget.searchPadding,
              child: TextField(
                style: widget.searchStyle,
                decoration: widget.searchDecoration,
                onChanged: _filterElements,
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 20),
              children: [
                widget.favoriteElements.isEmpty
                    ? const DecoratedBox(decoration: BoxDecoration())
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...widget.favoriteElements.map((f) => InkWell(
                        onTap: () {
                          _selectItem(f);
                        },
                        child: Padding(
                          padding: widget.dialogItemPadding,
                          child: _buildOption(f),
                        ))),
                    const Divider(),
                  ],
                ),
                if (filteredElements.isEmpty)
                  _buildEmptySearchWidget(context)
                else
                  ...filteredElements.map((e) => InkWell(
                      onTap: () {
                        _selectItem(e);
                      },
                      child: Padding(
                        padding: widget.dialogItemPadding,
                        child: _buildOption(e),
                      ))),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildOption(Country e) {
    return SizedBox(
      width: 400,
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          if (widget.showFlag!)
            Flexible(
              child: Container(
                margin: const EdgeInsets.only(right: 16.0),
                decoration: widget.flagDecoration,
                clipBehavior:
                widget.flagDecoration == null ? Clip.none : Clip.hardEdge,
                child: Image.asset(
                  e.flagUri,
                  package: 'country_code_picker_plus',
                  width: widget.flagWidth,
                ),
              ),
            ),
          Expanded(
            flex: 4,
            child: Text(
              widget.showCountryOnly! ? e.name : e.toLongString(),
              overflow: TextOverflow.fade,
              style: widget.textStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchWidget(BuildContext context) {
    if (widget.emptySearchBuilder != null) {
      return widget.emptySearchBuilder!(context);
    }

    return const Center(
      child: Text('No country found'),
    );
  }

  @override
  void initState() {
    filteredElements = widget.elements;
    super.initState();
  }

  void _filterElements(String s) {
    s = s.toUpperCase();
    setState(() {
      filteredElements = widget.elements
          .where((e) =>
      e.code.contains(s) ||
          e.dialCode.contains(s) ||
          e.name.toUpperCase().contains(s))
          .toList();
    });
  }

  void _selectItem(Country e) {
    Navigator.pop(context, e);
  }
}
