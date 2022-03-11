import 'package:inject/inject.dart';
import 'package:masterstudy_app/di/modules.dart';

import '../main.dart';
import '../ui/screens/auth/auth_screen.dart';
import '../ui/screens/home/home_screen.dart';
import '../ui/screens/splash/splash_screen.dart';
import 'app_injector.inject.dart' as g;

@Injector(const [AppModule])
abstract class AppInjector {
  @provide
  MyApp get app;

  @provide
  AuthScreen get authScreen;

  @provide
  HomeScreen get homeScreen;

  @provide
  SplashScreen get splashScreen;

  static Future<AppInjector> create() {
    return g.AppInjector$Injector.create(AppModule());
  }
}
