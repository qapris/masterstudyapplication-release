import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masterstudy_app/ui/bloc/restore_password/bloc.dart';

import '../../../main.dart';

class RestorePasswordScreen extends StatelessWidget {
  static const routeName = "restorePasswordScreen";
  final RestorePasswordBloc bloc;

  const RestorePasswordScreen(this.bloc) : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
      ),
      body: BlocProvider<RestorePasswordBloc>(create: (context) => bloc, child: _RestorePasswordWidget()),
    );
  }
}

class _RestorePasswordWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RestorePasswordWidgetState();
}

class _RestorePasswordWidgetState extends State<_RestorePasswordWidget> {
  late RestorePasswordBloc _bloc;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  FocusNode myFocusNode = new FocusNode();

  @override
  void initState() {
    _bloc = BlocProvider.of<RestorePasswordBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _bloc,
      listener: (context, state) {
        if (state is SuccessRestorePasswordState)
          Scaffold.of(context).showSnackBar(
            SnackBar(
              // content: Text(localizations!.getLocalization("restore_password_sent_text")),
              content: Text("Restore password, check email"),
              backgroundColor: Colors.green,
            ),
          );
      },
      child: BlocBuilder<RestorePasswordBloc, RestorePasswordState>(
        bloc: _bloc,
        builder: (context, state) {
          return _buildForm(state);
        },
      ),
    );
  }

  _buildForm(state) {
    var enableInputs = !(state is LoadingRestorePasswordState);
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
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
                  color: myFocusNode.hasFocus ? Colors.black : Colors.black,
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
          //Button "Restore password"
          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0, top: 18.0),
            child: new MaterialButton(
              minWidth: double.infinity,
              color: mainColor,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _bloc.add(SendRestorePasswordEvent(_emailController.text));
                }
              },
              child: setUpButtonChild(enableInputs),
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
        localizations!.getLocalization("restore_password_button"),
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

  String? _validateEmail(dynamic value) {
    if (value.isEmpty) {
      // The form is empty
      return localizations!.getLocalization("email_empty_error_text");
    }
    // This is just a regular expression for email addresses
    String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" + "\\@" + "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" + "(" + "\\." + "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" + ")+";
    RegExp regExp = new RegExp(p);

    if (regExp.hasMatch(value)) {
      // So, the email is valid
      return null;
    }

    // The pattern of the email didn't match the regex above.
    return localizations!.getLocalization("email_invalid_error_text");
  }
}
