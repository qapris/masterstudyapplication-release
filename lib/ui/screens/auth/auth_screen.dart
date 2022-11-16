import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inject/inject.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:masterstudy_app/data/models/AppSettings.dart';
import 'package:masterstudy_app/main.dart';
import 'package:masterstudy_app/ui/screens/main_screens.dart';
import '../../../data/utils.dart';
import '../../bloc/auth/bloc.dart';
import '../restore_password/restore_password_screen.dart';

class AuthScreenArgs {
  final OptionsBean optionsBean;

  AuthScreenArgs(this.optionsBean);
}

@provide
class AuthScreen extends StatelessWidget {
  final AuthBloc _bloc;
  static const routeName = "authScreen";

  AuthScreen(this._bloc);

  @override
  Widget build(BuildContext context) {
    final AuthScreenArgs args = ModalRoute.of(context)?.settings.arguments as AuthScreenArgs;
    return BlocProvider(child: AuthScreenWidget(args.optionsBean), create: (context) => _bloc);
  }
}

//Auth Tabs
class AuthScreenWidget extends StatefulWidget {
  final OptionsBean optionsBean;

  const AuthScreenWidget(this.optionsBean) : super();

  @override
  State<StatefulWidget> createState() => AuthScreenWidgetState();
}

class AuthScreenWidgetState extends State<AuthScreenWidget> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(110.0), // here th
          child: AppBar(
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            backgroundColor: Colors.white,
            title: Center(
              //Logo
              child: Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: appLogoUrl!.contains('svg')
                    ? SvgPicture.network(appLogoUrl!)
                    : CachedNetworkImage(
                        imageUrl: appLogoUrl!,
                        placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) {
                          if (appLogoUrl.toString().contains('svg')) {
                            SizedBox(width: 50.0, child: SvgPicture.asset(appLogoUrl.toString()));
                          } else {
                            SizedBox(
                              width: 50.0,
                              child: Image.network(appLogoUrl!),
                            );
                          }

                          return SizedBox(
                            width: 83.0,
                            child: Image.asset('assets/icons/logo.png'),
                          );
                        },
                        width: 50.0,
                      ),
              ),
            ),
            bottom: TabBar(
              indicatorColor: mainColorA,
              tabs: [
                //SignUp
                Tab(
                  icon: Text(
                    localizations!.getLocalization("auth_sign_up_tab"),
                    textScaleFactor: 1.0,
                    style: TextStyle(color: mainColor),
                  ),
                ),
                //SignIn
                Tab(
                  icon: Text(
                    localizations!.getLocalization("auth_sign_in_tab"),
                    textScaleFactor: 1.0,
                    style: TextStyle(color: mainColor),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: <Widget>[
              //SignUp
              ListView(
                children: <Widget>[_SignUpPage(widget.optionsBean)],
              ),
              //SignIn
              ListView(
                children: <Widget>[_SignInPage(widget.optionsBean)],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//Registration
class _SignUpPage extends StatefulWidget {
  final OptionsBean optionsBean;

  const _SignUpPage(this.optionsBean) : super();

  @override
  State<StatefulWidget> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<_SignUpPage> {
  late AuthBloc _bloc;
  final _formKey = GlobalKey<FormState>();

  TextEditingController _loginController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  FocusNode myFocusNode = new FocusNode();

  var passwordVisible = false;
  bool enableInputsDemo = false;
  bool enableInputs = true;

  @override
  void initState() {
    _bloc = BlocProvider.of<AuthBloc>(context);
    passwordVisible = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('Demo: ${preferences!.getBool('demo')}');
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is SuccessAuthState) {
            enableInputsDemo = false;
            enableInputs = true;
          WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.pushReplacementNamed(context, MainScreen.routeName, arguments: MainScreenArgs(widget.optionsBean)));
        }

        if (state is ErrorAuthState) {
            enableInputs = true;
            enableInputsDemo = false;
            preferences!.setBool('demo', false);
          WidgetsBinding.instance.addPostFrameCallback((_) => showDialogError(context, state.message));
        }

        return Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              //Login
              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 30.0),
                child: TextFormField(
                  controller: _loginController,
                  enabled: enableInputs,
                  cursorColor: mainColor,
                  decoration: InputDecoration(
                    labelText: localizations!.getLocalization("login_label_text"),
                    helperText: localizations!.getLocalization("login_registration_helper_text"),
                    filled: true,
                    labelStyle: TextStyle(
                      color: myFocusNode.hasFocus ? Colors.red : Colors.black,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: mainColor!),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return localizations!.getLocalization("login_empty_error_text");
                    }
                    return null;
                  },
                ),
              ),
              //Email
              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 18.0),
                child: TextFormField(
                  controller: _emailController,
                  enabled: enableInputs,
                  cursorColor: mainColor,
                  decoration: InputDecoration(
                    labelText: localizations!.getLocalization("email_label_text"),
                    helperText: localizations!.getLocalization("email_helper_text"),
                    filled: true,
                    labelStyle: TextStyle(
                      color: myFocusNode.hasFocus ? Colors.red : Colors.black,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: mainColor!),
                    ),
                  ),
                  validator: _validateEmail,
                ),
              ),
              //Password
              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 18.0),
                child: TextFormField(
                  controller: _passwordController,
                  enabled: enableInputs,
                  obscureText: passwordVisible,
                  cursorColor: mainColor,
                  decoration: InputDecoration(
                    labelText: localizations!.getLocalization("password_label_text"),
                    helperText: localizations!.getLocalization("password_registration_helper_text"),
                    filled: true,
                    labelStyle: TextStyle(
                      color: myFocusNode.hasFocus ? Colors.red : Colors.black,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: mainColor!),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        passwordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                      color: mainColor,
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return localizations!.getLocalization("password_empty_error_text");
                    }
                    if (value.length < 8) {
                      return localizations!.getLocalization("password_register_characters_count_error_text");
                    }

                    return null;
                  },
                ),
              ),
              //Button "Registration"
              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 18.0),
                child: MaterialButton(
                  minWidth: double.infinity,
                  color: mainColor,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        enableInputs = false;
                      });
                      _bloc.add(
                        RegisterEvent(
                          _loginController.text,
                          _emailController.text,
                          _passwordController.text,
                        ),
                      );
                    }
                  },
                  child: setUpButtonChild(enableInputs),
                  textColor: Colors.white,
                ),
              ),
              //Button "DEMO auth"
              Visibility(
                visible: demoEnabled ?? false,
                child: Padding(
                  padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 18.0),
                  child: new MaterialButton(
                    minWidth: double.infinity,
                    color: mainColor,
                    onPressed: () {
                      setState(() {
                        enableInputsDemo = true;
                      });

                      preferences!.setBool('demo', true);

                      _bloc.add(DemoAuthEvent());
                    },
                    child: setUpButtonChildDemo(enableInputsDemo),
                    textColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showDialogError(context, text) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            localizations!.getLocalization("error_dialog_title"),
            textScaleFactor: 1.0,
            style: TextStyle(color: Colors.black, fontSize: 20.0),
          ),
          content: Text(text, textScaleFactor: 1.0),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: mainColor,
              ),
              child: Text(
                localizations!.getLocalization("ok_dialog_button"),
                textScaleFactor: 1.0,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _bloc.add(CloseDialogEvent());
              },
            ),
          ],
        );
      },
    );
  }

  //Label in button "Registration"
  Widget setUpButtonChild(enable) {
    if (enable == true) {
      return new Text(
        localizations!.getLocalization("registration_button"),
        textScaleFactor: 1.0,
      );
    } else {
      return SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }
  }

  //Label in button "Demo Auth"
  Widget setUpButtonChildDemo(enableDemo) {
    if (enableDemo == false) {
      return new Text(
        localizations!.getLocalization("registration_demo_button"),
        textScaleFactor: 1.0,
      );
    } else {
      return SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value!.isEmpty) {
      // The form is empty
      return localizations!.getLocalization("email_empty_error_text");
    }
    // This is just a regular expression for email addresses
    String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" + "\\@" + "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" + "(" + "\\." + "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" + ")+";
    RegExp regExp = new RegExp(p);

    if (regExp.hasMatch(value)) {
      return null;
    }

    // The pattern of the email didn't match the regex above.
    return localizations!.getLocalization("email_invalid_error_text");
  }
}

