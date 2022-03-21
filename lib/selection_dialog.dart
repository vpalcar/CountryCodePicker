import 'package:country_code_picker/country_code.dart';
import 'package:country_code_picker/country_localizations.dart';
import 'package:country_code_picker/dashed_line.dart';
import 'package:flutter/material.dart';

/// selection dialog used for selection of the country code
class SelectionDialog extends StatefulWidget {
  final List<CountryCode> elements;
  final bool? showCountryOnly;
  final InputDecoration searchDecoration;
  final TextStyle? searchStyle;
  final TextStyle textStyle;
  final TextStyle codeStyle;
  final BoxDecoration? boxDecoration;
  final WidgetBuilder? emptySearchBuilder;
  final bool? showFlag;
  final double flagWidth;
  final Decoration? flagDecoration;
  final Size? size;
  final bool hideSearch;
  final Widget? closeIcon;
  final CountryCode? selectedItem;
  final Widget selectionIcon;
  final Color cursorColor;
  final bool? showDialCode;

  /// Background color of SelectionDialog
  final Color? backgroundColor;

  /// Boxshaow color of SelectionDialog that matches CountryCodePicker barrier color
  final Color? barrierColor;
  final Text title;

  SelectionDialog(
    this.elements, {
    Key? key,
    this.showCountryOnly,
    this.emptySearchBuilder,
    InputDecoration searchDecoration = const InputDecoration(),
    this.searchStyle,
    required this.textStyle,
    required this.codeStyle,
    required this.selectionIcon,
    required this.selectedItem,
    this.boxDecoration,
    this.showDialCode,
    this.showFlag,
    this.flagDecoration,
    this.flagWidth = 32.0,
    this.size,
    this.backgroundColor,
    this.barrierColor,
    this.hideSearch = false,
    required this.closeIcon,
    required this.title,
    required this.cursorColor,
  })  : this.searchDecoration = searchDecoration.prefixIcon == null
            ? searchDecoration.copyWith(prefixIcon: Icon(Icons.search))
            : searchDecoration,
        super(key: key);

  @override
  State<StatefulWidget> createState() => _SelectionDialogState();
}

class _SelectionDialogState extends State<SelectionDialog> {
  /// this is useful for filtering purpose
  late List<CountryCode> filteredElements;

  @override
  Widget build(BuildContext context) => Container(
        clipBehavior: Clip.hardEdge,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 65.0,
        decoration: widget.boxDecoration ??
            BoxDecoration(
              color: widget.backgroundColor ?? Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(1),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 30.0,
                  ),
                  widget.title,
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 30.0,
                      alignment: Alignment.centerRight,
                      child: widget.closeIcon,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                cursorColor: widget.cursorColor,
                style: widget.searchStyle,
                decoration: widget.searchDecoration,
                onChanged: _filterElements,
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(top: 21.0),
                children: [
                  SimpleDialogOption(
                    child: _buildOption(widget.selectedItem!),
                    onPressed: () {
                      _selectItem(widget.selectedItem!);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 12.0),
                    child: DashedLine(
                      color: widget.barrierColor!,
                    ),
                  ),
                  if (filteredElements.isEmpty)
                    _buildEmptySearchWidget(context)
                  else
                    ...filteredElements.map(
                      (e) => SimpleDialogOption(
                        child: _buildOption(e),
                        onPressed: () {
                          _selectItem(e);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildOption(CountryCode e) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
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
                    e.flagUri!,
                    package: 'country_code_picker',
                    width: widget.flagWidth,
                  ),
                ),
              ),
            if (widget.showDialCode ?? true)
              Flexible(
                child: Container(
                  width: 60.0,
                  child: Text(
                    e.dialCode!,
                    overflow: TextOverflow.fade,
                    style: widget.codeStyle,
                  ),
                ),
              ),
            Expanded(
              flex: 4,
              child: Text(
                e.toCountryStringOnly(),
                overflow: TextOverflow.fade,
                style: widget.textStyle,
              ),
            ),
            if (e == widget.selectedItem)
              Flexible(
                child: Container(
                  alignment: Alignment.centerRight,
                  width: 60.0,
                  child: widget.selectionIcon,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySearchWidget(BuildContext context) {
    if (widget.emptySearchBuilder != null) {
      return widget.emptySearchBuilder!(context);
    }

    return Center(
      child: Text(CountryLocalizations.of(context)?.translate('no_country') ??
          'No country found'),
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
              e.code!.contains(s) ||
              e.dialCode!.contains(s) ||
              e.name!.toUpperCase().contains(s))
          .toList();
    });
  }

  void _selectItem(CountryCode e) {
    Navigator.pop(context, e);
  }
}
