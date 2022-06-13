import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:masterstudy_app/data/models/OrdersResponse.dart';
import 'package:masterstudy_app/data/models/category.dart';
import 'package:masterstudy_app/data/models/course/CourcesResponse.dart';
import 'package:masterstudy_app/data/utils.dart';
import 'package:masterstudy_app/theme/theme.dart';
import 'package:masterstudy_app/ui/bloc/course/bloc.dart';
import 'package:masterstudy_app/ui/screens/category_detail/category_detail_screen.dart';
import 'package:masterstudy_app/ui/screens/course/tabs/curriculum_widget.dart';
import 'package:masterstudy_app/ui/screens/course/tabs/overview_widget.dart';
import 'package:masterstudy_app/ui/screens/detail_profile/detail_profile_screen.dart';
import 'package:masterstudy_app/ui/screens/search_detail/search_detail_screen.dart';
import 'package:masterstudy_app/ui/screens/user_course/user_course.dart';
import 'package:masterstudy_app/ui/screens/web_checkout/web_checkout_screen.dart';
import 'package:masterstudy_app/ui/widgets/dialog_author.dart';
import 'package:masterstudy_app/ui/widgets/loading_error_widget.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../main.dart';
import '../purchase_dialog/purchase_dialog.dart';
import 'tabs/faq_widget.dart';

class CourseScreenArgs {
  int? id;
  String? title;
  ImagesBean? images;
  List<String?> categories;
  PriceBean? price;
  RatingBean? rating;
  String? featured;
  StatusBean? status;
  List<Category?> categories_object;

  CourseScreenArgs(this.id, this.title, this.images, this.categories, this.price, this.rating, this.featured, this.status, this.categories_object);

  CourseScreenArgs.fromCourseBean(CoursesBean coursesBean)
      : id = coursesBean.id,
        title = coursesBean.title,
        images = coursesBean.images,
        categories = coursesBean.categories,
        price = coursesBean.price,
        rating = coursesBean.rating,
        featured = coursesBean.featured,
        status = coursesBean.status,
        categories_object = coursesBean.categories_object;

  CourseScreenArgs.fromOrderListBean(Cart_itemsBean cart_itemsBean)
      : id = cart_itemsBean.cart_item_id,
        title = cart_itemsBean.title,
        images = ImagesBean(full: cart_itemsBean.image_url, small: cart_itemsBean.image_url),
        categories = [],
        price = null,
        rating = null,
        featured = null,
        status = null,
        categories_object = [];
}

class CourseScreen extends StatelessWidget {
  static const routeName = "courseScreen";
  final CourseBloc _bloc;

  const CourseScreen(this._bloc) : super();

  @override
  Widget build(BuildContext context) {
    final CourseScreenArgs args = ModalRoute.of(context)?.settings.arguments as CourseScreenArgs;
    return BlocProvider<CourseBloc>(create: (c) => _bloc, child: _CourseScreenWidget(args));
  }
}

class _CourseScreenWidget extends StatefulWidget {
  final CourseScreenArgs coursesBean;

  const _CourseScreenWidget(this.coursesBean);

  @override
  State<StatefulWidget> createState() => _CourseScreenWidgetState();
}

