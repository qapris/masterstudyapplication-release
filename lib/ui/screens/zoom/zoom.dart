import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:masterstudy_app/data/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../main.dart';
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
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  double? descriptionHeight;
  bool showLoadingWebview = true;

  @override
  void initState() {
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _bloc = BlocProvider.of<LessonZoomBloc>(context)..add(FetchEvent(widget.courseId, widget.lessonId));
    ImageDownloader.callback(onProgressUpdate: (String? imageId, int progress) {
      setState(() {
        _progressImg = progress;
      });

      if (progress == 100) {
        setState(() {
          isLoadingImg = false;
        });
      }
    });
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
            body: SingleChildScrollView(
              child: _buildBody(state),
            ));
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
                ),
        ],
      );
    }
  }

  var progress = '';
  int _progressImg = 0;
  bool isLoading = false;
  bool isLoadingImg = false;
  Map<String, dynamic>? progressMap = {};
  Map<String, dynamic>? progressMapImg = {};
  Widget? svgIcon;

  _buildBody(state) {
    if (state is LoadedLessonZoomState) {
      var item = state.lessonResponse;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildWebView(item),
          const SizedBox(height: 20),
          _connectionStatus == ConnectivityResult.wifi || _connectionStatus == ConnectivityResult.mobile
              ? ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: state.lessonResponse.materials.length,
                  itemBuilder: (BuildContext ctx, int index) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      margin: EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Text 'Materials'
                          state.lessonResponse.materials.isNotEmpty
                              ? Text(
                                  'Materials:',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : const SizedBox(),
                          //Materials
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: state.lessonResponse.materials.length,
                            itemBuilder: (BuildContext ctx, int index) {
                              var item = state.lessonResponse.materials[index];
                              switch (item!.type) {
                                case 'audio':
                                  svgIcon = SvgPicture.asset('assets/icons/audio.svg');
                                  break;
                                case 'avi':
                                  svgIcon = SvgPicture.asset('assets/icons/avi.svg');
                                  break;
                                case 'doc':
                                  svgIcon = SvgPicture.asset('assets/icons/doc.svg');
                                  break;
                                case 'docx':
                                  svgIcon = SvgPicture.asset('assets/icons/docx.svg');
                                  break;
                                case 'gif':
                                  svgIcon = SvgPicture.asset('assets/icons/gif.svg');
                                  break;
                                case 'jpeg':
                                  svgIcon = SvgPicture.asset('assets/icons/jpeg.svg');
                                  break;
                                case 'jpg':
                                  svgIcon = SvgPicture.asset('assets/icons/jpg.svg');
                                  break;
                                case 'mov':
                                  svgIcon = SvgPicture.asset('assets/icons/mov.svg');
                                  break;
                                case 'mp3':
                                  svgIcon = SvgPicture.asset('assets/icons/mp3.svg');
                                  break;
                                case 'mp4':
                                  svgIcon = SvgPicture.asset('assets/icons/mp4.svg');
                                  break;
                                case 'pdf':
                                  svgIcon = SvgPicture.asset('assets/icons/pdf.svg');
                                  break;
                                case 'png':
                                  svgIcon = SvgPicture.asset('assets/icons/png.svg');
                                  break;
                                case 'ppt':
                                  svgIcon = SvgPicture.asset('assets/icons/ppt.svg');
                                  break;
                                case 'pptx':
                                  svgIcon = SvgPicture.asset('assets/icons/pptx.svg');
                                  break;
                                case 'psd':
                                  svgIcon = SvgPicture.asset('assets/icons/psd.svg');
                                  break;
                                case 'txt':
                                  svgIcon = SvgPicture.asset('assets/icons/txt.svg');
                                  break;
                                case 'xls':
                                  svgIcon = SvgPicture.asset('assets/icons/xls.svg');
                                  break;
                                case 'xlsx':
                                  svgIcon = SvgPicture.asset('assets/icons/xlsx.svg');
                                  break;
                                case 'zip':
                                  svgIcon = SvgPicture.asset('assets/icons/zip.svg');
                                  break;
                                default:
                                  svgIcon = SvgPicture.asset('assets/icons/txt.svg');
                              }
                              return Container(
                                margin: EdgeInsets.only(top: 20),
                                padding: EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: mainColor,
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(width: 50, height: 30, child: svgIcon!),
                                    //Materials Label
                                    Expanded(
                                      child: Text(
                                        '${item.label}.${item.type} (${item.size})',
                                        style: TextStyle(
                                          color: HexColor.fromHex("#FFFFFF"),
                                        ),
                                      ),
                                    ),

                                    item.url == progressMap!['itemUrl']
                                        ? Text(
                                            progress,
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          )
                                        : const SizedBox(),
                                    //Icon download
                                    IconButton(
                                      onPressed: isLoading || isLoadingImg
                                          ? null
                                          : () async {
                                              String? dir;
                                              if (Platform.isAndroid) {
                                                dir = (await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS));
                                              } else if (Platform.isIOS) {
                                                dir = (await getApplicationDocumentsDirectory()).path;
                                              }
                                              var cyrillicSymbols = RegExp('[а-яёА-ЯЁ]');

                                              bool isSymbols = cyrillicSymbols.hasMatch(item.url);

                                              //If file is jpeg/png/jpg
                                              if (item.url.toString().contains('jpeg') || item.url.toString().contains('png') || item.url.toString().contains('jpg')) {
                                                setState(() {
                                                  isLoadingImg = true;
                                                });

                                                if (Platform.isIOS && isSymbols) {
                                                  //If file container cyrillic symbols
                                                  AlertDialog alert = AlertDialog(
                                                    title: Text('Error image', textScaleFactor: 1.0, style: TextStyle(color: Colors.black, fontSize: 20.0)),
                                                    content: Text(
                                                      "Photo format error",
                                                      textScaleFactor: 1.0,
                                                    ),
                                                    actions: [
                                                      ElevatedButton(
                                                        child: Text(
                                                          'Ok',
                                                          textScaleFactor: 1.0,
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(context).pop();
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          primary: Colors.white,
                                                        ),
                                                      )
                                                    ],
                                                  );
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return alert;
                                                    },
                                                  );
                                                } else {
                                                  setState(() {
                                                    isLoadingImg = true;
                                                    progressMapImg!['item_url'] = item.url;
                                                  });

                                                  var imageId = await ImageDownloader.downloadImage(item.url);

                                                  if (imageId == null) {
                                                    return print('Error');
                                                  }
                                                }
                                              } else {
                                                setState(() {
                                                  isLoading = true;
                                                  progressMap!['item_url'] = item.url;
                                                });

                                                String fileName = item.url.substring(item.url.lastIndexOf("/") + 1);

                                                String fullPath = dir! + '/$fileName';

                                                Response response = await dio.get(
                                                  item.url,
                                                  onReceiveProgress: (received, total) {
                                                    setState(() {
                                                      progress = ((received / total * 100).toStringAsFixed(0) + '%');
                                                    });
                                                    progressMap!.addParam('progress', progress);
                                                  },

                                                  //Received data with List<int>
                                                  options: Options(
                                                    responseType: ResponseType.bytes,
                                                    followRedirects: false,
                                                  ),
                                                );

                                                if (mounted) {
                                                  setState(() {
                                                    isLoading = false;
                                                  });
                                                }
                                              }
                                            },
                                      icon: isLoadingImg && item.url == progressMapImg!['item_url'] || isLoading && item.url == progressMap!['item_url']
                                          ? SizedBox(
                                              width: 25,
                                              height: 25,
                                              child: CircularProgressIndicator(
                                                valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : Icon(
                                              _progressImg == 100 && item.url == progressMapImg!['item_url'] || progress == '${100}%' && item.url == progressMap!['item_url']
                                                  ? Icons.check
                                                  : Icons.download,
                                              color: Colors.white,
                                            ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    );
                  })
              : const SizedBox(),
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
    /*  if ( Platform.isIOS) {
      return Html(
        data: item.content,
        style: {
          "body": Style(
            margin: EdgeInsets.all(20),
            fontSize: FontSize(18.0),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          '.btn.stm-join-btn.join_in_menu': Style(
            color: Colors.red,
          ),
        },
      );
    }*/

    double webContainerHeight;
    if (descriptionHeight != null) {
      webContainerHeight = descriptionHeight!;
    } else {
      webContainerHeight = 200;
    }
    return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: webContainerHeight),
        child: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          gestureNavigationEnabled: true,
          backgroundColor: HexColor.fromHex("#151A25"),
          initialUrl: item.content,
          onPageFinished: (_) async {
            double height = double.parse(await _webViewController.runJavascriptReturningResult("document.documentElement.scrollHeight;"));
            setState(() {
              descriptionHeight = height;
              showLoadingWebview = false;
            });
          },
          onWebViewCreated: (controller) async {
            controller.clearCache();
            this._webViewController = controller;
            _webViewController.loadUrl(Uri.dataFromString(
              item.content,
              mimeType: 'text/html',
              encoding: Encoding.getByName('utf-8'),
            ).toString());
          },
          navigationDelegate: (NavigationRequest request) async {
            if (request.url.contains('data:text/html')) {
              return NavigationDecision.navigate;
            } else {
              _launchURL(request.url);
              return NavigationDecision.prevent;
            }
          },
        ));
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      log(e.toString());
      return;
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
