import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../main.dart';
import 'package:masterstudy_app/ui/bloc/change_password/bloc.dart';

class ChangePasswordScreen extends StatelessWidget {
  static const routeName = "changePasswordScreen";

  final ChangePasswordBloc bloc;

  const ChangePasswordScreen(this.bloc) : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Change Password',
          textScaleFactor: 1.0,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: mainColor,
      ),
      body: BlocProvider<ChangePasswordBloc>(create: (context) => bloc, child: ChangePasswordWidget()),
    );
  }
}

class ChangePasswordWidget extends StatefulWidget {
  const ChangePasswordWidget({Key? key}) : super(key: key);

  @override
  State<ChangePasswordWidget> createState() => _ChangePasswordWidgetState();
}

class _ChangePasswordWidgetState extends State<ChangePasswordWidget> {
  late ChangePasswordBloc _bloc;
  final _formKey = GlobalKey<FormState>();
  FocusNode myFocusNode = new FocusNode();
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController newPasswordConfirmController = TextEditingController();

  bool obscureText = true;
  bool obscureText1 = true;
  bool obscureText2 = true;

  @override
  void initState() {
    _bloc = BlocProvider.of<ChangePasswordBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _bloc,
      listener: (context, state) {
        if (state is SuccessChangePasswordState)
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations!.getLocalization("password_is_changed")),
              backgroundColor: Colors.green,
            ),
          );

        if(state is ErrorChangePasswordState) {
          WidgetsBinding.instance?.addPostFrameCallback((_) => showDialogError(context, state.message));
        }
      },
      child: BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
        bloc: _bloc,
        builder: (context, state) {
          return _widgetBuildBody(state);
        },
      ),
    );
  }

  _widgetBuildBody(state) {
    var enableInputs = !(state is LoadingChangePasswordState);

    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          //oldPassword
          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 18.0),
            child: TextFormField(
              controller: oldPasswordController,
              enabled: enableInputs,
              cursorColor: mainColor,
              // ignore: body_might_complete_normally_nullable
              validator: (val) {
                if (val!.isEmpty) return 'Fill in the field';
              },
              obscureText: obscureText,
              decoration: InputDecoration(
                labelText: localizations!.getLocalization('current_password'),
                helperText: localizations!.getLocalization('current_password_helper'),
                filled: true,
                suffixIcon: IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off,
                      color: mainColor,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    }),
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
              // validator: _validateEmail,
            ),
          ),
          //newPassword
          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 18.0),
            child: TextFormField(
              controller: newPasswordController,
              enabled: enableInputs,
              cursorColor: mainColor,
              obscureText: obscureText1,
              validator: (val) {
                if (val!.isEmpty) return 'Fill in the field';

                if (val.length < 8) {
                  return localizations!.getLocalization("password_register_characters_count_error_text");
                }

                if (RegExp(r'^[a-zA-Z]+$').hasMatch(val)) {
                  return 'Please a valid password';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: localizations!.getLocalization('new_password'),
                helperText: localizations!.getLocalization('password_registration_helper_text'),
                filled: true,
                labelStyle: TextStyle(
                  color: myFocusNode.hasFocus ? Colors.black : Colors.black,
                ),
                suffixIcon: IconButton(
                    icon: Icon(
                      obscureText1 ? Icons.visibility : Icons.visibility_off,
                      color: mainColor,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureText1 = !obscureText1;
                      });
                    }),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: mainColor!),
                ),
              ),
              // validator: _validateEmail,
            ),
          ),
          //newPasswordConfirm
          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 18.0),
            child: TextFormField(
              controller: newPasswordConfirmController,
              enabled: enableInputs,
              cursorColor: mainColor,
              validator: (val) {
                if (val!.isEmpty) {
                  return 'Fill in the field';
                }

                if (newPasswordController.text != newPasswordConfirmController.text) {
                  return 'Passwords do not match';
                }

                return null;
              },
              obscureText: obscureText2,
              decoration: InputDecoration(
                labelText: localizations!.getLocalization('confirm_password'),
                helperText: localizations!.getLocalization('confirm_password_helper'),
                filled: true,
                suffixIcon: IconButton(
                    icon: Icon(
                      obscureText2 ? Icons.visibility : Icons.visibility_off,
                      color: mainColor,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureText2 = !obscureText2;
                      });
                    }),
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
              // validator: _validateEmail,
            ),
          ),
          //Button "Change password"
          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 18.0),
            child: new MaterialButton(
              minWidth: double.infinity,
              color: mainColor,
              child: setUpButtonChild(enableInputs),
              onPressed: () {

                if (_formKey.currentState!.validate()) {
                  _bloc.add(SendChangePasswordEvent(oldPasswordController.text, newPasswordController.text));
                }
              },
              // child: setUpButtonChild(enableInputs),
              textColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget setUpButtonChild(enable) {
    if (enable == true) {
      return new Text(
        localizations!.getLocalization('change_password'),
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

  void showDialogError(context, text) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(localizations!.getLocalization("error_dialog_title"), textScaleFactor: 1.0, style: TextStyle(color: Colors.black, fontSize: 20.0)),
            content: Text(text ?? 'Error'),
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
                },
              ),
            ],
          );
        });
  }

}
