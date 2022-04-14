library country_code_picker;

import 'package:country_code_picker/country_code.dart';
import 'package:country_code_picker/country_codes.dart';
import 'package:country_code_picker/selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

export 'country_code.dart';

class CountryCodePicker extends StatefulWidget {
  final ValueChanged<CountryCode>? onChanged;
  final ValueChanged<CountryCode?>? onInit;
  final String? initialSelection;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;
  final bool showCountryOnly;
  final InputDecoration searchDecoration;
  final TextStyle searchStyle;
  final TextStyle dialogTextStyle;
  final TextStyle codeStyle;
  final WidgetBuilder? emptySearchBuilder;
  final Function(CountryCode?)? builder;
  final bool enabled;
  final TextOverflow textOverflow;
  final Widget closeIcon;
  final Widget selectionIcon;
  final Color cursorColor;
  final Widget? child;

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

  final Color iconColor;

  final Color buttonBackgroundColor;

  /// shows the flag
  final bool showFlag;

  final bool hideMainText;

  final bool? showFlagMain;

  final bool? showFlagDialog;

  /// Width of the flag images
  final double flagWidth;

  /// Use this property to change the order of the options
  final Comparator<CountryCode>? comparator;

  /// Set to true if you want to hide the search part
  final bool hideSearch;

  /// Set to true if you want to show drop down button
  final bool showDropDownButton;

  /// [BoxDecoration] for the flag image
  final Decoration? flagDecoration;

  /// An optional argument for injecting a list of countries
  /// with customized codes.
  final List<Map<String, String>> countryList;

  final Text title;
  final Widget? expandIcon;

  final double buttonBorderRadius;

  final double buttonHeight;

  final double buttonWidth;

  CountryCodePicker({
    this.onChanged,
    required this.buttonBackgroundColor,
    required this.iconColor,
    this.onInit,
    this.initialSelection,
    this.textStyle,
    this.child,
    this.padding = const EdgeInsets.all(8.0),
    this.showCountryOnly = false,
    this.searchDecoration = const InputDecoration(),
    required this.searchStyle,
    required this.dialogTextStyle,
    required this.codeStyle,
    required this.cursorColor,
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
    this.buttonBorderRadius = 10.0,
    this.buttonHeight = 60.0,
    this.buttonWidth = 77.0,
    this.textOverflow = TextOverflow.ellipsis,
    this.barrierColor,
    this.backgroundColor,
    this.boxDecoration,
    this.comparator,
    this.countryFilter,
    this.hideSearch = false,
    this.showDropDownButton = false,
    this.dialogSize,
    this.dialogBackgroundColor,
    required this.closeIcon,
    required this.selectionIcon,
    required this.title,
    this.expandIcon,
    this.countryList = codes,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    List<Map<String, String>> jsonList = countryList;

    List<CountryCode> elements =
        jsonList.map((json) => CountryCode.fromJson(json)).toList();

    if (comparator != null) {
      elements.sort(comparator);
    }

    if (countryFilter != null && countryFilter!.isNotEmpty) {
      final uppercaseCustomList =
          countryFilter!.map((c) => c.toUpperCase()).toList();
      elements = elements
          .where((c) =>
              uppercaseCustomList.contains(c.code) ||
              uppercaseCustomList.contains(c.name) ||
              uppercaseCustomList.contains(c.dialCode))
          .toList();
    }

    return CountryCodePickerState(elements);
  }
}

class CountryCodePickerState extends State<CountryCodePicker> {
  CountryCode? selectedItem;
  List<CountryCode> elements = [];
  List<CountryCode> favoriteElements = [];

  CountryCodePickerState(this.elements);

  @override
  Widget build(BuildContext context) {
    Widget _widget;

    if (widget.child == null) {
      _widget = GestureDetector(
        onTap: showCountryCodePickerDialog,
        child: Container(
          height: widget.buttonHeight,
          width: widget.buttonWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.buttonBorderRadius),
            color: widget.buttonBackgroundColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                clipBehavior:
                    widget.flagDecoration == null ? Clip.none : Clip.hardEdge,
                decoration: widget.flagDecoration,
                child: Image.asset(
                  selectedItem!.flagUri!,
                  package: 'country_code_picker',
                  width: 32.0,
                ),
              ),
              const SizedBox(
                width: 5.0,
              ),
              widget.expandIcon == null
                  ? Icon(
                      Icons.expand_more,
                      color: widget.iconColor,
                      size: 18.0,
                    )
                  : widget.expandIcon!,
            ],
          ),
        ),
      );
    } else {
      _widget = GestureDetector(
          onTap: showCountryCodePickerDialog, child: widget.child!);
    }

    return _widget;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    this.elements = elements.map((e) => e.localize(context)).toList();
    _onInit(selectedItem);
  }

  @override
  void didUpdateWidget(CountryCodePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialSelection != widget.initialSelection) {
      if (widget.initialSelection != null) {
        selectedItem = elements.firstWhere(
            (e) =>
                (e.code!.toUpperCase() ==
                    widget.initialSelection!.toUpperCase()) ||
                (e.dialCode == widget.initialSelection) ||
                (e.name!.toUpperCase() ==
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
          (e) =>
              (e.code!.toUpperCase() ==
                  widget.initialSelection!.toUpperCase()) ||
              (e.dialCode == widget.initialSelection) ||
              (e.name!.toUpperCase() == widget.initialSelection!.toUpperCase()),
          orElse: () => elements[0]);
    } else {
      selectedItem = elements[0];
    }
  }

  void showCountryCodePickerDialog() {
    showMaterialModalBottomSheet(
      barrierColor: Colors.grey.withOpacity(0.5),
      backgroundColor: widget.backgroundColor ?? Colors.transparent,
      context: context,
      builder: (context) => SelectionDialog(
        elements,
        showCountryOnly: widget.showCountryOnly,
        emptySearchBuilder: widget.emptySearchBuilder,
        searchDecoration: widget.searchDecoration,
        searchStyle: widget.searchStyle,
        textStyle: widget.dialogTextStyle,
        codeStyle: widget.codeStyle,
        boxDecoration: widget.boxDecoration,
        selectedItem: selectedItem,
        cursorColor: widget.cursorColor,
        showFlag: widget.showFlagDialog != null
            ? widget.showFlagDialog
            : widget.showFlag,
        showDialCode: !widget.showCountryOnly,
        flagWidth: widget.flagWidth,
        flagDecoration: widget.flagDecoration,
        size: widget.dialogSize,
        backgroundColor: widget.dialogBackgroundColor,
        barrierColor: widget.barrierColor,
        hideSearch: widget.hideSearch,
        closeIcon: widget.closeIcon,
        selectionIcon: widget.selectionIcon,
        title: widget.title,
      ),
    ).then((e) {
      if (e != null) {
        setState(() {
          selectedItem = e;
        });

        _publishSelection(e);
      }
    });
  }

  void _publishSelection(CountryCode e) {
    if (widget.onChanged != null) {
      widget.onChanged!(e);
    }
  }

  void _onInit(CountryCode? e) {
    if (widget.onInit != null) {
      widget.onInit!(e);
    }
  }
}
