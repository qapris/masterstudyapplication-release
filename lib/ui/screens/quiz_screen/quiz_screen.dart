import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masterstudy_app/data/models/LessonResponse.dart';
import 'package:masterstudy_app/data/models/QuizResponse.dart';
import 'package:masterstudy_app/data/utils.dart';
import 'package:masterstudy_app/theme/theme.dart';
import 'package:masterstudy_app/ui/bloc/quiz_screen/bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';


class QuizScreenArgs {
  final LessonResponse quizResponse;
  final int lessonId;
  final int courseId;

  QuizScreenArgs(this.quizResponse, this.lessonId, this.courseId);
}

class QuizScreen extends StatelessWidget {
  static const routeName = "quizScreen";
  final QuizScreenBloc bloc;

  const QuizScreen(this.bloc) : super();

  @override
  Widget build(BuildContext context) {
    QuizScreenArgs args = ModalRoute.of(context)?.settings.arguments as QuizScreenArgs;
    return BlocProvider<QuizScreenBloc>(
      create: (c) => bloc,
      child: QuizScreenWidget(args.quizResponse, args.lessonId, args.courseId),
    );
  }
}

class QuizScreenWidget extends StatefulWidget {
  final LessonResponse quizResponse;
  int lessonId;
  int courseId;

  QuizScreenWidget(this.quizResponse, this.lessonId, this.courseId) : super();

  @override
  State<StatefulWidget> createState() => QuizScreenWidgetState();
}

class QuizScreenWidgetState extends State<QuizScreenWidget> {
  late QuizScreenBloc _bloc;
  late WebViewController _webViewController;

  int? courseId;
  int? lessonId;

  @override
  void initState() {
    super.initState();
    courseId = widget.courseId;
    lessonId = widget.lessonId;
    _bloc = BlocProvider.of<QuizScreenBloc>(context);
    _bloc.add(FetchEvent(courseId!, lessonId!, widget.quizResponse));
  }

  // TODO: QUIZ DATA DELETE
  bool isCoursePassed(QuizResponse response) {
    bool passed = false;
    if (response.quiz_data.isNotEmpty) {
      widget.quizResponse.quiz_data.forEach((value) {
        if (value?.status == "passed") passed = true;
      });
    }
    return passed;
  }

  @override
  Widget build(BuildContext context) {
    log(widget.quizResponse.view_link.toString());
    return BlocBuilder<QuizScreenBloc, QuizScreenState>(
      bloc: _bloc,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: HexColor.fromHex("#273044"),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.quizResponse.section?.number,
                      textScaleFactor: 1.0,
                      style: TextStyle(fontSize: 14.0, color: Colors.white),
                    ),
                    Text(
                      widget.quizResponse.title,
                      textScaleFactor: 1.0,
                      style: TextStyle(fontSize: 14.0, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: _buildBody(),
        );
      },
    );
  }

  _buildBody() {
    return _buildWebView();
  }

  _buildWebView() {
    if (widget.quizResponse.view_link.isNotEmpty)
      return Stack(
        children: <Widget>[
          WebView(
            initialUrl: widget.quizResponse.view_link,
            javascriptMode: JavascriptMode.unrestricted,
            onPageFinished: (some) async {},
            onPageStarted: (some) {},
            onWebViewCreated: (controller) async {

              String header = preferences!.get("apiToken");
              Map<String, String> headers = {"token": header};

              controller.clearCache();
              this._webViewController = controller;
              controller.loadUrl(widget.quizResponse.view_link, headers: headers);
            },
            javascriptChannels: Set.from([
              JavascriptChannel(
                name: "lmsEvent",
                onMessageReceived: (JavascriptMessage result) {
                  if (jsonDecode(result.message)["event_type"] == "close_quiz") {
                    Navigator.pop(context);
                  }
                },
              ),
            ]),
          )
        ],
      );
  }
}