//Login
class _SignInPage extends StatefulWidget {
  final OptionsBean optionsBean;

  const _SignInPage(this.optionsBean) : super();

  @override
  State<StatefulWidget> createState() => _SignInPageState();
}

class _SignInPageState extends State<_SignInPage> {
  late AuthBloc _bloc;
  final _formKey = GlobalKey<FormState>();

  TextEditingController _loginController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  FocusNode myFocusNode = new FocusNode();
  var passwordVisible = false;

  @override
  void initState() {
    _bloc = BlocProvider.of<AuthBloc>(context);
    passwordVisible = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        var enableInputs = !(state is LoadingAuthState);

        if (state is SuccessAuthState) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => Navigator.pushReplacementNamed(
              context,
              MainScreen.routeName,
              arguments: MainScreenArgs(widget.optionsBean),
            ),
          );
        }

        if (state is ErrorAuthState) {
          WidgetsBinding.instance.addPostFrameCallback((_) => showDialogError(context, state.message));
        }

        return Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              //Login
              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 30.0),
                child: TextFormField(
                  controller: _loginController,
                  enabled: enableInputs,
                  cursorColor: mainColor,
                  decoration: InputDecoration(
                    labelText: localizations!.getLocalization("login_label_text"),
                    helperText: localizations!.getLocalization("login_sign_in_helper_text"),
                    filled: true,
                    labelStyle: TextStyle(
                      color: myFocusNode.hasFocus ? Colors.black : Colors.black,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: mainColor!),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return localizations!.getLocalization("login_sign_in_helper_text");
                    }
                    return null;
                  },
                ),
              ),
              //Password
              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 18.0),
                child: TextFormField(
                  controller: _passwordController,
                  enabled: enableInputs,
                  obscureText: passwordVisible,
                  cursorColor: mainColor,
                  decoration: InputDecoration(
                    labelText: localizations!.getLocalization("password_label_text"),
                    helperText: localizations!.getLocalization("password_sign_in_helper_text"),
                    filled: true,
                    labelStyle: TextStyle(
                      color: myFocusNode.hasFocus ? Colors.black : Colors.black,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: mainColor!),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        passwordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                      color: mainColor,
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return localizations!.getLocalization("password_sign_in_helper_text");
                    }

                    if (value.length < 4) {
                      return localizations!.getLocalization("password_sign_in_characters_count_error_text");
                    }

                    return null;
                  },
                ),
              ),
              //Button "Войти"
              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 18.0),
                child: new MaterialButton(
                  minWidth: double.infinity,
                  color: mainColor,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if(_loginController.text == 'demoapp' && _passwordController.text == 'demoapp') {
                        preferences!.setBool('demo', true);
                        _bloc.add(LoginEvent(_loginController.text, _passwordController.text));
                      }else {
                        _bloc.add(LoginEvent(_loginController.text, _passwordController.text));
                      }
                    }
                  },
                  child: setUpButtonChild(enableInputs),
                  textColor: Colors.white,
                ),
              ),
              //RestorePassword
              ElevatedButton(
                child: Text(
                  localizations!.getLocalization("restore_password_button"),
                  style: TextStyle(color: mainColor),
                  textScaleFactor: 1.0,
                ),
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(0.0),
                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(RestorePasswordScreen.routeName);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showDialogError(context, text) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(localizations!.getLocalization("error_dialog_title"), textScaleFactor: 1.0, style: TextStyle(color: Colors.black, fontSize: 20.0)),
            content: Text(text),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: mainColor,
                ),
                child: Text(
                  localizations!.getLocalization("ok_dialog_button"),
                  textScaleFactor: 1.0,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _bloc.add(CloseDialogEvent());
                },
              ),
            ],
          );
        });
  }

  //Button label text
  Widget setUpButtonChild(enable) {
    if (enable == true) {
      return new Text(
        localizations!.getLocalization("sign_in_button"),
        textScaleFactor: 1.0,
      );
    } else {
      return SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }
  }
}
