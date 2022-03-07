import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:masterstudy_app/data/models/curriculum.dart';
import 'package:masterstudy_app/data/models/user_course.dart';
import 'package:masterstudy_app/main.dart';
import 'package:masterstudy_app/theme/theme.dart';
import 'package:masterstudy_app/ui/bloc/user_course/bloc.dart';
import 'package:masterstudy_app/ui/screen/assignment/assignment_screen.dart';
import 'package:masterstudy_app/ui/screen/detail_profile/detail_profile_screen.dart';
import 'package:masterstudy_app/ui/screen/lesson_video/lesson_video_screen.dart';
import 'package:masterstudy_app/ui/screen/quiz_lesson/quiz_lesson_screen.dart';
import 'package:masterstudy_app/ui/screen/text_lesson/text_lesson_screen.dart';
import 'package:masterstudy_app/ui/widgets/loading_error_widget.dart';

class UserCourseScreenArgs {
  final String course_id;
  final String title;
  final String app_image;
  final String avatar_url;
  final String login;
  final String authorId;
  final String progress;
  String lesson_type;
  String lesson_id;
  String hash;
  PostsBean postsBean;

  UserCourseScreenArgs(
      this.course_id,
      this.title,
      this.app_image,
      this.avatar_url,
      this.login,
      this.authorId,
      this.progress,
      this.lesson_type,
      this.lesson_id)
      : this.postsBean = PostsBean(
            course_id: course_id,
            title: title,
            app_image: app_image,
            progress: progress,
            lesson_type: lesson_type,
            lesson_id: lesson_id,
            author: PostAuthorBean(
              id: authorId,
              avatar_url: avatar_url,
            ));

  UserCourseScreenArgs.fromPostsBean(PostsBean postsBean)
      : course_id = postsBean.course_id,
        title = postsBean.title,
        app_image = postsBean.app_image,
        avatar_url = postsBean.author.avatar_url,
        login = postsBean.author.login,
        authorId = postsBean.author.id,
        progress = postsBean.progress,
        lesson_type = postsBean.lesson_type,
        lesson_id = postsBean.lesson_id,
        this.hash = postsBean.hash,
        this.postsBean = postsBean;
}

class UserCourseScreen extends StatelessWidget {
  static const routeName = "userCourseScreen";
  final UserCourseBloc bloc;

  UserCourseScreen(
    this.bloc,
  ) : super();

  @override
  Widget build(BuildContext context) {
    final UserCourseScreenArgs args = ModalRoute.of(context).settings.arguments;
    return BlocProvider(
        create: (context) => bloc, child: UserCourseWidget(args));
  }
}

class UserCourseWidget extends StatefulWidget {
  final UserCourseScreenArgs args;

  const UserCourseWidget(this.args) : super();

  @override
  State<StatefulWidget> createState() {
    return UserCourseWidgetState();
  }
}

class UserCourseWidgetState extends State<UserCourseWidget> {
  ScrollController _scrollController;
  String title = "";
  UserCourseBloc _bloc;
  var unescape = new HtmlUnescape();

  bool get _isAppBarExpanded {
    return _scrollController.hasClients &&
        _scrollController.offset >
            (MediaQuery.of(context).size.height / 3 - (kToolbarHeight));
  }

