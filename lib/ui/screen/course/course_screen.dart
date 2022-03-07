import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:masterstudy_app/data/models/OrdersResponse.dart';
import 'package:masterstudy_app/data/models/category.dart';
import 'package:masterstudy_app/data/models/course/CourcesResponse.dart';
import 'package:masterstudy_app/data/network/api_provider.dart';
import 'package:masterstudy_app/theme/theme.dart';
import 'package:masterstudy_app/ui/bloc/course/bloc.dart';
import 'package:masterstudy_app/ui/screen/category_detail/category_detail_screen.dart';
import 'package:masterstudy_app/ui/screen/course/tabs/curriculum_widget.dart';
import 'package:masterstudy_app/ui/screen/course/tabs/overview_widget.dart';
import 'package:masterstudy_app/ui/screen/detail_profile/detail_profile_screen.dart';
import 'package:masterstudy_app/ui/screen/porchase_dialog/purchase_dialog.dart';
import 'package:masterstudy_app/ui/screen/search_detail/search_detail_screen.dart';
import 'package:masterstudy_app/ui/screen/user_course/user_course.dart';
import 'package:masterstudy_app/ui/screen/web_checkout/web_checkout_screen.dart';
import 'package:masterstudy_app/ui/widgets/dialog_author.dart';
import 'package:masterstudy_app/ui/widgets/loading_error_widget.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../../main.dart';
import 'tabs/faq_widget.dart';

class CourseScreenArgs {
  num id;
  String title;
  ImagesBean images;
  List<String> categories;
  PriceBean price;
  RatingBean rating;
  String featured;
  StatusBean status;
  List<Category> categories_object;

  CourseScreenArgs(
      this.id,
      this.title,
      this.images,
      this.categories,
      this.price,
      this.rating,
      this.featured,
      this.status,
      this.categories_object);

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
        images = ImagesBean(
            full: cart_itemsBean.image_url, small: cart_itemsBean.image_url),
        categories = null,
        price = null,
        rating = null,
        featured = null,
        status = null,
        categories_object = null;
}

class CourseScreen extends StatelessWidget {
  static const routeName = "courseScreen";
  final CourseBloc _bloc;

  const CourseScreen(this._bloc) : super();

  @override
  Widget build(BuildContext context) {
    final CourseScreenArgs args = ModalRoute.of(context).settings.arguments;
    return BlocProvider<CourseBloc>(
        create: (c) => _bloc, child: _CourseScreenWidget(args));
  }
}

class _CourseScreenWidget extends StatefulWidget {
  final CourseScreenArgs coursesBean;

  const _CourseScreenWidget(this.coursesBean);

  @override
  State<StatefulWidget> createState() {
    return _CourseScreenWidgetState();
  }
}

