import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../theme/theme.dart';
import '../../bloc/lesson_zoom/bloc.dart';
import '../questions/questions_screen.dart';

class LessonZoomScreenArgs {
  final int courseId;
  final int lessonId;
  final String authorAva;
  final String authorName;
  final bool hasPreview;
  final bool trial;

  LessonZoomScreenArgs(this.courseId, this.lessonId, this.authorAva, this.authorName, this.hasPreview, this.trial);
}

class LessonZoomScreen extends StatelessWidget {
  static const routeName = 'lessonZoomScreen';
  final LessonZoomBloc _bloc;

  const LessonZoomScreen(this._bloc) : super();

  @override
  Widget build(BuildContext context) {
    final LessonZoomScreenArgs args = ModalRoute.of(context)?.settings.arguments as LessonZoomScreenArgs;

    return BlocProvider<LessonZoomBloc>(
      create: (c) => _bloc,
      child: LessonZoomScreenWidget(
        args.courseId,
        args.lessonId,
        args.authorAva,
        args.authorName,
        args.hasPreview,
        args.trial,
      ),
    );
  }
}

class LessonZoomScreenWidget extends StatefulWidget {
  final int courseId;
  final int lessonId;
  final String authorAva;
  final String authorName;
  final bool hasPreview;
  final bool trial;

  const LessonZoomScreenWidget(this.courseId, this.lessonId, this.authorAva, this.authorName, this.hasPreview, this.trial);

  @override
  State<LessonZoomScreenWidget> createState() => _LessonZoomScreenWidgetState();
}

class _LessonZoomScreenWidgetState extends State<LessonZoomScreenWidget> {
  late LessonZoomBloc _bloc;
  late WebViewController _webViewController;
  double? descriptionHeight;
  bool showLoadingWebview = true;

  @override
  void initState() {
    _bloc = BlocProvider.of<LessonZoomBloc>(context)..add(FetchEvent(widget.courseId, widget.lessonId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LessonZoomBloc, LessonZoomState>(
      bloc: _bloc,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: HexColor.fromHex("#151A25"),
          appBar: AppBar(
            backgroundColor: HexColor.fromHex("#273044"),
            title: _buildAppBar(state),
          ),
          body: _buildBody(state),
        );
      },
    );
  }


  _buildAppBar(state) {
    if (state is InitialLessonZoomState) {
      return const SizedBox();
    }

    if (state is LoadedLessonZoomState) {
      var item = state.lessonResponse;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          //Title and Label Course
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  item.section?.number,
                  textScaleFactor: 1.0,
                  style: TextStyle(fontSize: 14.0, color: Colors.white),
                ),
                Flexible(
                  child: Text(
                    item.section?.label,
                    textScaleFactor: 1.0,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          //Question Icon
          (widget.hasPreview)
              ? Center()
              : SizedBox(
                  width: 40,
                  height: 40,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                      backgroundColor: MaterialStateProperty.all(HexColor.fromHex("#3E4555")),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        QuestionsScreen.routeName,
                        arguments: QuestionsScreenArgs(widget.lessonId, 1),
                      );
                    },
                    child: SizedBox(
                        width: 24,
                        height: 24,
                        child: SvgPicture.asset(
                          "assets/icons/question_icon.svg",
                          color: Colors.white,
                        )),
                  ),
                )
        ],
      );
    }
  }

  _buildBody(state) {
    if (state is LoadedLessonZoomState) {
      var item = state.lessonResponse;
      return Column(
        children: <Widget>[
          Visibility(
            visible: showLoadingWebview,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          _buildWebView(item)
        ],
      );
    }

    if (state is InitialLessonZoomState) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  _buildWebView(item) {
    if (Platform.isAndroid || Platform.isIOS /*&& (androidInfo?.version.sdkInt == 30 || androidInfo?.version.sdkInt == 31)*/) {
      return Html(
        data: item.content,
      );
    }
    double webContainerHeight;
    if (descriptionHeight != null) {
      webContainerHeight = descriptionHeight!;
    } else {
      webContainerHeight = 160;
    }
    ConstrainedBox(
        constraints: BoxConstraints(maxHeight: webContainerHeight),
        child: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          gestureNavigationEnabled: true,
          initialUrl: 'data:/text/html;base64, ${base64Encode(const Utf8Encoder().convert(item.content))}',
          onPageFinished: (some) async {
            double height = double.parse(await _webViewController.runJavascriptReturningResult("document.documentElement.scrollHeight;"));
            setState(() {
              descriptionHeight = height;
              print("webview $height");
            });
          },
          onWebViewCreated: (controller) async {
            controller.clearCache();
            this._webViewController = controller;
          },
        ));
  }
}
