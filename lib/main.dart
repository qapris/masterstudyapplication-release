import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/repository/localization_repository.dart';
import 'package:masterstudy_app/theme/theme.dart';
import 'package:masterstudy_app/ui/bloc/assignment/assignment_bloc.dart';
import 'package:masterstudy_app/ui/bloc/category_detail/bloc.dart';
import 'package:masterstudy_app/ui/bloc/course/bloc.dart';
import 'package:masterstudy_app/ui/bloc/courses/bloc.dart';
import 'package:masterstudy_app/ui/bloc/detail_profile/bloc.dart';
import 'package:masterstudy_app/ui/bloc/edit_profile_bloc/bloc.dart';
import 'package:masterstudy_app/ui/bloc/favorites/bloc.dart';
import 'package:masterstudy_app/ui/bloc/final/bloc.dart';
import 'package:masterstudy_app/ui/bloc/home/bloc.dart';
import 'package:masterstudy_app/ui/bloc/home_simple/bloc.dart';
import 'package:masterstudy_app/ui/bloc/lesson_stream/bloc.dart';
import 'package:masterstudy_app/ui/bloc/lesson_video/bloc.dart';
import 'package:masterstudy_app/ui/bloc/lesson_zoom/bloc.dart';
import 'package:masterstudy_app/ui/bloc/orders/orders_bloc.dart';
import 'package:masterstudy_app/ui/bloc/plans/plans_bloc.dart';
import 'package:masterstudy_app/ui/bloc/profile/bloc.dart';
import 'package:masterstudy_app/ui/bloc/profile_assignment/profile_assignment_bloc.dart';
import 'package:masterstudy_app/ui/bloc/question_ask/bloc.dart';
import 'package:masterstudy_app/ui/bloc/question_details/bloc.dart';
import 'package:masterstudy_app/ui/bloc/questions/bloc.dart';
import 'package:masterstudy_app/ui/bloc/quiz_lesson/quiz_lesson_bloc.dart';
import 'package:masterstudy_app/ui/bloc/quiz_screen/quiz_screen_bloc.dart';
import 'package:masterstudy_app/ui/bloc/restore_password/restore_password_bloc.dart';
import 'package:masterstudy_app/ui/bloc/change_password/change_password_bloc.dart';
import 'package:masterstudy_app/ui/bloc/review_write/bloc.dart';
import 'package:masterstudy_app/ui/bloc/search/bloc.dart';
import 'package:masterstudy_app/ui/bloc/search_detail/bloc.dart';
import 'package:masterstudy_app/ui/bloc/text_lesson/bloc.dart';
import 'package:masterstudy_app/ui/bloc/user_course/bloc.dart';
import 'package:masterstudy_app/ui/bloc/user_course_locked/bloc.dart';
import 'package:masterstudy_app/ui/bloc/video/bloc.dart';
import 'package:masterstudy_app/ui/screens/assignment/assignment_screen.dart';
import 'package:masterstudy_app/ui/screens/auth/auth_screen.dart';
import 'package:masterstudy_app/ui/screens/category_detail/category_detail_screen.dart';
import 'package:masterstudy_app/ui/screens/course/course_screen.dart';
import 'package:masterstudy_app/ui/screens/detail_profile/detail_profile_screen.dart';
import 'package:masterstudy_app/ui/screens/final/final_screen.dart';
import 'package:masterstudy_app/ui/screens/lesson_stream/lesson_stream_screen.dart';
import 'package:masterstudy_app/ui/screens/lesson_video/lesson_video_screen.dart';
import 'package:masterstudy_app/ui/screens/main_screens.dart';
import 'package:masterstudy_app/ui/screens/plans/plans_screen.dart';
import 'package:masterstudy_app/ui/screens/profile_assignment/profile_assignment_screen.dart';
import 'package:masterstudy_app/ui/screens/profile_edit/profile_edit_screen.dart';
import 'package:masterstudy_app/ui/screens/question_ask/question_ask_screen.dart';
import 'package:masterstudy_app/ui/screens/question_details/question_details_screen.dart';
import 'package:masterstudy_app/ui/screens/questions/questions_screen.dart';
import 'package:masterstudy_app/ui/screens/quiz_lesson/quiz_lesson_screen.dart';
import 'package:masterstudy_app/ui/screens/quiz_screen/quiz_screen.dart';
import 'package:masterstudy_app/ui/screens/restore_password/restore_password_screen.dart';
import 'package:masterstudy_app/ui/screens/change_password/change_password_screen.dart';
import 'package:masterstudy_app/ui/screens/review_write/review_write_screen.dart';
import 'package:masterstudy_app/ui/screens/search_detail/search_detail_screen.dart';
import 'package:masterstudy_app/ui/screens/splash/splash_screen.dart';
import 'package:masterstudy_app/ui/screens/text_lesson/text_lesson_screen.dart';
import 'package:masterstudy_app/ui/screens/user_course/user_course.dart';
import 'package:masterstudy_app/ui/screens/user_course_locked/user_course_locked_screen.dart';
import 'package:masterstudy_app/ui/screens/video_screen/video_screen.dart';
import 'package:masterstudy_app/ui/screens/web_checkout/web_checkout_screen.dart';
import 'package:masterstudy_app/ui/screens/zoom/zoom.dart';
import 'package:masterstudy_app/ui/widgets/message_notification.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/push/push_manager.dart';
import 'data/utils.dart';
import 'di/app_injector.dart';
import 'ui/screens/orders/orders.dart';
import 'ui/screens/user_course/user_course.dart';