  @override
  void initState() {
    super.initState();

    _bloc = BlocProvider.of<UserCourseBloc>(context)
      ..add(FetchEvent(widget.args));
    _scrollController = ScrollController()
      ..addListener(() {
        if (!_isAppBarExpanded) {
          setState(() {
            title = "";
          });
        } else {
          setState(() {
            title = unescape.convert(widget.args.title);
          });
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    num kef = (MediaQuery.of(context).size.height > 690) ? 3.3 : 3;

    return BlocBuilder<UserCourseBloc, UserCourseState>(
      bloc: BlocProvider.of(context),
      builder: (context, state) {
        return Scaffold(
          body: NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    title: Text(
                      title,
                      textScaleFactor: 1.0,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    expandedHeight: MediaQuery.of(context).size.height / kef,
                    floating: false,
                    pinned: true,
                    snap: false,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      background: Container(
                        child: Stack(
                          children: <Widget>[
                            Hero(
                                tag: widget.args.course_id,
                                child: CachedNetworkImage(
                                  imageUrl: widget.args.app_image,
                                  placeholder: (ctx, url) => SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height / 3 +
                                            MediaQuery.of(context).padding.top,
                                  ),
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.height / 3 +
                                          MediaQuery.of(context).padding.top,
                                  fit: BoxFit.cover,
                                )),
                            Container(
                              decoration: BoxDecoration(
                                  color: HexColor.fromHex("#2A3045")
                                      .withOpacity(0.7)),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height / kef,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                child: SafeArea(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 0.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: <Widget>[
                                              GestureDetector(
                                                onTap: () {
                                                  if (state
                                                      is LoadedUserCourseState)
                                                    Navigator.pushNamed(
                                                      context,
                                                      DetailProfileScreen
                                                          .routeName,
                                                      arguments:
                                                          DetailProfileScreenArgs
                                                              .fromId(int.parse(
                                                                  widget.args
                                                                      .authorId)),
                                                    );
                                                },
                                                child: CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(
                                                  (state is LoadedUserCourseState)
                                                      ? widget.args.avatar_url
                                                      : "",
                                                )),
                                              )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Container(
                                            height: 55,
                                            child: Text(
                                              unescape
                                                  .convert(widget.args.title),
                                              textScaleFactor: 1.0,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 16.0),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30)),
                                            child: SizedBox(
                                              height: 6,
                                              child: LinearProgressIndicator(
                                                value: int.parse((state
                                                            is LoadedUserCourseState)
                                                        ? state.progress
                                                        : "0") /
                                                    100,
                                                backgroundColor:
                                                    HexColor.fromHex("#D7DAE2"),
                                                valueColor:
                                                    new AlwaysStoppedAnimation(
                                                        secondColor),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 16.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Expanded(
                                                flex: 5,
                                                child: MaterialButton(
                                                  minWidth: double.infinity,
                                                  color: secondColor,
                                                  onPressed: () {
                                                    if (state
                                                        is LoadedUserCourseState) {
                                                      if (state.response
                                                                  .sections !=
                                                              null &&
                                                          state
                                                              .response
                                                              .sections
                                                              .isNotEmpty) {
                                                        var containsLastLesson =
                                                            false;
                                                        state.response.sections
                                                            .forEach((section) {
                                                          if (section.section_items !=
                                                                  null &&
                                                              section
                                                                  .section_items
                                                                  .isNotEmpty) {
                                                            section
                                                                .section_items
                                                                .forEach(
                                                                    (sectionItem) {
                                                              if (sectionItem
                                                                      .item_id ==
                                                                  int.tryParse(
                                                                      widget
                                                                          .args
                                                                          .lesson_id))
                                                                containsLastLesson =
                                                                    true;
                                                            });
                                                          }
                                                        });
                                                        if (containsLastLesson) {
                                                          _openLesson(
                                                              widget.args
                                                                  .lesson_type,
                                                              int.tryParse(widget
                                                                  .args
                                                                  .lesson_id));
                                                        }
                                                      }
                                                    }
                                                  },
                                                  child: Text(
                                                    "CONTINUE",
                                                    textScaleFactor: 1.0,
                                                  ),
                                                  textColor: Colors.white,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 20.0),
                                                child: _buildCacheButton(state),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ];
              },
              body: _buildBody(state)),
        );
      },
    );
  }

  _openLesson(String type, int id) {
    Future screenFuture = null;
    switch (type) {
      case "quiz":
        screenFuture = Navigator.of(context).pushNamed(
          QuizLessonScreen.routeName,
          arguments: QuizLessonScreenArgs(int.parse(widget.args.course_id), id,
              widget.args.avatar_url, widget.args.login),
        );
        break;
      case "text":
        screenFuture = Navigator.of(context).pushNamed(
          TextLessonScreen.routeName,
          arguments: TextLessonScreenArgs(int.parse(widget.args.course_id), id,
              widget.args.avatar_url, widget.args.login, false, true),
        );
        break;
      case "video":
        screenFuture = Navigator.of(context).pushNamed(
          LessonVideoScreen.routeName,
          arguments: LessonVideoScreenArgs(int.tryParse(widget.args.course_id),
              id, widget.args.avatar_url, widget.args.login, false, true),
        );
        break;
      case "assignment":
        screenFuture = Navigator.of(context).pushNamed(
          AssignmentScreen.routeName,
          arguments: AssignmentScreenArgs(int.tryParse(widget.args.course_id),
              id, widget.args.avatar_url, widget.args.login),
        );
        break;
      default:
        screenFuture = Navigator.of(context).pushNamed(
          TextLessonScreen.routeName,
          arguments: TextLessonScreenArgs(int.tryParse(widget.args.course_id),
              id, widget.args.avatar_url, widget.args.login, false, true),
        );
    }
    if (screenFuture != null) {
      screenFuture.then((value) => {_bloc.add(FetchEvent(widget.args))});
    }
  }

  _buildCacheButton(state) {
    if (state is LoadedUserCourseState) {
      Widget icon;
      if (state.isCached) {
        icon = Icon(
          Icons.check,
          color: Colors.white,
        );
      } else if (state.showCachingProgress) {
        icon = CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.white),
        );
      } else {
        icon = Icon(
          Icons.cloud_download,
          color: Colors.white,
        );
      }
      return SizedBox(
        width: 50,
        height: 50,
        child: FlatButton(
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            onPressed: () {
              if (state is LoadedUserCourseState &&
                  !state.showCachingProgress &&
                  !state.isCached) {
                _bloc.add(CacheCourseEvent(widget.args));
              }
            },
            padding: EdgeInsets.only(left: 0.0),
            color: HexColor.fromHex("#FFFFFF").withOpacity(0.1),
            child: icon),
      );
    } else {
      return SizedBox(width: 50, height: 50);
    }
  }

  _buildBody(state) {
    if (state is InitialUserCourseState) return _buildLoading();
    if (state is LoadedUserCourseState) {
      widget.args.lesson_id = state.response.current_lesson_id;
      widget.args.lesson_type = state.response.lesson_type;
      return _buildCurriculum(state);
    }
    if (state is ErrorUserCourseState)
      return Center(
        child: LoadingErrorWidget(() {
          _bloc.add(FetchEvent(widget.args));
        }),
      );
  }

  _buildLoading() => Center(
        child: CircularProgressIndicator(),
      );

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
            localizations.getLocalization("empty_sections_course"),
            textScaleFactor: 1.0,
            style: TextStyle(color: HexColor.fromHex("#D7DAE2"), fontSize: 18),
          ),
        ],
      ),
    );
  }

