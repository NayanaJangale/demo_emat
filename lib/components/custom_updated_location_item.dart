import 'package:digitalgeolocater/handlers/message_handler.dart';
import 'package:digitalgeolocater/handlers/string_handlers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomUpdatedLocationItem extends StatefulWidget {
  final String branchName;
  final int floorNo;
  final int Redius;

  CustomUpdatedLocationItem({
    this.branchName,
    this.floorNo,
    this.Redius,
  });

  @override
  _CustomUpdatedLocationItemState createState() => _CustomUpdatedLocationItemState();
}

class _CustomUpdatedLocationItemState extends State<CustomUpdatedLocationItem> {

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30.0),
          topLeft: Radius.circular(3.0),
          bottomRight: Radius.circular(3.0),
          bottomLeft: Radius.circular(3.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Table(
              columnWidths: {
                0: FractionColumnWidth(.4),
              },
              children: [
                TableRow(
                  children: [
                    Container(),
                    Container(),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 5.0,
                      ),
                      child: Text(
                        "Branch Name",
                        style: Theme.of(context).textTheme.body2.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 5.0,
                      ),
                      child: Text(
                        StringHandlers.capitalizeWords(this.widget.branchName),
                        style: Theme.of(context).textTheme.body2.copyWith(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 5.0,
                        bottom: 5.0,
                      ),
                      child: Text(
                        "Floor No",
                        style: Theme.of(context).textTheme.body2.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 5.0,
                        bottom: 5.0,
                      ),
                      child: Text(
                        StringHandlers.capitalizeWords(widget.floorNo.toString()),
                        style: Theme.of(context).textTheme.body2.copyWith(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  /*decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[300],
                      ),
                    ),
                  ),*/
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 5.0,
                        bottom: 5.0,
                      ),
                      child: Text(
                        "Redius",
                        style: Theme.of(context).textTheme.body2.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 5.0,
                        bottom: 5.0,
                      ),
                      child: Text(
                        widget.Redius.toString()+"m",
                        style: Theme.of(context).textTheme.body2.copyWith(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

              ],
            ),
            SizedBox(
              height: 10,
            ),

          ],
        ),
      ),
    );
  }
}