typedef Provider<T> = T Function();

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

LocalizationRepository? localizations;
Color? mainColor, mainColorA, secondColor;

StreamController pushStreamController = StreamController<RemoteMessage>();
Stream pushStream = pushStreamController.stream.asBroadcastStream();

bool dripContentEnabled = false;
bool? demoEnabled = false;
bool appView = false;

Future<String> getDefaultLocalization() async {
  String data = await rootBundle.loadString('assets/localization/default_locale.json');
  return data;
}

Future<dynamic>? myBackgroundMessageHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }
  // Or do other work.
  return null;
}

void main() async {
  //System style AppBar
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
    statusBarColor: Colors.grey.withOpacity(0.4), //top bar color
    statusBarIconBrightness: Brightness.light, //top bar icons
  ));
  WidgetsFlutterBinding.ensureInitialized();


  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

    var swAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
    var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

    if (swAvailable && swInterceptAvailable) {
      AndroidServiceWorkerController serviceWorkerController =
      AndroidServiceWorkerController.instance();

      await serviceWorkerController
          .setServiceWorkerClient(AndroidServiceWorkerClient(
        shouldInterceptRequest: (request) async {
          print(request);
          return null;
        },
      ));
    }
  }

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  //SharedPreferences
  preferences = await SharedPreferences.getInstance();

  //Firebase
  await Firebase.initializeApp();
  FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  PushNotificationsManager().init();

  //Localizations
  localizations = LocalizationRepositoryImpl(await getDefaultLocalization());

  appDocDir = await getApplicationDocumentsDirectory();
  appView = preferences!.getBool("app_view") ?? false;

  if (Platform.isAndroid) androidInfo = await deviceInfo.androidInfo;
  if (Platform.isIOS) iosDeviceInfo = await deviceInfo.iosInfo;

  //runApp
  runZoned(() async {
    var container = await AppInjector.create();
    runApp(container.app);
  }, onError: FirebaseCrashlytics.instance.recordError);
}

@provide
class MyApp extends StatefulWidget {
  final Provider<AuthScreen> authScreen;
  final Provider<HomeBloc> homeBloc;
  final Provider<FavoritesBloc> favoritesBloc;
  final Provider<SplashScreen> splashScreen;
  final Provider<ProfileBloc> profileBloc;
  final Provider<DetailProfileBloc> detailProfileBloc;
  final Provider<EditProfileBloc> editProfileBloc;
  final Provider<SearchScreenBloc> searchScreenBloc;
  final Provider<SearchDetailBloc> searchDetailBloc;
  final Provider<CourseBloc> courseBloc;
  final Provider<HomeSimpleBloc> homeSimpleBloc;
  final Provider<CategoryDetailBloc> categoryDetailBloc;
  final Provider<AssignmentBloc> assignmentBloc;
  final Provider<ProfileAssignmentBloc> profileAssignmentBloc;
  final Provider<ReviewWriteBloc> reviewWriteBloc;
  final Provider<UserCoursesBloc> userCoursesBloc;
  final Provider<UserCourseBloc> userCourseBloc;
  final Provider<UserCourseLockedBloc> userCourseLockedBloc;
  final Provider<TextLessonBloc> textLessonBloc;
  final Provider<LessonVideoBloc> lessonVideoBloc;
  final Provider<LessonStreamBloc> lessonStreamBloc;
  final Provider<VideoBloc> videoBloc;
  final Provider<QuizLessonBloc> quizLessonBloc;
  final Provider<QuestionsBloc> questionsBloc;
  final Provider<QuestionAskBloc> questionAskBloc;
  final Provider<QuestionDetailsBloc> questionDetailsBloc;
  final Provider<QuizScreenBloc> quizScreenBloc;
  final Provider<FinalBloc> finalBloc;
  final Provider<PlansBloc> plansBloc;
  final Provider<OrdersBloc> ordersBloc;
  final Provider<RestorePasswordBloc> restorePasswordBloc;
  final Provider<LessonZoomBloc> lessonZoomBloc;
  final Provider<ChangePasswordBloc> changePasswordBloc;