class _CourseScreenWidgetState extends State<_CourseScreenWidget>
    with TickerProviderStateMixin {
  ScrollController _scrollController;
  String title = "";
  var _favIcoColor = Colors.white;
  AnimationController animation;
  Animation<double> _fadeInFadeOut;
  CourseBloc _bloc;
  bool hasTrial = true;
  bool _isFav = false;
  num kef = 2;

  var screenHeight;

  @override
  void initState() {
    super.initState();
    animation = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );
    _fadeInFadeOut = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: animation, curve: Interval(0.25, 1, curve: Curves.easeIn)));
    animation.forward();

    _scrollController = ScrollController()
      ..addListener(() {
        if (!_isAppBarExpanded) {
          setState(() {
            title = "";
          });
        } else {
          //if (_bloc.account != null) {
          setState(() {
            title = "${widget.coursesBean.title}";
          });
          //}
        }
      });

    _bloc = BlocProvider.of<CourseBloc>(context)
      ..add(FetchEvent(widget.coursesBean.id));

    _initInApp();
  }

  @override
  Widget build(BuildContext context) {
    animation.forward();

    var unescape = new HtmlUnescape();
    kef = (MediaQuery.of(context).size.height > 690) ? kef : 1.8;

    return BlocListener<CourseBloc, CourseState>(
      bloc: _bloc,
      listener: (context, state) {
        if (state is LoadedCourseState) {
          setState(() {
            _isFav = state.courseDetailResponse.is_favorite;
            _favIcoColor = (state.courseDetailResponse.is_favorite)
                ? Colors.red
                : Colors.white;
          });
        }

        if (state is OpenPurchaseState) {
          var future = Navigator.pushNamed(
            context,
            WebCheckoutScreen.routeName,
            arguments: WebCheckoutScreenArgs(state.url),
          );
          future.then((value) {
            _bloc.add(FetchEvent(widget.coursesBean.id));
          });
        }
      },
      child: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          var tabLength = 2;
          if (state is LoadedCourseState) {
            if (state.courseDetailResponse.faq != null &&
                state.courseDetailResponse.faq.isNotEmpty) tabLength = 3;
          }
          return DefaultTabController(
            length: tabLength,
            child: Scaffold(
              body: NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  String categories = "";
                  double ratingAverage = 0.0;
                  num ratingTotal = 0.0;

                  if (state is LoadedCourseState) {
                    if (state.courseDetailResponse.categories_object != null &&
                        state.courseDetailResponse.categories_object.isNotEmpty)
                      categories =
                          state.courseDetailResponse.categories_object[0].name;
                    ratingAverage =
                        state.courseDetailResponse.rating.average.toDouble();
                    ratingTotal = state.courseDetailResponse.rating.total;
                  } else {
                    if (widget.coursesBean.categories_object != null &&
                        widget.coursesBean.categories_object.isNotEmpty) {
                      categories =
                          widget.coursesBean.categories_object.first.name;
                    }

                    if (widget.coursesBean.rating == null) {
                      ratingAverage = 0.0;
                      ratingTotal = 0.0;
                    }
                  }
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
                      actions: <Widget>[
                        IconButton(
                          icon: Icon(Icons.share),
                          onPressed: () {
                            if (state is LoadedCourseState)
                              Share.share(state.courseDetailResponse.url);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.favorite),
                          color: _favIcoColor,
                          onPressed: () {
                            setState(() {
                              _favIcoColor =
                                  (_isFav) ? Colors.white : Colors.red;
                              _isFav = (_isFav) ? false : true;
                            });

                            if (state is LoadedCourseState) {
                              if (state.courseDetailResponse.is_favorite) {
                                _bloc.add(
                                    DeleteFromFavorite(widget.coursesBean.id));
                              } else {
                                _bloc.add(AddToFavorite(widget.coursesBean.id));
                              }
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                                SearchDetailScreen.routeName,
                                arguments: SearchDetailScreenArgs(""));
                          },
                        ),
                      ],
                      bottom: ColoredTabBar(
                          Colors.white,
                          TabBar(
                            indicatorColor: mainColorA,
                            tabs: [
                              Tab(
                                text: localizations
                                    .getLocalization("course_overview_tab"),
                              ),
                              Tab(
                                  text: localizations.getLocalization(
                                      "course_curriculum_tab")),
                              if (state is LoadedCourseState)
                                if (state.courseDetailResponse.faq != null &&
                                    state.courseDetailResponse.faq.isNotEmpty)
                                  Tab(
                                      text: localizations
                                          .getLocalization("course_faq_tab")),
                            ],
                          )),
                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.parallax,
                        background: Container(
                            child: Stack(
                          children: <Widget>[
                            Stack(
                              children: <Widget>[
                                Hero(
                                  tag: widget.coursesBean.images.small,
                                  child: FadeInImage.memoryNetwork(
                                    image: "${widget.coursesBean.images.small}",
                                    fit: BoxFit.cover,
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height /
                                        kef,
                                    placeholder: kTransparentImage,
                                  ),
                                ),
                              ],
                            ),
                            FadeTransition(
                              opacity: _fadeInFadeOut,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: mainColor.withOpacity(0.5)),
                              ),
                            ),
                            FadeTransition(
                              opacity: _fadeInFadeOut,
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 0.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.pushNamed(
                                                      context,
                                                      CategoryDetailScreen
                                                          .routeName,
                                                      arguments:
                                                          CategoryDetailScreenArgs(
                                                              widget.coursesBean
                                                                  .categories_object[0]),
                                                    );
                                                  },
                                                  child: Text(
                                                    unescape
                                                        .convert(categories),
                                                    textScaleFactor: 1.0,
                                                    style: TextStyle(
                                                        color: Colors.white
                                                            .withOpacity(0.5),
                                                        fontSize: 16),
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.keyboard_arrow_right,
                                                  color: Colors.white
                                                      .withOpacity(0.5),
                                                )
                                              ],
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (BuildContext
                                                          context) =>
                                                      DialogAuthorWidget(state),
                                                );
                                              },
                                              child: CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                (state is LoadedCourseState)
                                                    ? state.courseDetailResponse
                                                        .author.avatar_url
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
                                          height: 140,
                                          child: Text(
                                            unescape.convert(
                                                widget.coursesBean.title),
                                            textScaleFactor: 1.0,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 40),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 32.0, right: 16.0),
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
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Text(
                                                "${ratingAverage.toDouble()} (${ratingTotal} review)",
                                                textScaleFactor: 1.0,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white
                                                        .withOpacity(0.5)),
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
                    child: _buildBody(state)),
              ),
              bottomNavigationBar: _buildBottom(state),
            ),
          );
        },
      ),
    );
  }

  _buildBody(state) {
    if (state is InitialCourseState)
      return Center(
        child: CircularProgressIndicator(),
      );

    if (state is LoadedCourseState)
      return TabBarView(
        children: <Widget>[
          OverviewWidget(state.courseDetailResponse, state.reviewResponse, () {
            _scrollController
                .jumpTo(screenHeight / kef - (kToolbarHeight * kef));
          }),
          CurriculumWidget(state.courseDetailResponse),
          if (state.courseDetailResponse.faq != null &&
              state.courseDetailResponse.faq.isNotEmpty)
            FaqWidget(state.courseDetailResponse),
        ],
      );
    if (state is ErrorCourseState) {
      return LoadingErrorWidget(() {
        _bloc.add(FetchEvent(widget.coursesBean.id));
      });
    }
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  bool get _isAppBarExpanded {
    if (screenHeight == null) screenHeight = MediaQuery.of(context).size.height;
    if (_scrollController.offset >
        (screenHeight / kef - (kToolbarHeight * kef)))
      return _scrollController.hasClients &&
          _scrollController.offset >
              (screenHeight / kef - (kToolbarHeight * kef));
  }

  _buildBottom(CourseState state) {
    if (state is LoadedCourseState && state.courseDetailResponse.has_access) {
      return Container(
          decoration: BoxDecoration(
            color: HexColor.fromHex("#F6F6F6"),
          ),
          child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildStartButton(state)));
    }

    return Container(
      decoration: BoxDecoration(
        color: HexColor.fromHex("#F6F6F6"),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildPrice(state),
            MaterialButton(
              height: 40,
              color: mainColor,
              onPressed: () {
                if (state is LoadedCourseState) {
                  if (Platform.isIOS) {
                    if (_products.isNotEmpty) {
                      PurchaseParam purchaseParam =
                          PurchaseParam(productDetails: _products[0]);
                      print(
                          '${_products[0].title}: ${_products[0].description} (cost is ${_products[0].price})');
                      _connection.buyNonConsumable(
                          purchaseParam: purchaseParam);
                    } else {
                      _showInAppNotFound();
                    }
                  } else {
                    if (!state.courseDetailResponse.has_access) {
                      if (_bloc.selectedPaymetId == -1) {
                        _bloc.add(AddToCart(state.courseDetailResponse.id));
                      } else {
                        _bloc.add(UsePlan(state.courseDetailResponse.id));
                      }
                    }
                  }
                }
              },
              child: setUpButtonChild(state),
            )
          ],
        ),
      ),
    );
  }

  _showInAppNotFound() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(localizations.getLocalization("error_dialog_title"),
                textScaleFactor: 1.0,
                style: TextStyle(color: Colors.black, fontSize: 20.0)),
            content: Text(localizations.getLocalization("in_app_not_found")),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  localizations.getLocalization("ok_dialog_button"),
                  textScaleFactor: 1.0,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  _buildPrice(CourseState state) {
    if (state is LoadedCourseState) {
      if (!state.courseDetailResponse.has_access) {
        if (state.courseDetailResponse.price.free) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                localizations.getLocalization("course_free_price"),
                textScaleFactor: 1.0,
              ),
              (!Platform.isIOS) ? Icon(Icons.arrow_drop_down) : Text("")
            ],
          );
        } else {
          String selectedPlan;
          if (_bloc.selectedPaymetId == -1)
            selectedPlan =
                "${localizations.getLocalization("course_regular_price")} ${state.courseDetailResponse.price.price}";
          if (state.userPlans.isNotEmpty) {
            state.userPlans.forEach((value) {
              if (int.parse(value.subscription_id) == _bloc.selectedPaymetId)
                selectedPlan = value.name;
            });
          }
          if (_products.isNotEmpty)
            selectedPlan =
                "${localizations.getLocalization("course_regular_price")} ${_products[0].price}";
          return GestureDetector(
            onTap: () async {
              if (!Platform.isIOS) {
                var dialog = showDialog(
                    context: context,
                    builder: (builder) {
                      return BlocProvider.value(
                        child: Dialog(
                          child: PurchaseDialog(),
                        ),
                        value: _bloc,
                      );
                    });

                dialog.then((value) {
                  if (value == "update") {
                    _bloc.add(FetchEvent(widget.coursesBean.id));
                  } else {
                    setState(() {});
                  }
                });
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  selectedPlan,
                  textScaleFactor: 1.0,
                ),
                (!Platform.isIOS) ? Icon(Icons.arrow_drop_down) : Text("")
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

  Widget setUpButtonChild(CourseState state) {
    String buttonText;
    bool enable = state is LoadedCourseState;

    if (state is LoadedCourseState) {
      buttonText = state.courseDetailResponse.purchase_label;
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

  _buildStartButton(LoadedCourseState state) {
    return MaterialButton(
      height: 40,
      color: secondColor,
      onPressed: () {
        Navigator.of(context).pushNamed(
          UserCourseScreen.routeName,
          arguments: UserCourseScreenArgs(
            state.courseDetailResponse.id.toString(),
            widget.coursesBean.title,
            widget.coursesBean.images.small,
            state.courseDetailResponse.author.avatar_url,
            state.courseDetailResponse.author.login,
            "0",
            "1",
            "",
            "",
          ),
        );
      },
      child: Text(
        localizations.getLocalization("start_course_button"),
        textScaleFactor: 1.0,
        style: TextStyle(color: white),
      ),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  //InApp

  final InAppPurchase _connection = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> _notFoundIds = [];
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  List<String> _consumables = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String _queryProductError;

  _initInApp() {
    Stream purchaseUpdated =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
    initStoreInfo();
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _connection.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = [];
        _purchases = [];
        _notFoundIds = [];
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    var courseId = widget.coursesBean.id.toString();
    ProductDetailsResponse productDetailResponse =
        await _connection.queryProductDetails({courseId});

    if (productDetailResponse.error != null) {
      setState(() {
        _queryProductError = productDetailResponse.error.message;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = [];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = null;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = [];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    final QueryPurchaseDetailsResponse purchaseResponse =
        await _connection.queryPastPurchases();
//    if (purchaseResponse.error != null) {
//      // handle query past purchase error..
//    }
//    final List<PurchaseDetails> verifiedPurchases = [];
//    for (PurchaseDetails purchase in purchaseResponse.pastPurchases) {
//      if (await _verifyPurchase(purchase)) {
//        verifiedPurchases.add(purchase);
//      }
//    }
    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      //_purchases = verifiedPurchases;
      _notFoundIds = productDetailResponse.notFoundIDs;
      _purchasePending = false;
      _loading = false;
    });
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          handleError(purchaseDetails.error);
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          _verifyPurchase(purchaseDetails);
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchaseConnection.instance
              .completePurchase(purchaseDetails);
        }
      }
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    _bloc.add(VerifyInAppPurchase(
        purchaseDetails.verificationData.serverVerificationData,
        _products[0].price,
        widget.coursesBean.id));
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }

  void handleError(IAPError error) {
    print(error.details.toString());
    setState(() {
      //_purchasePending = false;
    });
  }
}
