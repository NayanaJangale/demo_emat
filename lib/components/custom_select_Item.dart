import 'package:flutter/material.dart';

class CustomSelectItem extends StatelessWidget {
  String itemTitle;
  int itemIndex;
  Function onItemTap;

  CustomSelectItem({
    this.itemTitle,
    this.itemIndex,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: this.onItemTap,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 8.0,
          bottom: 8.0,
        ),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
                right: 10.0,
                top: 3.0,
                bottom: 3.0,
              ),
              child: Text(
                itemIndex.toString(),
                style: Theme.of(context).textTheme.body2.copyWith(
                  color: Colors.blue[800],
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Text(
                itemTitle,
                style: Theme.of(context).textTheme.body2.copyWith(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Text(
                "10 am",
                style: Theme.of(context).textTheme.body2.copyWith(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 3.0,
                bottom: 3.0,
              ),
              child: Icon(
                Icons.navigate_next,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