  const MyApp(
    this.authScreen,
    this.homeBloc,
    this.splashScreen,
    this.favoritesBloc,
    this.profileBloc,
    this.editProfileBloc,
    this.detailProfileBloc,
    this.searchScreenBloc,
    this.searchDetailBloc,
    this.courseBloc,
    this.homeSimpleBloc,
    this.categoryDetailBloc,
    this.profileAssignmentBloc,
    this.assignmentBloc,
    this.reviewWriteBloc,
    this.userCoursesBloc,
    this.userCourseBloc,
    this.userCourseLockedBloc,
    this.textLessonBloc,
    this.quizLessonBloc,
    this.lessonVideoBloc,
    this.lessonStreamBloc,
    this.videoBloc,
    this.questionsBloc,
    this.questionAskBloc,
    this.questionDetailsBloc,
    this.quizScreenBloc,
    this.finalBloc,
    this.plansBloc,
    this.ordersBloc,
    this.restorePasswordBloc,
    this.lessonZoomBloc,
    this.changePasswordBloc,
  ) : super();

  _getProvidedMainScreen() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(create: (BuildContext context) => homeBloc()),
        BlocProvider<HomeSimpleBloc>(create: (BuildContext context) => homeSimpleBloc()),
        BlocProvider<FavoritesBloc>(create: (BuildContext context) => favoritesBloc()),
        BlocProvider<SearchScreenBloc>(create: (BuildContext context) => searchScreenBloc()),
        BlocProvider<UserCoursesBloc>(create: (BuildContext context) => userCoursesBloc()),
      ],
      child: MainScreen(),
    );
  }

  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  ThemeData _buildShrineTheme() {
    final ThemeData base = ThemeData.light();
    return base.copyWith(
      primaryColor: mainColor,
      buttonTheme: buttonThemeData,
      buttonBarTheme: base.buttonBarTheme.copyWith(
        buttonTextTheme: ButtonTextTheme.accent,
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
      ),
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white,
      textTheme: getTextTheme(base.primaryTextTheme),
      primaryTextTheme: getTextTheme(base.primaryTextTheme).apply(
        bodyColor: mainColor,
        displayColor: mainColor,
      ),
      errorColor: Colors.red[400],
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: mainColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    pushStream.listen((event) {
      var message = event as Map<String, dynamic>;
      var notification = message["notification"];
      showOverlayNotification((context) {
        return MessageNotification(
          notification["title"],
          notification["body"],
          onReplay: () {
            OverlaySupportEntry.of(context)?.dismiss();
          },
        );
      }, duration: Duration(seconds: 5));
    });
    return BlocProvider(
      create: (BuildContext context) => widget.profileBloc(),
      child: OverlaySupport(
        child: MaterialApp(
          title: 'Masterstudy',
          theme: _buildShrineTheme(),
          initialRoute: SplashScreen.routeName,
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          onGenerateRoute: (routeSettings) {
            switch (routeSettings.name) {
              case SplashScreen.routeName:
                return MaterialPageRoute(builder: (context) => widget.splashScreen());
              case AuthScreen.routeName:
                return MaterialPageRoute(builder: (context) => widget.authScreen(), settings: routeSettings);
              case MainScreen.routeName:
                return MaterialPageRoute(builder: (context) => widget._getProvidedMainScreen(), settings: routeSettings);
              case CourseScreen.routeName:
                return MaterialPageRoute(builder: (context) => CourseScreen(widget.courseBloc()), settings: routeSettings);
              case SearchDetailScreen.routeName:
                return MaterialPageRoute(builder: (context) => SearchDetailScreen(widget.searchDetailBloc()), settings: routeSettings);
              case DetailProfileScreen.routeName:
                return MaterialPageRoute(builder: (context) => DetailProfileScreen(widget.detailProfileBloc()), settings: routeSettings);
              case ProfileEditScreen.routeName:
                return MaterialPageRoute(builder: (context) => ProfileEditScreen(widget.editProfileBloc()), settings: routeSettings);
              case CategoryDetailScreen.routeName:
                return MaterialPageRoute(builder: (context) => CategoryDetailScreen(widget.categoryDetailBloc()), settings: routeSettings);
              case ProfileAssignmentScreen.routeName:
                return MaterialPageRoute(builder: (context) => ProfileAssignmentScreen(widget.profileAssignmentBloc()), settings: routeSettings);
              case AssignmentScreen.routeName:
                return MaterialPageRoute(builder: (context) => AssignmentScreen(widget.assignmentBloc()), settings: routeSettings);
              case ReviewWriteScreen.routeName:
                return MaterialPageRoute(builder: (context) => ReviewWriteScreen(widget.reviewWriteBloc()), settings: routeSettings);
              case UserCourseScreen.routeName:
                return MaterialPageRoute(builder: (context) => UserCourseScreen(widget.userCourseBloc()), settings: routeSettings);
              case TextLessonScreen.routeName:
                return PageTransition(child: TextLessonScreen(widget.textLessonBloc()), type: PageTransitionType.leftToRight, settings: routeSettings);
              case LessonVideoScreen.routeName:
                return MaterialPageRoute(builder: (context) => LessonVideoScreen(widget.lessonVideoBloc()), settings: routeSettings);
              case LessonStreamScreen.routeName:
                return MaterialPageRoute(builder: (context) => LessonStreamScreen(widget.lessonStreamBloc()), settings: routeSettings);
              case VideoScreen.routeName:
                return MaterialPageRoute(builder: (context) => VideoScreen(widget.videoBloc()), settings: routeSettings);
              case QuizLessonScreen.routeName:
                return MaterialPageRoute(builder: (context) => QuizLessonScreen(widget.quizLessonBloc()), settings: routeSettings);
              case QuestionsScreen.routeName:
                return MaterialPageRoute(builder: (context) => QuestionsScreen(widget.questionsBloc()), settings: routeSettings);
              case QuestionAskScreen.routeName:
                return MaterialPageRoute(builder: (context) => QuestionAskScreen(widget.questionAskBloc()), settings: routeSettings);
              case QuestionDetailsScreen.routeName:
                return MaterialPageRoute(builder: (context) => QuestionDetailsScreen(widget.questionDetailsBloc()), settings: routeSettings);
              case FinalScreen.routeName:
                return MaterialPageRoute(builder: (context) => FinalScreen(widget.finalBloc()), settings: routeSettings);
              case QuizScreen.routeName:
                return MaterialPageRoute(builder: (context) => QuizScreen(widget.quizScreenBloc()), settings: routeSettings);
              case PlansScreen.routeName:
                return MaterialPageRoute(builder: (context) => PlansScreen(widget.plansBloc()), settings: routeSettings);
              case WebCheckoutScreen.routeName:
                return MaterialPageRoute(builder: (context) => WebCheckoutScreen(), settings: routeSettings);
              case OrdersScreen.routeName:
                return MaterialPageRoute(builder: (context) => OrdersScreen(widget.ordersBloc()), settings: routeSettings);
              case UserCourseLockedScreen.routeName:
                return MaterialPageRoute(builder: (context) => UserCourseLockedScreen(widget.courseBloc()), settings: routeSettings);
              case RestorePasswordScreen.routeName:
                return MaterialPageRoute(builder: (context) => RestorePasswordScreen(widget.restorePasswordBloc()), settings: routeSettings);
              case ChangePasswordScreen.routeName:
                return MaterialPageRoute(builder: (context) => ChangePasswordScreen(widget.changePasswordBloc()), settings: routeSettings);
              case LessonZoomScreen.routeName:
                return MaterialPageRoute(builder: (context) => LessonZoomScreen(widget.lessonZoomBloc()), settings: routeSettings);

              default:
                return MaterialPageRoute(builder: (context) => widget.splashScreen());
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
