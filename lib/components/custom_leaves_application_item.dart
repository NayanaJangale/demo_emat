import 'package:digitalgeolocater/handlers/string_handlers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class CustomLeaveApplicationItem extends StatelessWidget {
  final String leave_type;
  final String start_date;
  final String end_date;
  final String assign_to_date;
  final String assign_from_date;
  final String apply_date;
  final String status;
  final String reason;
  final String leaveCategory;

  CustomLeaveApplicationItem({
    this.leave_type,
    this.start_date,
    this.end_date,
    this.assign_to_date,
    this.assign_from_date,
    this.apply_date,
    this.status,
    this.reason,
    this.leaveCategory
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Card(
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
                            "Leave Type",
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
                          StringHandlers.capitalizeWords(this.leave_type),
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
                        ),
                        child: Text(
                          "Applied Duration",
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
                          StringHandlers.capitalizeWords(
                              "${this.start_date} - ${this.end_date}"),
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
                        ),
                        child: Text(
                          "Approved Duration",
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
                          StringHandlers.capitalizeWords(
                              "${this.assign_from_date} - ${this.assign_to_date}"),
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
                          bottom: 0.0,
                        ),
                        child: Text(
                          "Applied on",
                          style: Theme.of(context).textTheme.body2.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 5.0,
                          bottom: 0.0,
                        ),
                        child: Text(
                          StringHandlers.capitalizeWords(this.apply_date),
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
                          bottom: 0.0,
                        ),
                        child: Text(
                          "Reason",
                          style: Theme.of(context).textTheme.body2.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 5.0,
                          bottom: 0.0,
                        ),
                        child: Text(
                          StringHandlers.capitalizeWords(this.reason),
                          style: Theme.of(context).textTheme.body2.copyWith(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.lightBlue[100],
                        ),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 5.0,
                          bottom: 10.0,
                        ),
                        child: Text(
                          "Leave Category",
                          style: Theme.of(context).textTheme.body2.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 5.0,
                          bottom: 10.0,
                        ),
                        child: Text(
                          StringHandlers.capitalizeWords(this.leaveCategory),
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
                          top: 10.0,
                          bottom: 10.0,
                        ),
                        child: Text(
                          "Status",
                          style: Theme.of(context).textTheme.body2.copyWith(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 10.0,
                          bottom: 10.0,
                        ),
                        child: Text(
                          StringHandlers.capitalizeWords(this.status),
                          style: Theme.of(context).textTheme.body2.copyWith(
                                color: this.status=='Approved'? Colors.green[800] : this.status=='Rejected'? Colors.red[800]:Colors.blue[800],
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
