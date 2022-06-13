import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:masterstudy_app/data/models/user_course.dart';
import 'package:masterstudy_app/data/utils.dart';
import 'package:masterstudy_app/main.dart';
import 'package:masterstudy_app/theme/theme.dart';
import 'package:masterstudy_app/ui/bloc/courses/bloc.dart';
import 'package:masterstudy_app/ui/screens/category_detail/category_detail_screen.dart';
import 'package:masterstudy_app/ui/screens/user_course/user_course.dart';
import 'package:masterstudy_app/ui/widgets/loading_error_widget.dart';

class CoursesScreen extends StatelessWidget {
  final Function addCoursesCallback;

  const CoursesScreen(this.addCoursesCallback) : super();

  @override
  Widget build(BuildContext context) => _CoursesWidget(addCoursesCallback);
}

class _CoursesWidget extends StatefulWidget {
  final Function addCoursesCallback;

  const _CoursesWidget(this.addCoursesCallback) : super();

  @override
  State<StatefulWidget> createState() => _CoursesWidgetState();
}

class _CoursesWidgetState extends State<_CoursesWidget> {
  late UserCoursesBloc _bloc;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _bloc = BlocProvider.of<UserCoursesBloc>(context)..add(FetchEvent());
    updateCompletedLesson();
  }

  @override
  Widget build(BuildContext context) {
    updateCompletedLesson();
    return Scaffold(
        backgroundColor: HexColor.fromHex("#F3F5F9"),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: mainColor,
          title: Text(
            localizations!.getLocalization("user_courses_screen_title"),
            textScaleFactor: 1.0,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        body: BlocBuilder<UserCoursesBloc, UserCoursesState>(
          bloc: _bloc,
          // ignore: missing_return
          builder: (context, state) {
            if (state is EmptyCacheCoursesState) {
              return Center(
                child: Text('You haven"t loaded courses'),
              );
            }

            if (state is LoadedCoursesState) return _buildList(state.courses);

            if (state is ErrorUserCoursesState)
              return Center(
                child: LoadingErrorWidget(() {
                  _bloc.add(FetchEvent());
                }),
              );

            if (state is InitialUserCoursesState)
              return Center(
                child: CircularProgressIndicator(),
              );

            if (state is EmptyCoursesState) return _buildEmptyList();

            return Text('Ошибка');
          },
        ));
  }

  ///Empty List
  _buildEmptyList() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 150,
            height: 150,
            child: SvgPicture.asset(
              "assets/icons/empty_courses.svg",
            ),
          ),
          Text(
            localizations!.getLocalization("no_user_courses_screen_title"),
            textScaleFactor: 1.0,
            style: TextStyle(color: HexColor.fromHex("#D7DAE2"), fontSize: 18),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: new MaterialButton(
                minWidth: double.infinity,
                color: secondColor,
                onPressed: () {
                  this.widget.addCoursesCallback();
                },
                child: Text(
                  localizations!.getLocalization("add_courses_button"),
                  textScaleFactor: 1.0,
                ),
                textColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///List with courses
  _buildList(List<PostsBean?> courses) {
    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return _CourseWidget(courses[index]!);
      },
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void updateCompletedLesson() async {
    ///Lessons Offline Mode
    final myList = recordMap;
    final jsonList = myList.map((item) => jsonEncode(item)).toList();
    final uniqueJsonList = jsonList.toSet().toList();
    final result = uniqueJsonList.map((item) => jsonDecode(item)).toList();

    ///Lessons Offline Mode
    if (_connectionStatus == ConnectivityResult.wifi || _connectionStatus == ConnectivityResult.mobile) {
      try {
        for (var el in result) {
          Response response = await dio.put(
            apiEndpoint + "course/lesson/complete",
            data: {"course_id": el['course_id'], "item_id": el['lesson_id']},
            options: Options(
              headers: {"requirestoken": "true"},
            ),
          );
        }
      } catch (e) {
        print(e);
      }
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
}

class _CourseWidget extends StatelessWidget {
  final PostsBean postsBean;

  const _CourseWidget(this.postsBean, {key}) : super(key: key);

  _openCourse(context) {
    var future = Navigator.of(context).pushNamed(
      UserCourseScreen.routeName,
      arguments: UserCourseScreenArgs.fromPostsBean(postsBean),
    );
    future.then((value) => {BlocProvider.of<UserCoursesBloc>(context)..add(FetchEvent())});
  }

  @override
  Widget build(BuildContext context) {
    ///From list delete same id

    var unescape = new HtmlUnescape();
    double imgHeight = (MediaQuery.of(context).size.width > 450) ? 370.0 : 160.0;

    ///Function for set category
    String category = "";
    if (postsBean.categories_object.isNotEmpty) {
      if (postsBean.categories_object.first?.name != null) {
        category = postsBean.categories_object.first!.name;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          borderOnForeground: true,
          elevation: 2.5,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(0.0),
            ),
          ),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    _openCourse(context);
                  },
                  child: Hero(
                    tag: postsBean.course_id,
                    child: CachedNetworkImage(
                      imageUrl: postsBean.app_image,
                      placeholder: (ctx, url) => SizedBox(
                        height: imgHeight,
                      ),
                      width: double.infinity,
                      height: imgHeight,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Visibility(
                  visible: postsBean.fromCache ?? true,
                  child: Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            CategoryDetailScreen.routeName,
                            arguments: CategoryDetailScreenArgs(postsBean.categories_object.first),
                          );
                        },
                        child: Text(
                          "${unescape.convert(category)} >",
                          textScaleFactor: 1.0,
                          style: TextStyle(fontSize: 16, color: HexColor.fromHex("#2a3045").withOpacity(0.5)),
                        ),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 16.0, right: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        UserCourseScreen.routeName,
                        arguments: UserCourseScreenArgs.fromPostsBean(postsBean),
                      );
                    },
                    child: Text(
                      "${unescape.convert(postsBean.title)}",
                      textScaleFactor: 1.0,
                      maxLines: 2,
                      style: TextStyle(fontSize: 22, color: dark, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Visibility(
                  visible: postsBean.fromCache ?? true,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      child: SizedBox(
                        height: 6,
                        child: LinearProgressIndicator(
                          value: int.parse(postsBean.progress) / 100,
                          backgroundColor: HexColor.fromHex("#D7DAE2"),
                          valueColor: new AlwaysStoppedAnimation(secondColor),
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: postsBean.fromCache ?? true,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        //Time Course
                        Text(
                          postsBean.duration ?? "",
                          textScaleFactor: 1.0,
                          style: TextStyle(color: HexColor.fromHex("#2a3045").withOpacity(0.5)),
                        ),
                        //Percent course complete
                        Text(
                          postsBean.progress_label ?? "",
                          textScaleFactor: 1.0,
                          style: TextStyle(color: HexColor.fromHex("#2a3045").withOpacity(0.5)),
                        ),
                      ],
                    ),
                  ),
                ),
                //Button 'CONTINUE'
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 16, right: 16, bottom: 16),
                  child: SizedBox(
                    child: new MaterialButton(
                      minWidth: double.infinity,
                      color: secondColor,
                      onPressed: () {
                        _openCourse(context);
                      },
                      child: Text(
                        localizations!.getLocalization("continue_button"),
                        textScaleFactor: 1.0,
                      ),
                      textColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
