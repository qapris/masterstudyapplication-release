import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:masterstudy_app/data/models/QuestionsResponse.dart';
import 'package:masterstudy_app/main.dart';
import 'package:masterstudy_app/theme/theme.dart';
import 'package:masterstudy_app/ui/bloc/questions/bloc.dart';
import 'package:masterstudy_app/ui/screens/question_ask/question_ask_screen.dart';
import 'package:masterstudy_app/ui/screens/question_details/question_details_screen.dart';
import 'package:masterstudy_app/ui/screens/detail_profile/detail_profile_screen.dart';
import 'package:masterstudy_app/ui/widgets/dialog_author.dart';

import '../../../data/utils.dart';

class QuestionsScreenArgs {
  final int lessonId;
  final int page;

  QuestionsScreenArgs(this.lessonId, this.page);
}

class QuestionsScreen extends StatelessWidget {
  static const routeName = "questionsScreen";
  final QuestionsBloc bloc;

  const QuestionsScreen(this.bloc) : super();

  @override
  Widget build(BuildContext context) {
    QuestionsScreenArgs args = ModalRoute.of(context)?.settings.arguments as QuestionsScreenArgs;
    return BlocProvider<QuestionsBloc>(create: (context) => bloc, child: QuestionsWidget(args.lessonId, args.page));
  }
}

class QuestionsWidget extends StatefulWidget {
  final int lessonId;
  final int page;

  const QuestionsWidget(this.lessonId, this.page) : super();

  @override
  State<StatefulWidget> createState() => QuestionsWidgetState();
}

class QuestionsWidgetState extends State<QuestionsWidget> {
  late QuestionsBloc _bloc;
  late QuestionsResponse questionsAll;
  late QuestionsResponse questionsMy;
  TextEditingController reply = TextEditingController();
  List<TextEditingController> _controllers = [];

  final interval = const Duration(seconds: 1);

  final int timerMaxSeconds = 20;

  int currentSeconds = 0;

  String get timerText => '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}: ${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}';

  bool isLoadingTimer = false;
  bool isLoadingButton = false;
  late bool demo;

