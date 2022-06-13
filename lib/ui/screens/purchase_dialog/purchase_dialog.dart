import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masterstudy_app/data/models/purchase/UserPlansResponse.dart';
import 'package:masterstudy_app/main.dart';
import 'package:masterstudy_app/ui/bloc/course/course_bloc.dart';
import 'package:masterstudy_app/ui/bloc/course/course_event.dart';
import 'package:masterstudy_app/ui/bloc/course/course_state.dart';
import 'package:url_launcher/url_launcher.dart';

class PurchaseDialog extends StatefulWidget {
  final dynamic courseToken;

  const PurchaseDialog({Key? key, this.courseToken}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PurchaseDialogState();
}

class PurchaseDialogState extends State<PurchaseDialog> {
  late CourseBloc _bloc;
  String courseToken = '';

  int selectedId = -1;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<CourseBloc>(context);
    selectedId = _bloc.selectedPaymetId;

    courseToken = widget.courseToken;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _bloc,
      builder: (context, state) {
        if (state is LoadedCourseState) return _buildPrices(state);
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  bool _haveValidPlan(UserPlansResponse plans) {
    bool have = false;
    plans.subscriptions.forEach((element) {
      if (element!.quotas_left > 0) {
        have = true;
        return;
      }
    });
    return have;
  }

  _buildPrices(LoadedCourseState state) {
    List<Widget> list = [];

    if(state.courseDetailResponse.price!.free == false) {
      list.add(
        _buildDefaultItem(
            (selectedId == -1), localizations!.getLocalization("one_time_payment"), "${localizations!.getLocalization("course_regular_price")} ${state.courseDetailResponse.price!.price}",
            state.courseDetailResponse.price!.price, () {
          setState(() {
            selectedId = -1;
          });
        }),
      );
    }

    if(state.userPlans != null) {
      if (state.userPlans!.subscriptions.isNotEmpty && _haveValidPlan(state.userPlans!)) {
        state.userPlans!.subscriptions.forEach((value) {
          list.add(_buildPriceItem((selectedId == int.parse(value!.subscription_id)), localizations!.getLocalization("enroll_with_membership"), value.name, value.quotas_left, () {
            setState(() {
              selectedId = int.parse(value.subscription_id);
            });
          }));
        });
      } else if (_bloc.availablePlans.isNotEmpty) {
        _bloc.availablePlans.forEach((value) {
          list.add(_buildPriceItem((selectedId == int.parse(value.id)), "${localizations!.getLocalization("available_in_plan")} \"${value.name}\"", value.name, value.quotas_left, () {
            setState(() {
              selectedId = int.parse(value.id);
            });
          }));
        });
      }
    }

    //Button "Select"
    list.add(
      Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: MaterialButton(
          minWidth: double.infinity,
          color: mainColor,
          onPressed: () async {
            if (state is LoadedCourseState && state.userPlans!.subscriptions.isNotEmpty) {
              _bloc.add(PaymentSelectedEvent(selectedId, state.courseDetailResponse.id));
              Navigator.pop(context);
            } else {
              if (selectedId != -1) {
                if(state.userPlans!.other_subscriptions) {
                  _warningDialog();
                }else {
                  await launch('${courseToken}&payment=$selectedId').then((value) {
                    Navigator.of(context).pop();
                  });
                }
              } else {
                _bloc.add(PaymentSelectedEvent(selectedId, state.courseDetailResponse.id));
                Navigator.pop(context);
              }
            }
          },
          child: Text(
            localizations!.getLocalization("select_payment_button"),
            textScaleFactor: 1.0,
          ),
          textColor: Colors.white,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0, top: 35.0, left: 16, right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: list,
      ),
    );
  }

  _buildDefaultItem(selected, title, subtitle, value, onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 50,
            child: Stack(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      selected ? Icons.check_circle : Icons.panorama_fish_eye,
                      color: selected ? secondColor : Colors.grey,
                      size: 40,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "$title",
                            textScaleFactor: 1.0,
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            "$subtitle ",
                            textScaleFactor: 1.0,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                      child: Text(
                    "$value",
                    textScaleFactor: 1.0,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: secondColor),
                  )),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildPriceItem(selected, title, subtitle, value, onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    selected ? Icons.check_circle : Icons.panorama_fish_eye,
                    color: selected ? secondColor : Colors.grey,
                    size: 40,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          "$title",
                          textScaleFactor: 1.0,
                          style: TextStyle(fontSize: title.length > 20 ? 14 : 18),
                        ),
                        Text(
                          "$subtitle ",
                          textScaleFactor: 1.0,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Visibility(
                visible: value != null,
                child: Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "$value",
                        textScaleFactor: 1.0,
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: secondColor),
                      ),
                      Text(
                        localizations!.getLocalization("plan_count_left"),
                        textScaleFactor: 1.0,
                        style: TextStyle(fontSize: 9, color: secondColor),
                      )
                    ],
                  )),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  _warningDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(localizations!.getLocalization("warning"), textScaleFactor: 1.0, style: TextStyle(color: Colors.black, fontSize: 20.0)),
            content: Text(localizations!.getLocalization("new_plan_over_the_old")),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: mainColor,
                ),
                child: Text(
                  localizations!.getLocalization("get_now"),
                  textScaleFactor: 1.0,
                ),
                onPressed: () async {
                  await launch('${courseToken}&payment=$selectedId').then((value) {
                    Navigator.of(context).pop();
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  _purchaseDialog() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black.withAlpha(1),
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: double.infinity,
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.8),
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 25, right: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: Center(
                        child: Text(
                          "All purchases are going through the website only. In-app purchase is not available.\n Please, continue purchase on the website.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