class _CourseScreenWidgetState extends State<_CourseScreenWidget> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController animation;
  late AnimationController animationBottom;
  late Animation<double> _fadeInFadeOut;
  late CourseBloc _bloc;
  late bool _isFav;
  var _favIcoColor = Colors.white;
  var screenHeight;
  String title = "";
  bool hasTrial = true;
  num kef = 2;
  String? selectedPlan = '';

  @override
  void initState() {
    super.initState();
    animationBottom = BottomSheet.createAnimationController(this);
    animationBottom.duration = Duration(seconds: 1);
    animation = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );
    _fadeInFadeOut = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: Interval(0.25, 1, curve: Curves.easeIn),
      ),
    );
    animation.forward();

    _scrollController = ScrollController()
      ..addListener(() {
        if (!_isAppBarExpanded) {
          setState(() {
            title = "";
          });
        } else {
          setState(() {
            title = "${widget.coursesBean.title}";
          });
        }
      });

    getToken();

    _bloc = BlocProvider.of<CourseBloc>(context)..add(FetchEvent(widget.coursesBean.id!));
  }

  String courseToken = '';

  Future getToken() async {
    Response response = await dio.post(apiEndpoint + 'get_auth_token_to_course', data: {'course_id': widget.coursesBean.id});

    courseToken = response.data['token_auth'];
  }

  @override
  Widget build(BuildContext context) {
    animation.forward();

    var unescape = new HtmlUnescape();
    kef = (MediaQuery.of(context).size.height > 690) ? kef : 1.8;

    return BlocListener<CourseBloc, CourseState>(
      bloc: _bloc,
      listener: (context, state) {
        ///Favorite Course or not
        if (state is LoadedCourseState) {
          setState(() {
            _isFav = state.courseDetailResponse.is_favorite!;
            _favIcoColor = (state.courseDetailResponse.is_favorite!) ? Colors.red : Colors.white;
          });
        }

        ///Purchase
        if (state is OpenPurchaseState) {
          var future = Navigator.pushNamed(
            context,
            WebCheckoutScreen.routeName,
            arguments: WebCheckoutScreenArgs(state.url),
          );
          future.then((value) {
            _bloc.add(FetchEvent(widget.coursesBean.id!));
          });
        }
      },
      child: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          var tabLength = 2;

          //Set tabLength
          if (state is LoadedCourseState) {
            if (state.courseDetailResponse.faq != null && state.courseDetailResponse.faq!.isNotEmpty) tabLength = 3;
          }

          return DefaultTabController(
            length: tabLength,
            child: Scaffold(
              body: NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  String? categories = "";
                  double? ratingAverage = 0.0;
                  dynamic ratingTotal = 0.0;

                  if (state is LoadedCourseState) {
                    if (state.courseDetailResponse.categories_object != null && state.courseDetailResponse.categories_object.isNotEmpty)
                      categories = state.courseDetailResponse.categories_object[0]?.name;
                    ratingAverage = state.courseDetailResponse.rating?.average!.toDouble();
                    ratingTotal = state.courseDetailResponse.rating!.total;
                  } else {
                    if (widget.coursesBean.categories_object != null && widget.coursesBean.categories_object.isNotEmpty) {
                      categories = widget.coursesBean.categories_object.first!.name;
                    }

                    if (widget.coursesBean.rating == null) {
                      ratingAverage = 0.0;
                      ratingTotal = 0.0;
                    }
                  }
                  return <Widget>[
                    SliverAppBar(
                      backgroundColor: mainColor,
                      title: Text(
                        title,
                        textScaleFactor: 1.0,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      expandedHeight: MediaQuery.of(context).size.height / kef,
                      floating: false,
                      pinned: true,
                      snap: false,
                      actions: <Widget>[
                        //Icon share
                        IconButton(
                          icon: Icon(Icons.share),
                          onPressed: () {
                            if (state is LoadedCourseState) Share.share(state.courseDetailResponse.url);
                          },
                        ),
                        //Icon fav
                        IconButton(
                          icon: Icon(Icons.favorite),
                          color: _favIcoColor,
                          onPressed: () {
                            setState(() {
                              _favIcoColor = _isFav ? Colors.white : Colors.red;
                              _isFav = (_isFav) ? false : true;
                            });

                            if (state is LoadedCourseState) {
                              if (state.courseDetailResponse.is_favorite!) {
                                _bloc.add(DeleteFromFavorite(widget.coursesBean.id!));
                              } else {
                                _bloc.add(AddToFavorite(widget.coursesBean.id!));
                              }
                            }
                          },
                        ),
                        //Icon search
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            Navigator.of(context).pushNamed(SearchDetailScreen.routeName, arguments: SearchDetailScreenArgs(""));
                          },
                        ),
                      ],
                      bottom: ColoredTabBar(
                        Colors.white,
                        TabBar(
                          indicatorColor: mainColorA,
                          tabs: [
                            Tab(
                              text: localizations!.getLocalization("course_overview_tab"),
                            ),
                            Tab(
                              text: localizations!.getLocalization("course_curriculum_tab"),
                            ),
                            if (state is LoadedCourseState)
                              if (state.courseDetailResponse.faq != null && state.courseDetailResponse.faq!.isNotEmpty)
                                Tab(
                                  text: localizations!.getLocalization("course_faq_tab"),
                                ),
                          ],
                        ),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.parallax,
                        background: Container(
                            child: Stack(
                          children: <Widget>[
                            Stack(
                              children: <Widget>[
                                Hero(
                                  tag: widget.coursesBean.images?.small as Object,
                                  child: FadeInImage.memoryNetwork(
                                    image: widget.coursesBean.images!.small!,
                                    fit: BoxFit.cover,
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height / kef,
                                    placeholder: kTransparentImage,
                                  ),
                                ),
                              ],
                            ),
                            FadeTransition(
                              opacity: _fadeInFadeOut,
                              child: Container(
                                decoration: BoxDecoration(color: mainColor?.withOpacity(0.5)),
                              ),
                            ),
                            FadeTransition(
                              opacity: _fadeInFadeOut,
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, right: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(top: 0.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.pushNamed(
                                                      context,
                                                      CategoryDetailScreen.routeName,
                                                      arguments: CategoryDetailScreenArgs(widget.coursesBean.categories_object[0]),
                                                    );
                                                  },
                                                  child: Text(
                                                    unescape.convert(categories),
                                                    textScaleFactor: 1.0,
                                                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.keyboard_arrow_right,
                                                  color: Colors.white.withOpacity(0.5),
                                                )
                                              ],
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (BuildContext context) => DialogAuthorWidget(state),
                                                );
                                              },
                                              child: CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                  (state is LoadedCourseState)
                                                      ? state.courseDetailResponse.author?.avatar_url ??
                                                          'https://eitrawmaterials.eu/wp-content/uploads/2016/09/person-icon.png'
                                                      : 'https://eitrawmaterials.eu/wp-content/uploads/2016/09/person-icon.png',
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Container(
                                          height: 140,
                                          child: Text(
                                            unescape.convert(widget.coursesBean.title),
                                            textScaleFactor: 1.0,
                                            style: TextStyle(color: Colors.white, fontSize: 40),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 32.0, right: 16.0),
                                        child: Row(
                                          children: <Widget>[
                                            RatingBar(
                                              initialRating: ratingAverage,
                                              minRating: 0,
                                              allowHalfRating: true,
                                              direction: Axis.horizontal,
                                              tapOnlyMode: true,
                                              glow: false,
                                              ignoreGestures: true,
                                              itemCount: 5,
                                              itemSize: 19,
                                              itemBuilder: (context, _) => Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                              onRatingUpdate: (rating) {},
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8.0),
                                              child: Text(
                                                "${ratingAverage?.toDouble()} (${ratingTotal} review)",
                                                textScaleFactor: 1.0,
                                                style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.5)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        )),
                      ),
                    )
                  ];
                },
                body: AnimatedSwitcher(
                  duration: Duration(milliseconds: 150),
                  child: _buildBody(state),
                ),
              ),
              bottomNavigationBar: _buildBottom(state),
            ),
          );
        },
      ),
    );
  }

  bool get _isAppBarExpanded {
    if (screenHeight == null) screenHeight = MediaQuery.of(context).size.height;
    if (_scrollController.offset > (screenHeight / kef - (kToolbarHeight * kef)))
      return _scrollController.hasClients && _scrollController.offset > (screenHeight / kef - (kToolbarHeight * kef));
    return false;
  }

  _buildBody(state) {
    if (state is InitialCourseState)
      return Center(
        child: CircularProgressIndicator(),
      );

    if (state is LoadedCourseState)
      return TabBarView(
        children: <Widget>[
          //OverviewWidget
          OverviewWidget(state.courseDetailResponse, state.reviewResponse, () {
            _scrollController.jumpTo(screenHeight / kef - (kToolbarHeight * kef));
          }),
          //CurriculumWidget
          CurriculumWidget(state.courseDetailResponse),
          //FaqWidget
          if (state.courseDetailResponse.faq != null && state.courseDetailResponse.faq!.isNotEmpty) FaqWidget(state.courseDetailResponse),
        ],
      );

    if (state is ErrorCourseState) {
      return LoadingErrorWidget(() {
        _bloc.add(FetchEvent(widget.coursesBean.id!));
      });
    }
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  bool isLoading = false;

  _buildBottom(CourseState state) {
    ///Button is "Start Course" if has_access == true
    if (state is LoadedCourseState && state.courseDetailResponse.has_access) {
      return Container(
        decoration: BoxDecoration(
          color: HexColor.fromHex("#F6F6F6"),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: MaterialButton(
            height: 40,
            color: secondColor,
            onPressed: () {
              Navigator.of(context).pushNamed(
                UserCourseScreen.routeName,
                arguments: UserCourseScreenArgs(
                  course_id: state.courseDetailResponse.id.toString(),
                  title: widget.coursesBean.title,
                  app_image: widget.coursesBean.images?.small,
                  avatar_url: state.courseDetailResponse.author?.avatar_url,
                  login: state.courseDetailResponse.author?.login,
                  authorId: "0",
                  progress: "1",
                  lesson_type: "",
                  lesson_id: "",
                  isFirstStart: true,
                ),
              );
            },
            child: Text(
              localizations!.getLocalization("start_course_button"),
              textScaleFactor: 1.0,
              style: TextStyle(color: white),
            ),
          ),
        ),
      );
    }

    ///If course not free
    return Container(
      decoration: BoxDecoration(
        color: HexColor.fromHex("#F6F6F6"),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            //Price Course
            _buildPrice(state),
            //Button "Get Now"
            MaterialButton(
              height: 40,
              color: mainColor,
              onPressed: () async {
                if (state is LoadedCourseState) {
                  if (_bloc.selectedPaymetId == -1) {
                    setState(() {
                      isLoading = true;
                    });

                    //GetTokenToBuyCourse
                    Response response = await dio.post(apiEndpoint + 'get_auth_token_to_course', data: {'course_id': widget.coursesBean.id});

                    setState(() {
                      isLoading = false;
                    });
                    showModalBottomSheet<void>(
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
                                          "This app doesn't support the In App Purchase\nPlease visit the website to continue",
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
                                    Material(
                                      color: Colors.transparent,
                                      child: SizedBox(
                                        height: 45,
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            primary: mainColor,
                                          ),
                                          onPressed: () async {
                                            _bloc.add(FetchEvent(widget.coursesBean.id!));
                                            await launch('${response.data['token_auth']}&payment=pay').then((value) {
                                              Navigator.of(context).pop();
                                            });
                                          },
                                          child: Text(
                                            'Continue',
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    _bloc.add(UsePlan(state.courseDetailResponse.id));
                  }
                }
              },
              child: setUpButtonChild(state, isLoading),
            )
          ],
        ),
      ),
    );
  }

  _buildPrice(CourseState state) {
    if (state is LoadedCourseState) {
      var userSubscriptions = state.userPlans?.subscriptions ?? [];
      if (state.courseDetailResponse.has_access == false) {
        if (state.courseDetailResponse.price?.free ?? false) {
          var dialog;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                localizations!.getLocalization("enroll_with_membership"),
                textScaleFactor: 1.0,
              ),
              IconButton(
                onPressed: () {
                  dialog = showDialog(
                    context: context,
                    builder: (builder) {
                      return StatefulBuilder(
                        builder: (context, setState) {
                          return BlocProvider.value(
                            child: Dialog(
                              child: PurchaseDialog(courseToken: courseToken),
                            ),
                            value: _bloc,
                          );
                        },
                      );
                    },
                  );

                  dialog.then((value) {
                    if (value == "update") {
                      _bloc.add(FetchEvent(widget.coursesBean.id!));
                    } else {
                      setState(() {
                        selectedPlan = value;
                      });
                    }
                  });
                },
                icon: Icon(Icons.arrow_drop_down),
              ),
            ],
          );
        } else {
          //Set price for course
          if (_bloc.selectedPaymetId == -1) {
            selectedPlan = "${localizations!.getLocalization("course_regular_price")} ${state.courseDetailResponse.price?.price}";
          }

          //If user have plans
          if (userSubscriptions.isNotEmpty) {
            userSubscriptions.forEach((value) {
              if (int.parse(value!.subscription_id) == _bloc.selectedPaymetId) {
                selectedPlan = value.name;
              }
            });
          }

          var dialog;

          return GestureDetector(
            onTap: () async {
              dialog = showDialog(
                context: context,
                builder: (builder) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return BlocProvider.value(
                        child: Dialog(
                          child: PurchaseDialog(courseToken: courseToken),
                        ),
                        value: _bloc,
                      );
                    },
                  );
                },
              );

              dialog.then((value) {
                if (value == "update") {
                  _bloc.add(FetchEvent(widget.coursesBean.id!));
                } else {
                  setState(() {
                    selectedPlan = value;
                  });
                }
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '${selectedPlan!}',
                  textScaleFactor: 1.0,
                ),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          );
        }
      } else {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[],
        );
      }
    }
    return Text("");
  }

  Widget setUpButtonChild(CourseState state, isLoading) {
    String buttonText = '';
    bool enable = state is LoadedCourseState;

    if (state is LoadedCourseState) {
      buttonText = state.courseDetailResponse.purchase_label!;
    }

    //For purchase get now (show alert)
    if (isLoading == true) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),
      );
    } else {
      Text(
        buttonText.toUpperCase(),
        textScaleFactor: 1.0,
      );
    }

    if (enable == true) {
      return new Text(
        buttonText.toUpperCase(),
        textScaleFactor: 1.0,
      );
    } else {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
