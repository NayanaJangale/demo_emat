import 'package:flutter/material.dart';

class CustomDropDownButton extends StatelessWidget {
  const CustomDropDownButton({
    Key key,
    this.items,
    this.onItemChanged,
    this.hintText,
    this.value,
    this.color,
    this.selecteedItem,
  }) : super(key: key);

  final List<Widget> items;
  final Function onItemChanged;
  final Function selecteedItem;
  final String hintText;
  final dynamic value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: value,
      items: items,
      onChanged: onItemChanged,
      hint:  Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          hintText,
          style: Theme.of(context)
              .textTheme
              .body2
              .copyWith(
            color: Colors.grey[700],
          ),
        ),
      ),
      isExpanded: true,
      iconEnabledColor: Colors.black,
      selectedItemBuilder: selecteedItem,
      underline: Divider(
        color: Colors.grey[200],
        height: 2.0,
        thickness: 0.5,
      ),
    );
  }
}
