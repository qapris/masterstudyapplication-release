import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inject/inject.dart';
import 'package:masterstudy_app/data/models/AppSettings.dart';
import 'package:masterstudy_app/main.dart';
import 'package:masterstudy_app/theme/theme.dart';
import 'package:masterstudy_app/ui/bloc/splash/bloc.dart';
import 'package:masterstudy_app/ui/screens/auth/auth_screen.dart';
import 'package:masterstudy_app/ui/widgets/loading_error_widget.dart';
import 'package:path_provider/path_provider.dart';
import '../../../data/utils.dart';
import '../../screenS/main_screens.dart';

@provide
class SplashScreen extends StatelessWidget {
  static const String routeName = "splashScreen";
  SplashBloc bloc;

  SplashScreen(this.bloc);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => bloc,
        child: SplashWidget(),
      ),
    );
  }
}

class SplashWidget extends StatefulWidget {
  @override
  State<SplashWidget> createState() => SplashWidgetState();
}

class SplashWidgetState extends State<SplashWidget> {
  File? newImage;

  Future getAppSettingColor() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    ///If user connect to mobile or wifi
    if (connectivityResult == ConnectivityResult.wifi || connectivityResult == ConnectivityResult.mobile) {
      Response response = await dio.get('$apiEndpoint' + 'app_settings');

      if (response.statusCode == 200) {
        log("${response.data['options']}");
        if (response.data['options']['main_color_hex'].toString().contains('#') &&
            response.data['options']['secondary_color_hex'].toString().contains('#')) {
          var mainColorHex = response.data['options']['main_color_hex'];
          var secondColorHex = response.data['options']['secondary_color_hex'];

          if (mainColorHex != null) {
            mainColor = HexColor.fromHex(response.data['options']['main_color_hex']);
            mainColorA = HexColor.fromHex(response.data['options']['main_color_hex']);
          } else {
            mainColor = blue_blue;
          }

          if (secondColorHex != null) {
            secondColor = HexColor.fromHex(response.data['options']['secondary_color_hex']);
          } else {
            secondColor = seaweed;
          }
        } else {
          try {
            var mainColorItem = response.data['options']['main_color'];
            var secondColorItem = response.data['options']['secondary_color'];

            if (mainColorItem != null) {
              mainColor = Color.fromRGBO(
                mainColorItem['r'],
                mainColorItem['g'],
                mainColorItem['b'],
                double.parse(mainColorItem['a'].toString()),
              );

              mainColorA = Color.fromRGBO(
                mainColorItem['r'],
                mainColorItem['g'],
                mainColorItem['b'],
                0.999,
              );
            } else if (response.data['options']['main_color_hex'].toString().contains('#')) {
              mainColor = HexColor.fromHex(response.data['options']['main_color_hex']);
            } else {
              mainColor = blue_blue;
            }

            if (secondColorItem != null) {
              secondColor = Color.fromRGBO(
                secondColorItem['r'],
                secondColorItem['g'],
                secondColorItem['b'],
                double.parse(secondColorItem['a'].toString()),
              );
            } else if (response.data['options']['secondary_color_hex'].toString().contains('#')) {
              secondColor = HexColor.fromHex(response.data['options']['secondary_color_hex']);
            } else {
              secondColor = seaweed;
            }
          } on DioError {
            mainColor = blue_blue;
            mainColorA = blue_blue_a;
            secondColor = seaweed;
          }
        }
      }
    } else {
      try {
        final mcr = preferences!.getInt("main_color_r");
        final mcg = preferences!.getInt("main_color_g");
        final mcb = preferences!.getInt("main_color_b");
        final mca = preferences!.getDouble("main_color_a");

        final scr = preferences!.getInt("second_color_r");
        final scg = preferences!.getInt("second_color_g");
        final scb = preferences!.getInt("second_color_b");
        final sca = preferences!.getDouble("second_color_a");

        mainColor = Color.fromRGBO(mcr, mcg, mcb, mca);
        mainColorA = Color.fromRGBO(mcr, mcg, mcb, 0.999);
        secondColor = Color.fromRGBO(scr, scg, scb, sca);
      } catch (e) {
        mainColor = blue_blue;
        mainColorA = blue_blue_a;
        secondColor = seaweed;
      }
    }
    return true;
  }

  @override
  void initState() {
    //GetAppColor
    getAppSettingColor();
    //SplashBloc
    BlocProvider.of<SplashBloc>(context).add(CheckAuthSplashEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SplashBloc, SplashState>(
      builder: (context, state) {
        return Center(
          child: _buildLogoBlock(state),
        );
      },
    );
  }

  _buildLogoBlock(state) {
    if (state is InitialSplashState)
      return Center(
        child: CircularProgressIndicator(),
      );

    if (state is CloseSplash) {
      String imgUrl = "";
      String postsCount = "";
      appLogoUrl = imgUrl;

      ///Cached img to file
      Future<File> _fileFromImageUrl() async {
        var url = state.appSettings!.options!.logo;
        final Response res = await Dio().get<List<int>>(
          url,
          options: Options(responseType: ResponseType.bytes),
        );

        // Get App local storage
        final Directory appDir = await getApplicationDocumentsDirectory();

        // Generate Image Name
        final String imageName = url.split('/').last;

        // Create Empty File in app dir & fill with new image
        newImage = File('${appDir.path}/$imageName');

        newImage!.writeAsBytesSync(res.data as List<int>);

        return newImage!;
      }

      if (state.isSigned) {
        if (state.appSettings != null) {
          openMainPage(state.appSettings!.options!);
        } else {
          openMainPage(state.appSettings!.options);
        }
      } else {
        if (state.appSettings != null) {
          openAuthPage(state.appSettings!.options!);
        } else {
          openAuthPage(null);
        }
      }

      if (state.appSettings != null) {
        ///Logo
        _fileFromImageUrl();
        imgUrl = state.appSettings!.options?.logo == null ? "" : state.appSettings!.options!.logo;
        appLogoUrl = state.appSettings!.options?.logo == null ? "" : state.appSettings!.options!.logo;

        ///Demo
        demoEnabled = state.appSettings!.demo;

        ///Addons about count course
        if (state.appSettings!.addons != null)
          dripContentEnabled =
              state.appSettings!.addons?.sequential_drip_content != null && state.appSettings!.addons?.sequential_drip_content == "on";
        postsCount = state.appSettings!.options!.posts_count.toString();

        return Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              imgUrl.contains('svg')
                  ? SvgPicture.network(imgUrl)
                  : CachedNetworkImage(
                      imageUrl: imgUrl,
                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) {
                        if (newImage.toString().contains('svg')) {
                          SizedBox(width: 83.0, child: SvgPicture.asset(newImage.toString()));
                        } else if (!newImage.toString().contains('svg')) {
                          SizedBox(width: 83.0, child: Image.file(File(newImage.toString())));
                        }
                        return SizedBox(
                          width: 83.0,
                          child: Image.asset('assets/icons/logo.png'),
                        );
                      },
                      width: 83.0,
                    ),
              //Count course
              Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 5.0),
                child: Text(
                  postsCount,
                  textScaleFactor: 1.0,
                  style: TextStyle(color: mainColor, fontSize: 40.0),
                ),
              ),
              //Text "Course"
              Padding(
                padding: EdgeInsets.only(bottom: 0),
                child: Text(
                  (postsCount != "") ? "COURSES" : "",
                  textScaleFactor: 1.0,
                  style: TextStyle(color: HexColor.fromHex("#000000"), fontSize: 14.0, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        );
      }
    }

    if (state is ErrorSplashState) {
      return LoadingErrorWidget(() {
        BlocProvider.of<SplashBloc>(context).add(CheckAuthSplashEvent());
      });
    }
  }

  void openAuthPage(OptionsBean? optionsBean) {
    _ambiguate(SchedulerBinding.instance)!.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        Navigator.of(context).pushReplacementNamed(AuthScreen.routeName, arguments: AuthScreenArgs(optionsBean!));
      });
    });
  }

  T? _ambiguate<T>(T? value) => value;

  void openMainPage(OptionsBean? optionsBean) {
    _ambiguate(SchedulerBinding.instance)!.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        Navigator.of(context).pushReplacementNamed(MainScreen.routeName, arguments: MainScreenArgs(optionsBean!));
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