  startTimeout() {
    var duration = interval;
    timer = Timer.periodic(duration, (timer) {
      setState(() {
        isLoadingButton = true;
        isLoadingTimer = true;
      });

      setState(() {
        currentSeconds = timer.tick;
        if (timer.tick >= timerMaxSeconds) timer.cancel();
      });

      if (timer.tick == 20) {
        setState(() {
          isLoadingButton = false;
          isLoadingTimer = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (preferences!.getBool('demo') == null) {
      demo = false;
    } else {
      demo = preferences!.getBool('demo');
    }
    _bloc = BlocProvider.of<QuestionsBloc>(context);
    _bloc.add(FetchEvent(widget.lessonId, widget.page, "", ""));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
        bloc: _bloc,
        listener: (context, state) {
          if (state is LoadedQuestionsState) {
            setState(() {
              questionsAll = state.questionsResponseAll;
              questionsMy = state.questionsResponseMy;
            });
          }

          if (state is TimerStartState) {
            startTimeout();
          }
        },
        child: BlocBuilder<QuestionsBloc, QuestionsState>(
          builder: (context, state) {
            return DefaultTabController(
              length: 2,
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  backgroundColor: HexColor.fromHex("#273044"),
                  title: Text(
                    localizations!.getLocalization("question_ask_screen_title"),
                    textScaleFactor: 1.0,
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                  bottom: ColoredTabBar(
                    Colors.white,
                    TabBar(
                      indicatorColor: mainColorA,
                      tabs: [
                        Tab(
                          text: localizations!.getLocalization("all_questions"),
                        ),
                        Tab(text: localizations!.getLocalization("my_questions")),
                      ],
                    ),
                  ),
                ),
                body: GestureDetector(
                  child: _buildBody(state),
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                ),
                bottomNavigationBar: _buildBottom(state),
              ),
            );
          },
        ));
  }

  //Body
  _buildBody(QuestionsState state) {
    if (state is InitialQuestionsState)
      return Center(
        child: CircularProgressIndicator(),
      );

    if (state is LoadedQuestionsState) {
      questionsAll = state.questionsResponseAll;
      questionsMy = state.questionsResponseMy;

      return TabBarView(
        children: <Widget>[
          //All questions
          questionsAll.posts.length != 0
              ? ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: questionsAll.posts.length,
                  itemBuilder: (BuildContext ctx, int index) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(padding: EdgeInsets.only(top: 30.0, right: 27.0, left: 27.0, bottom: 10), child: _buildQuestion(questionsAll.posts[index])),
                      ],
                    );
                  },
                )
              : Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 30.0),
                    child: Text(
                      localizations!.getLocalization("no_questions"),
                      textScaleFactor: 1.0,
                    ),
                  ),
                ),
          //My questions
          questionsMy.posts.length != 0
              ? ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: questionsMy.posts.length,
                  itemBuilder: (BuildContext ctx, int index) {
                    _controllers.add(new TextEditingController());
                    return Padding(
                      padding: EdgeInsets.only(top: 30.0, right: 27.0, left: 27.0, bottom: 10),
                      child: _buildMyQuestion(questionsMy.posts[index]!, _controllers[index]),
                    );
                  },
                )
              : Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 30.0),
                    child: Text(
                      localizations!.getLocalization("no_questions"),
                      textScaleFactor: 1.0,
                    ),
                  ),
                ),
        ],
      );
    }
  }

  //AllQuestion
  _buildQuestion(QuestionBean? question) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              QuestionDetailsScreen.routeName,
              arguments: QuestionDetailsScreenArgs(widget.lessonId, question!),
            );
          },
          // child: Html(data: question?.content, style: {'body': Style(fontSize: FontSize(17.0), fontWeight: FontWeight.w700, color: HexColor.fromHex("#273044"))}),
          child: Text(question!.content, style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w700, color: HexColor.fromHex("#273044"))),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.0, bottom: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                  width: 20,
                  height: 20,
                  child: SvgPicture.asset(
                    (question.replies.length == 0) ? "assets/icons/reply_no.svg" : "assets/icons/reply_has.svg",
                    color: (question.replies.length == 0) ? HexColor.fromHex("#AAAAAA") : secondColor,
                  )),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Text(
                  question.replies_count!,
                  textScaleFactor: 1.0,
                  style: TextStyle(fontSize: 15.0, color: (question.replies.length == 0) ? HexColor.fromHex("#AAAAAA") : secondColor),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Container(
              height: 1.0,
              decoration: BoxDecoration(
                color: HexColor.fromHex("#E2E5EB"),
              )),
        )
      ],
    );
  }

  //MyQuestion
  _buildMyQuestion(QuestionBean question, TextEditingController controller) {
    FocusNode myFocusNode = new FocusNode();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //Question
            Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              // child: Html(data: question.content, style: {'body': Style(fontSize: FontSize(17.0), fontWeight: FontWeight.w700, color: HexColor.fromHex("#273044"))}),
              child: Text(question.content, style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w700, color: HexColor.fromHex("#273044"))),
            ),
            //Time
            Text(question.datetime, textScaleFactor: 1.0, style: TextStyle(color: HexColor.fromHex("#AAAAAA"))),
            //Enter your answer
            Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 40.0),
                child: TextFormField(
                  textInputAction: TextInputAction.done,
                  maxLines: 2,
                  controller: controller,
                  cursorColor: mainColor,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Enter your answer",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: mainColor!),
                    ),
                    labelStyle: TextStyle(color: myFocusNode.hasFocus ? mainColor : Colors.black),
                  ),
                )),
            SizedBox(
              height: 45,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: secondColor),
                onPressed: isLoadingButton
                    ? null
                    : () {
                        if (demo) {
                          showDialogError(context, 'Demo Mode');
                        } else {
                          if (controller.text != '') {
                            setState(() {
                              isLoadingButton = true;
                            });

                            _bloc.add(
                              MyQuestionAddEvent(questionsAll, widget.lessonId, controller.text, int.tryParse(question.comment_ID)!),
                            );
                            controller.clear();
                          }
                        }
                      },
                child: isLoadingTimer
                    ? Text(
                        timerText,
                        textScaleFactor: 1.0,
                      )
                    : isLoadingButton
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
            //MyAnswerList
            for (var el in question.replies) _buildMyAnswer(el!),
            // _buildMyAnswer(question.replies)
          ],
        ),
        // Custom Divider
        Padding(
          padding: EdgeInsets.only(top: 20.0),
          child: Container(
              height: 1.0,
              decoration: BoxDecoration(
                color: HexColor.fromHex("#E2E5EB"),
              )),
        )
      ],
    );
  }

  //MyAnswer
  _buildMyAnswer(ReplyBean reply) {
    return Padding(
      padding: EdgeInsets.only(top: 10.0, bottom: 30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              //Author name
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  //Icon "Star"
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: SvgPicture.asset(
                      "assets/icons/star.svg",
                      color: mainColor,
                    ),
                  ),
                  //Author login
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      reply.author?.login ?? '',
                      textScaleFactor: 1.0,
                      style: TextStyle(color: mainColor),
                    ),
                  ),
                ],
              ),
              //Divider
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: 1,
                  height: 14,
                  decoration: BoxDecoration(color: HexColor.fromHex("#E2E5EB")),
                ),
              ),
              //Time
              Text(
                reply.datetime,
                textScaleFactor: 1.0,
                style: TextStyle(
                  color: HexColor.fromHex("#AAAAAA"),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                    width: 1,
                    height: 14,
                    decoration: BoxDecoration(
                      color: HexColor.fromHex("#E2E5EB"),
                    )),
              ),
              Expanded(
                child: SizedBox(
                    width: 12,
                    height: 12,
                    child: SvgPicture.asset(
                      "assets/icons/flag.svg",
                      color: HexColor.fromHex("#AAAAAA"),
                    )),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Html(
              data: reply.content,
              style: {
                'body': Style(
                  fontSize: FontSize(14.0),
                  color: HexColor.fromHex("#273044"),
                )
              },
            ),
          ),
        ],
      ),
    );
  }

  _buildBottom(QuestionsState state) {
    if (state is InitialQuestionsState) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is LoadedQuestionsState) {
      return Container(
        decoration: BoxDecoration(color: HexColor.fromHex("#273044"), boxShadow: [BoxShadow(color: HexColor.fromHex("#000000").withOpacity(.1), offset: Offset(0, 0), blurRadius: 6, spreadRadius: 2)]),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: 35,
                height: 35,
                child: Center(),
              ),
              Expanded(
                flex: 8,
                child: Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0),
                  child: MaterialButton(
                    height: 50,
                    color: mainColor,
                    onPressed: () {
                      if (demo) {
                        showDialogError(context, 'Demo Mode');
                      } else {
                        Navigator.of(context)
                            .pushNamed(
                          QuestionAskScreen.routeName,
                          arguments: QuestionAskScreenArgs(widget.lessonId),
                        )
                            .then((value) {
                          _refreshState();
                        });
                      }
                    },
                    child: Text(
                      "ASK A QUESTION",
                      textScaleFactor: 1.0,
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 35,
                height: 35,
                child: Center(),
              )
            ],
          ),
        ),
      );
    }
  }

  _refreshState() {
    _bloc.add(FetchEvent(widget.lessonId, widget.page, "", ""));
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