  _buildCurriculum(LoadedUserCourseState state) {
    if (state.sections == null || state.sections.isEmpty) {
      return _buildEmptyList();
    }
    return ListView.builder(
        itemCount: state.sections.length,
        itemBuilder: (context, index) {
          return _buildSection(state.sections[index]);
        });
  }

  _buildSection(SectionItem sectionItem) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                sectionItem.number,
                textScaleFactor: 1.0,
                style: TextStyle(color: HexColor.fromHex("#AAAAAA")),
              ),
              Text(
                sectionItem.title,
                textScaleFactor: 1.0,
                style: TextStyle(
                    color: HexColor.fromHex("#273044"),
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        if (sectionItem.section_items != null &&
            sectionItem.section_items.isNotEmpty)
          Column(
            children: sectionItem.section_items.map((value) {
              return _buildLesson(
                value,
              );
            }).toList(),
          )
      ],
    );
  }

  Widget _buildLesson(Section_itemsBean section_itemsBean) {
    bool locked = section_itemsBean.locked && dripContentEnabled;
    Widget icon = Center();
    String duration = section_itemsBean.duration;

    if (section_itemsBean.type == "video")
      icon = SizedBox(
          width: 24,
          height: 24,
          child: SvgPicture.asset("assets/icons/ico_play.svg",
              color: (!locked)
                  ? mainColor
                  : HexColor.fromHex("#2A3045").withOpacity(0.3)));
    if (section_itemsBean.type == "stream")
      icon = SizedBox(
          width: 24,
          height: 24,
          child: SvgPicture.asset("assets/icons/video-camera.svg",
              color: (!locked)
                  ? mainColor
                  : HexColor.fromHex("#2A3045").withOpacity(0.3)));
    if (section_itemsBean.type == "slide")
      icon = SizedBox(
          width: 24,
          height: 24,
          child: SvgPicture.asset("assets/icons/slides_icon.svg",
              color: (!locked)
                  ? mainColor
                  : HexColor.fromHex("#2A3045").withOpacity(0.3)));
    if (section_itemsBean.type == "assignment")
      icon = SizedBox(
          width: 24,
          height: 24,
          child: SvgPicture.asset("assets/icons/assignment_icon.svg",
              color: (!locked)
                  ? mainColor
                  : HexColor.fromHex("#2A3045").withOpacity(0.3)));
    if (section_itemsBean.type == "quiz") {
      duration = section_itemsBean.questions;
      icon = SizedBox(
          width: 24,
          height: 24,
          child: SvgPicture.asset("assets/icons/ico_question.svg",
              color: (!locked)
                  ? mainColor
                  : HexColor.fromHex("#2A3045").withOpacity(0.3)));
    }
    if (section_itemsBean.type == "text" || section_itemsBean.type == "")
      icon = SizedBox(
          width: 24,
          height: 24,
          child: SvgPicture.asset("assets/icons/ico_text.svg",
              color: (!locked)
                  ? mainColor
                  : HexColor.fromHex("#2A3045").withOpacity(0.3)));

    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: InkWell(
        onTap: () {
          if (!locked)
            _openLesson(section_itemsBean.type, section_itemsBean.item_id);
        },
        child: Container(
          decoration: BoxDecoration(color: HexColor.fromHex("#F3F5F9")),
          child: Padding(
            padding: const EdgeInsets.only(
                top: 16.0, bottom: 16, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      icon,
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: Text(
                            section_itemsBean.title ?? "",
                            textScaleFactor: 1.0,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                                color: locked
                                    ? Colors.black.withOpacity(0.3)
                                    : Colors.black),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Stack(
                  children: <Widget>[
                    Visibility(
                      visible: locked,
                      child: SizedBox(
                          width: 24,
                          height: 24,
                          child: SvgPicture.asset("assets/icons/ico_lock.svg",
                              color: mainColor)),
                    ),
                    Visibility(
                      visible:
                          !locked && duration != null && duration.isNotEmpty,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                              width: 14,
                              height: 14,
                              child: SvgPicture.asset(
                                  'assets/icons/duration_curriculum_icon.svg')),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              duration ?? "",
                              textScaleFactor: 1.0,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.3)),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
