import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masterstudy_app/main.dart';
import 'package:masterstudy_app/theme/theme.dart';
import 'package:masterstudy_app/ui/bloc/question_ask/bloc.dart';

import '../../../data/utils.dart';

class QuestionAskScreenArgs {
  final int lessonId;

  QuestionAskScreenArgs(this.lessonId);
}

class QuestionAskScreen extends StatelessWidget {
  static const routeName = "questionAskScreen";
  final QuestionAskBloc bloc;

  const QuestionAskScreen(this.bloc) : super();

  @override
  Widget build(BuildContext context) {
    QuestionAskScreenArgs args = ModalRoute.of(context)?.settings.arguments as QuestionAskScreenArgs;
    return BlocProvider<QuestionAskBloc>(create: (context) => bloc, child: QuestionAskWidget(args.lessonId));
  }
}

class QuestionAskWidget extends StatefulWidget {
  final int lessonId;

  const QuestionAskWidget(this.lessonId) : super();

  @override
  State<StatefulWidget> createState() => QuestionAskWidgetState();
}

class QuestionAskWidgetState extends State<QuestionAskWidget> {
  QuestionAskBloc? chatsBloc;
  bool sendRequest = false;
  bool isLoading = false;
  TextEditingController textController = TextEditingController();
  FocusNode myFocusNode = new FocusNode();

  final interval = const Duration(seconds: 1);

  final int timerMaxSeconds = 20;

  int currentSeconds = 0;

  String get timerText => '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}: ${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    chatsBloc = BlocProvider.of<QuestionAskBloc>(context);
  }

  startTimeout() {
    var duration = interval;
    timer = Timer.periodic(duration, (timer) {
      setState(() {
        sendRequest = true;
      });
      setState(() {
        currentSeconds = timer.tick;
        if (timer.tick >= timerMaxSeconds) timer.cancel();
      });

      if (timer.tick == 20) {
        setState(() {
          sendRequest = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: HexColor.fromHex("#273044"),
        title: Text(
          localizations!.getLocalization("question_ask_screen_title"),
          textScaleFactor: 1.0,
          style: TextStyle(color: Colors.white, fontSize: 16.0),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: BlocListener(
          bloc: chatsBloc,
          listener: (context, state) {
            if (state is QuestionAddedState) {
              textController.clear();
              setState(() {
                isLoading = false;
                sendRequest = true;
              });

              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(
                  state.questionAddResponse.message,
                  textScaleFactor: 1.0,
                ),
                duration: Duration(seconds: 5),
                action: SnackBarAction(
                  label: localizations!.getLocalization("ok_dialog_button"),
                  onPressed: () {},
                ),
              ));

              startTimeout();
            } else {
              textController.clear();
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(
                  'Error with network, please resend!',
                  textScaleFactor: 1.0,
                ),
                duration: Duration(seconds: 5),
              ));
              setState(() {
                isLoading = false;
                sendRequest = false;
              });
            }
          },
          child: BlocBuilder<QuestionAskBloc, QuestionAskState>(builder: (context, state) {
            return Padding(
              padding: EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0),
              child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 0),
                  child: Text(
                    localizations!.getLocalization("ask_your_question"),
                    textScaleFactor: 1.0,
                    style: TextStyle(color: HexColor.fromHex("#273044"), fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                  child: TextFormField(
                    textInputAction: TextInputAction.done,
                    controller: textController,
                    maxLines: 8,
                    cursorColor: mainColor,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: mainColor!),
                      ),
                      labelStyle: TextStyle(color: myFocusNode.hasFocus ? mainColor : Colors.black),
                      labelText: localizations!.getLocalization("enter_review"),
                      alignLabelWithHint: true,
                    ),
                  ),
                ),
                SizedBox(
                  height: 45,
                  width: double.infinity,
                  child: new ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: secondColor,
                    ),
                    onPressed: sendRequest
                        ? null
                        : () {
                            if (textController.text != "") {
                              setState(() {
                                isLoading = true;
                              });
                              chatsBloc!.add(QuestionAddEvent(widget.lessonId, textController.text));
                            }
                          },
                    child: sendRequest
                        ? Text(
                            timerText,
                            textScaleFactor: 1.0,
                          )
                        : isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Text(
                                "SUBMIT",
                                textScaleFactor: 1.0,
                              ),
                  ),
                ),
                const SizedBox(height: 10),
              ]),
            );
          }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
